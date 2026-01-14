package com.artexchange.util;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.PurchaseDAO;
import com.artexchange.dao.UserDAO;
import com.artexchange.model.Artwork;
import com.artexchange.model.Purchase;
import com.artexchange.model.User;
import com.artexchange.config.FirebaseConfig;
import com.google.cloud.firestore.Firestore;
import com.google.cloud.firestore.Query;
import com.google.cloud.firestore.QueryDocumentSnapshot;
import com.google.cloud.firestore.QuerySnapshot;
import com.google.api.core.ApiFuture;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;

/**
 * Utility class for processing auction end events
 */
public class AuctionProcessor {
    private static final Logger logger = Logger.getLogger(AuctionProcessor.class.getName());
    private static final ArtworkDAO artworkDAO = new ArtworkDAO();
    private static final PurchaseDAO purchaseDAO = new PurchaseDAO();
    private static final UserDAO userDAO = new UserDAO();
    
    /**
     * Process an ended auction: determine winner, update artwork, create purchase, send notifications
     */
    public static void processEndedAuction(String artworkId) {
        try {
            logger.info("Processing ended auction for artwork: " + artworkId);
            
            Artwork artwork = artworkDAO.findById(artworkId);
            if (artwork == null) {
                logger.warning("Artwork not found: " + artworkId);
                return;
            }
            
            // Check if already processed
            if (artwork.getWinnerId() != null && !artwork.getWinnerId().trim().isEmpty()) {
                logger.info("Auction " + artworkId + " already has a winner: " + artwork.getWinnerId());
                return;
            }
            
            // Get the highest bidder from bid_history
            Map<String, Object> winnerInfo = getHighestBidder(artworkId);
            
            String winnerId = null;
            String winnerName = null;
            BigDecimal winningBidAmount = null;
            
            if (winnerInfo != null && winnerInfo.get("bidderId") != null) {
                winnerId = (String) winnerInfo.get("bidderId");
                winnerName = (String) winnerInfo.get("bidderName");
                Object bidAmountObj = winnerInfo.get("bidAmount");
                
                if (bidAmountObj instanceof Number) {
                    winningBidAmount = BigDecimal.valueOf(((Number) bidAmountObj).doubleValue());
                } else if (bidAmountObj instanceof String) {
                    winningBidAmount = new BigDecimal((String) bidAmountObj);
                }
            } else {
                // Fallback to highestBidderId from artwork
                if (artwork.getHighestBidderId() != null && !artwork.getHighestBidderId().trim().isEmpty()) {
                    winnerId = artwork.getHighestBidderId();
                    winningBidAmount = artwork.getCurrentBid() != null ? artwork.getCurrentBid() : artwork.getStartingBid();
                    
                    // Get winner name
                    try {
                        User winner = userDAO.findById(winnerId);
                        if (winner != null) {
                            winnerName = winner.getDisplayName();
                        } else {
                            winnerName = "Unknown User";
                        }
                    } catch (Exception e) {
                        logger.warning("Could not fetch winner name: " + e.getMessage());
                        winnerName = "Unknown User";
                    }
                }
            }
            
            // Check if there's a valid winner
            if (winnerId == null || winnerId.trim().isEmpty()) {
                logger.info("Auction ended for artwork " + artworkId + " with no bids");
                artwork.setStatus(Artwork.ArtworkStatus.INACTIVE);
                artwork.setEndedAt(LocalDateTime.now());
                artworkDAO.updateArtwork(artwork);
                return;
            }
            
            // Update artwork with winner information using transaction
            boolean success = updateAuctionWithWinner(artworkId, winnerId, winnerName, winningBidAmount);
            
            if (!success) {
                logger.warning("Auction " + artworkId + " was already processed");
                return;
            }
            
            // Reload artwork to get updated information
            artwork = artworkDAO.findById(artworkId);
            
            // Create purchase record with PENDING_PAYMENT status
            String purchaseId = null;
            try {
                Purchase purchase = new Purchase(
                    artworkId,
                    winnerId,
                    artwork.getArtistId(),
                    winningBidAmount
                );
                
                // Set status to PENDING_PAYMENT - winner has 24 hours to pay
                purchase.setStatus("PENDING_PAYMENT");
                purchase.setPaymentMethod("AUCTION_WIN");
                purchase.setTransactionId("AUCTION_" + artworkId + "_" + System.currentTimeMillis());
                purchase.setNotes("Auction win - Final bid: " + winningBidAmount);
                // Set purchase date explicitly
                purchase.setPurchaseDate(LocalDateTime.now());
                
                // Set payment deadline to 24 hours from now
                LocalDateTime paymentDeadline = LocalDateTime.now().plusHours(24);
                purchase.setPaymentDeadline(paymentDeadline);
                purchase.setPaymentExpired(false);
                
                purchaseId = purchaseDAO.savePurchase(purchase);
                logger.info("✓ Purchase record created for auction win: " + purchaseId + " (artwork: " + artworkId + ", buyer: " + winnerId + ", amount: " + winningBidAmount + ", payment deadline: " + paymentDeadline + ")");
                
            } catch (Exception e) {
                logger.severe("✗ Error creating purchase record for auction win: " + e.getMessage());
                e.printStackTrace();
                // Continue even if purchase creation fails - we still want to try notifications
            }
            
            // Send notifications - do this AFTER purchase is created
            try {
                logger.info("=== Sending auction winner notifications ===");
                logger.info("Artwork ID: " + artworkId);
                logger.info("Artwork Title: " + artwork.getTitle());
                logger.info("Winner ID: " + winnerId);
                logger.info("Winner Name: " + winnerName);
                logger.info("Winning Bid Amount: " + winningBidAmount);
                logger.info("Seller ID: " + artwork.getArtistId());
                
                NotificationUtil.sendAuctionWinnerNotifications(
                    artworkId,
                    artwork.getTitle(),
                    winnerId,
                    winnerName,
                    winningBidAmount,
                    artwork.getArtistId()
                );
                logger.info("✓✓✓ Auction winner notifications successfully sent for artwork: " + artworkId);
            } catch (Exception e) {
                logger.severe("✗✗✗ FAILED to send auction winner notifications: " + e.getMessage());
                e.printStackTrace();
                // Don't throw - notifications are non-critical but log the error
            }
            
            logger.info("Successfully processed auction end for artwork: " + artworkId + " - Winner: " + winnerName + " (" + winnerId + ") - Amount: " + winningBidAmount);
            
        } catch (Exception e) {
            logger.severe("Error processing ended auction: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Get the highest bidder from bid_history collection
     */
    private static Map<String, Object> getHighestBidder(String artworkId) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            Query query = db.collection("bid_history")
                    .whereEqualTo("auctionId", artworkId);
            
            ApiFuture<QuerySnapshot> future = query.get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            
            if (documents.isEmpty()) {
                logger.info("No bids found in bid_history for auction: " + artworkId);
                return null;
            }
            
            // Find the highest bid
            Map<String, Object> highestBid = null;
            double maxAmount = 0.0;
            
            for (QueryDocumentSnapshot doc : documents) {
                Map<String, Object> bidData = doc.getData();
                Object bidAmountObj = bidData.get("bidAmount");
                
                double bidAmount = 0.0;
                if (bidAmountObj instanceof Number) {
                    bidAmount = ((Number) bidAmountObj).doubleValue();
                } else if (bidAmountObj instanceof String) {
                    try {
                        bidAmount = Double.parseDouble((String) bidAmountObj);
                    } catch (NumberFormatException e) {
                        continue;
                    }
                }
                
                if (bidAmount > maxAmount) {
                    maxAmount = bidAmount;
                    highestBid = new HashMap<>();
                    highestBid.put("bidderId", bidData.get("bidderId"));
                    highestBid.put("bidderName", bidData.get("bidderName"));
                    highestBid.put("bidAmount", bidAmount);
                }
            }
            
            return highestBid;
            
        } catch (Exception e) {
            logger.warning("Error getting highest bidder: " + e.getMessage());
            e.printStackTrace();
            return null;
        }
    }
    
    /**
     * Atomically update artwork with winner information using a transaction
     */
    private static boolean updateAuctionWithWinner(String artworkId, String winnerId, String winnerName, BigDecimal winningBidAmount) {
        try {
            Firestore db = FirebaseConfig.getFirestore();
            com.google.cloud.firestore.DocumentReference artworkRef = db.collection("artworks").document(artworkId);
            
            return db.runTransaction(transaction -> {
                try {
                    com.google.cloud.firestore.DocumentSnapshot artworkDoc = transaction.get(artworkRef).get();
                    
                    if (!artworkDoc.exists()) {
                        throw new RuntimeException("Artwork not found: " + artworkId);
                    }
                    
                    // Check if winner is already set
                    String existingWinnerId = artworkDoc.getString("winnerId");
                    if (existingWinnerId != null && !existingWinnerId.trim().isEmpty()) {
                        logger.warning("Auction " + artworkId + " already has a winner: " + existingWinnerId);
                        return false;
                    }
                    
                    // Update artwork with winner information
                    LocalDateTime now = LocalDateTime.now();
                    Map<String, Object> updates = new HashMap<>();
                    updates.put("status", "SOLD");
                    updates.put("winnerId", winnerId);
                    updates.put("winnerName", winnerName);
                    updates.put("winningBidAmount", winningBidAmount != null ? winningBidAmount.toString() : null);
                    updates.put("endedAt", now.toString());
                    updates.put("soldAt", now.toString());
                    updates.put("updatedAt", now.toString());
                    
                    transaction.update(artworkRef, updates);
                    logger.info("Artwork " + artworkId + " updated with winner information in transaction");
                    return true;
                    
                } catch (InterruptedException | ExecutionException e) {
                    Thread.currentThread().interrupt();
                    throw new RuntimeException("Error in transaction: " + e.getMessage(), e);
                }
            }).get();
            
        } catch (Exception e) {
            logger.severe("Error updating auction with winner: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
    
    /**
     * Process all ended auctions that haven't been processed yet
     */
    public static void processAllEndedAuctions() {
        try {
            logger.info("=== Starting processAllEndedAuctions ===");
            
            Firestore db = FirebaseConfig.getFirestore();
            LocalDateTime now = LocalDateTime.now();
            
            // Get all active auctions first, then filter in memory
            // (Firestore string comparison can be tricky with dates)
            Query query = db.collection("artworks")
                    .whereEqualTo("saleType", "AUCTION")
                    .whereEqualTo("status", "ACTIVE");
            
            ApiFuture<QuerySnapshot> future = query.get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            
            logger.info("Found " + documents.size() + " active auctions to check");
            
            int processedCount = 0;
            for (QueryDocumentSnapshot doc : documents) {
                try {
                    String artworkId = doc.getId();
                    String auctionEndTimeStr = doc.getString("auctionEndTime");
                    
                    if (auctionEndTimeStr == null || auctionEndTimeStr.trim().isEmpty()) {
                        logger.warning("Auction " + artworkId + " has no auctionEndTime");
                        continue;
                    }
                    
                    // Parse end time and check if it's in the past
                    LocalDateTime auctionEndTime = LocalDateTime.parse(auctionEndTimeStr);
                    if (auctionEndTime.isAfter(now)) {
                        // Auction hasn't ended yet
                        continue;
                    }
                    
                    // Auction has ended - check if already processed
                    String winnerId = doc.getString("winnerId");
                    if (winnerId == null || winnerId.trim().isEmpty()) {
                        logger.info("Processing ended auction: " + artworkId + " (ended at: " + auctionEndTimeStr + ")");
                        processEndedAuction(artworkId);
                        processedCount++;
                    } else {
                        logger.info("Auction " + artworkId + " already processed (has winner: " + winnerId + ")");
                    }
                } catch (Exception e) {
                    logger.severe("Error processing auction " + doc.getId() + ": " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            logger.info("=== Finished processing ended auctions. Processed: " + processedCount + " ===");
            
        } catch (Exception e) {
            logger.severe("Error processing all ended auctions: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    /**
     * Process expired payments for auction wins
     * Checks all PENDING_PAYMENT purchases and marks them as expired if deadline passed
     */
    public static void processExpiredPayments() {
        try {
            logger.info("=== Starting processExpiredPayments ===");
            
            List<Purchase> pendingPurchases = purchaseDAO.findPendingPaymentPurchases();
            logger.info("Found " + pendingPurchases.size() + " pending payment purchases to check");
            
            LocalDateTime now = LocalDateTime.now();
            int expiredCount = 0;
            
            for (Purchase purchase : pendingPurchases) {
                try {
                    // Check if payment deadline has passed
                    if (purchase.getPaymentDeadline() != null && 
                        purchase.getPaymentDeadline().isBefore(now) &&
                        !purchase.isPaymentExpired()) {
                        
                        logger.info("Payment expired for purchase: " + purchase.getPurchaseId() + 
                                   " (deadline: " + purchase.getPaymentDeadline() + ", now: " + now + ")");
                        
                        // Mark payment as expired
                        purchaseDAO.markPaymentAsExpired(purchase.getPurchaseId());
                        
                        // Update artwork status - make it available again or mark as expired
                        Artwork artwork = artworkDAO.findById(purchase.getArtworkId());
                        if (artwork != null) {
                            // Set artwork status to INACTIVE since payment failed
                            artwork.setStatus(Artwork.ArtworkStatus.INACTIVE);
                            artwork.setWinnerId(null);
                            artwork.setWinnerName(null);
                            artwork.setWinningBidAmount(null);
                            artwork.setSoldAt(null); // Clear soldAt since payment failed
                            artworkDAO.updateArtwork(artwork);
                            
                            logger.info("Artwork " + purchase.getArtworkId() + " marked as INACTIVE due to expired payment");
                            
                            // Notify seller that payment expired
                            try {
                                NotificationUtil.sendPaymentExpiredNotification(
                                    purchase.getArtworkId(),
                                    artwork.getTitle(),
                                    purchase.getBuyerId(),
                                    purchase.getSellerId()
                                );
                            } catch (Exception e) {
                                logger.warning("Failed to send payment expired notification: " + e.getMessage());
                            }
                        }
                        
                        expiredCount++;
                    }
                } catch (Exception e) {
                    logger.severe("Error processing expired payment for purchase " + purchase.getPurchaseId() + ": " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            logger.info("=== Finished processing expired payments. Expired: " + expiredCount + " ===");
            
        } catch (Exception e) {
            logger.severe("Error processing expired payments: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

