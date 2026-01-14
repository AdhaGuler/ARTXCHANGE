package com.artexchange.util;

import com.artexchange.dao.MessageDAO;
import com.artexchange.dao.ArtworkDAO;
import com.artexchange.model.Message;
import com.artexchange.model.Artwork;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;

/**
 * Utility class for sending notifications to users
 */
public class NotificationUtil {
    private static final Logger logger = Logger.getLogger(NotificationUtil.class.getName());
    private static final MessageDAO messageDAO = new MessageDAO();
    private static final ArtworkDAO artworkDAO = new ArtworkDAO();
    
    /**
     * Send purchase completion notifications to both buyer and seller
     * 
     * @param artworkId The ID of the purchased artwork
     * @param buyerId The ID of the buyer
     * @param sellerId The ID of the seller (artist)
     * @param purchaseId The ID of the purchase record
     */
    public static void sendPurchaseNotifications(String artworkId, String buyerId, String sellerId, String purchaseId) {
        try {
            // Get artwork details for notification context
            Artwork artwork = artworkDAO.findById(artworkId);
            String artworkTitle = artwork != null ? artwork.getTitle() : "artwork";
            
            // Send notification to buyer
            sendBuyerNotification(buyerId, artworkId, artworkTitle, purchaseId);
            
            // Send notification to seller
            sendSellerNotification(sellerId, artworkId, artworkTitle, purchaseId);
            
            logger.info("Purchase notifications sent for artwork: " + artworkId + " (Purchase ID: " + purchaseId + ")");
            
        } catch (Exception e) {
            logger.severe("Error sending purchase notifications: " + e.getMessage());
            // Don't throw - notifications are non-critical
        }
    }
    
    /**
     * Send purchase confirmation notification to buyer
     */
    private static void sendBuyerNotification(String buyerId, String artworkId, String artworkTitle, String purchaseId) 
            throws ExecutionException, InterruptedException {
        Message buyerMessage = new Message();
        buyerMessage.setSenderId("SYSTEM"); // System-generated notification
        buyerMessage.setReceiverId(buyerId);
        buyerMessage.setArtworkId(artworkId);
        buyerMessage.setContent("Thank you for your purchase! Your receipt and purchase details are now available.");
        buyerMessage.setMessageType(Message.MessageType.PURCHASE_NOTIFICATION);
        buyerMessage.setRead(false);
        buyerMessage.setSentAt(java.time.LocalDateTime.now());
        
        messageDAO.createMessage(buyerMessage);
        logger.info("Buyer notification sent to user: " + buyerId);
    }
    
    /**
     * Send sale notification to seller
     */
    private static void sendSellerNotification(String sellerId, String artworkId, String artworkTitle, String purchaseId) 
            throws ExecutionException, InterruptedException {
        Message sellerMessage = new Message();
        sellerMessage.setSenderId("SYSTEM"); // System-generated notification
        sellerMessage.setReceiverId(sellerId);
        sellerMessage.setArtworkId(artworkId);
        sellerMessage.setContent("Your artwork has been sold. View the purchase details in your dashboard.");
        sellerMessage.setMessageType(Message.MessageType.PURCHASE_NOTIFICATION);
        sellerMessage.setRead(false);
        sellerMessage.setSentAt(java.time.LocalDateTime.now());
        
        messageDAO.createMessage(sellerMessage);
        logger.info("Seller notification sent to user: " + sellerId);
    }
    
    /**
     * Send auction winner notifications to both winner and seller
     * 
     * @param artworkId The ID of the auction artwork
     * @param artworkTitle The title of the artwork
     * @param winnerId The ID of the winning bidder
     * @param winnerName The name of the winning bidder
     * @param winningBidAmount The winning bid amount
     * @param sellerId The ID of the seller (artist)
     */
    public static void sendAuctionWinnerNotifications(String artworkId, String artworkTitle, 
            String winnerId, String winnerName, java.math.BigDecimal winningBidAmount, String sellerId) {
        try {
            logger.info("Sending auction winner notifications for artwork: " + artworkId);
            
            // Send notification to winner
            sendWinnerNotification(winnerId, artworkId, artworkTitle, winningBidAmount);
            
            // Send notification to seller
            sendAuctionEndedSellerNotification(sellerId, artworkId, artworkTitle, winnerName, winningBidAmount);
            
            logger.info("Auction winner notifications sent successfully for artwork: " + artworkId);
            
        } catch (Exception e) {
            logger.severe("Error sending auction winner notifications: " + e.getMessage());
            e.printStackTrace();
            // Don't throw - notifications are non-critical
        }
    }
    
    /**
     * Send auction win notification to the winning bidder
     */
    private static void sendWinnerNotification(String winnerId, String artworkId, String artworkTitle, 
            java.math.BigDecimal winningBidAmount) 
            throws ExecutionException, InterruptedException {
        try {
            String amountStr = winningBidAmount != null ? String.format("%.2f", winningBidAmount.doubleValue()) : "0.00";
            String content = "🎉 Congratulations! You have won the auction for \"" + artworkTitle + 
                            "\". Your winning bid was RM " + amountStr + ". Please proceed with payment within 24 hours to complete your purchase.";
            
            logger.info("Creating winner notification for user: " + winnerId);
            logger.info("Notification content: " + content);
            
            Message winnerMessage = new Message();
            winnerMessage.setSenderId("SYSTEM");
            winnerMessage.setReceiverId(winnerId);
            winnerMessage.setArtworkId(artworkId);
            winnerMessage.setContent(content);
            winnerMessage.setMessageType(Message.MessageType.PURCHASE_NOTIFICATION);
            winnerMessage.setRead(false);
            // Set timestamp as Date (MessageDAO expects Date)
            winnerMessage.setTimestamp(new java.util.Date());
            
            String messageId = messageDAO.createMessage(winnerMessage);
            logger.info("✓ Winner notification successfully created with ID: " + messageId);
            logger.info("  - Sent to user: " + winnerId);
            logger.info("  - Artwork: " + artworkId + " (" + artworkTitle + ")");
            logger.info("  - Winning bid: RM " + amountStr);
        } catch (Exception e) {
            logger.severe("✗ Error sending winner notification: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
    
    /**
     * Send auction ended notification to seller
     */
    private static void sendAuctionEndedSellerNotification(String sellerId, String artworkId, String artworkTitle, 
            String winnerName, java.math.BigDecimal winningBidAmount) 
            throws ExecutionException, InterruptedException {
        try {
            String amountStr = winningBidAmount != null ? String.format("%.2f", winningBidAmount.doubleValue()) : "0.00";
            String winnerDisplayName = (winnerName != null && !winnerName.trim().isEmpty()) ? winnerName : "a bidder";
            String content = "🏆 Your auction for \"" + artworkTitle + "\" has ended. " +
                            "Winner: " + winnerDisplayName + " | Winning Bid: RM " + amountStr + ". " +
                            "View the auction details in your dashboard.";
            
            logger.info("Creating seller notification for user: " + sellerId);
            logger.info("Notification content: " + content);
            
            Message sellerMessage = new Message();
            sellerMessage.setSenderId("SYSTEM");
            sellerMessage.setReceiverId(sellerId);
            sellerMessage.setArtworkId(artworkId);
            sellerMessage.setContent(content);
            sellerMessage.setMessageType(Message.MessageType.PURCHASE_NOTIFICATION);
            sellerMessage.setRead(false);
            // Set timestamp as Date (MessageDAO expects Date)
            sellerMessage.setTimestamp(new java.util.Date());
            
            String messageId = messageDAO.createMessage(sellerMessage);
            logger.info("✓ Seller notification successfully created with ID: " + messageId);
            logger.info("  - Sent to seller: " + sellerId);
            logger.info("  - Artwork: " + artworkId + " (" + artworkTitle + ")");
            logger.info("  - Winner: " + winnerDisplayName);
            logger.info("  - Winning bid: RM " + amountStr);
        } catch (Exception e) {
            logger.severe("✗ Error sending seller notification: " + e.getMessage());
            e.printStackTrace();
            throw e;
        }
    }
    
    /**
     * Send payment expired notification to seller
     * 
     * @param artworkId The ID of the artwork
     * @param artworkTitle The title of the artwork
     * @param buyerId The ID of the buyer who failed to pay
     * @param sellerId The ID of the seller
     */
    public static void sendPaymentExpiredNotification(String artworkId, String artworkTitle, 
            String buyerId, String sellerId) {
        try {
            logger.info("Sending payment expired notification for artwork: " + artworkId);
            
            String content = "⚠️ Payment expired for auction winner. The winner of \"" + artworkTitle + 
                            "\" did not complete payment within 24 hours. The artwork is now available again.";
            
            Message sellerMessage = new Message();
            sellerMessage.setSenderId("SYSTEM");
            sellerMessage.setReceiverId(sellerId);
            sellerMessage.setArtworkId(artworkId);
            sellerMessage.setContent(content);
            sellerMessage.setMessageType(Message.MessageType.PURCHASE_NOTIFICATION);
            sellerMessage.setRead(false);
            sellerMessage.setTimestamp(new java.util.Date());
            
            String messageId = messageDAO.createMessage(sellerMessage);
            logger.info("✓ Payment expired notification sent to seller: " + sellerId + " (message ID: " + messageId + ")");
            
        } catch (Exception e) {
            logger.severe("✗ Error sending payment expired notification: " + e.getMessage());
            e.printStackTrace();
            // Don't throw - notifications are non-critical
        }
    }
}

