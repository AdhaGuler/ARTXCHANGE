package com.artexchange.websocket;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.util.AuctionProcessor;
import com.artexchange.model.Artwork;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;
import java.io.IOException;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.logging.Logger;

@ServerEndpoint("/auction/{artworkId}")
public class AuctionWebSocket {
    private static final Logger logger = Logger.getLogger(AuctionWebSocket.class.getName());
    private static final ConcurrentHashMap<String, ConcurrentHashMap<String, Session>> auctionSessions = new ConcurrentHashMap<>();
    private static final ScheduledExecutorService scheduler = Executors.newScheduledThreadPool(10);
    private static final Gson gson = new Gson();
    private static final ArtworkDAO artworkDAO = new ArtworkDAO();
    
    @OnOpen
    public void onOpen(Session session, @PathParam("artworkId") String artworkId) {
        // Add session to artwork's auction room
        auctionSessions.computeIfAbsent(artworkId, k -> new ConcurrentHashMap<>())
                      .put(session.getId(), session);
        
        logger.info("User joined auction for artwork: " + artworkId);
        
        try {
            // Send current auction status
            sendAuctionStatus(artworkId, session);
            
            // Start timer updates for this auction if not already running
            startAuctionTimer(artworkId);
            
        } catch (Exception e) {
            logger.severe("Error on auction WebSocket open: " + e.getMessage());
        }
    }
    
    @OnMessage
    public void onMessage(String message, Session session, @PathParam("artworkId") String artworkId) {
        try {
            JsonObject messageJson = gson.fromJson(message, JsonObject.class);
            String type = messageJson.get("type").getAsString();
            
            switch (type) {
                case "place_bid":
                    handlePlaceBid(messageJson, artworkId, session);
                    break;
                case "get_status":
                    sendAuctionStatus(artworkId, session);
                    break;
                default:
                    logger.warning("Unknown auction message type: " + type);
            }
            
        } catch (Exception e) {
            logger.severe("Error processing auction message: " + e.getMessage());
        }
    }
    
    @OnClose
    public void onClose(Session session, @PathParam("artworkId") String artworkId) {
        ConcurrentHashMap<String, Session> artworkSessions = auctionSessions.get(artworkId);
        if (artworkSessions != null) {
            artworkSessions.remove(session.getId());
            
            // If no more sessions for this artwork, clean up
            if (artworkSessions.isEmpty()) {
                auctionSessions.remove(artworkId);
            }
        }
        
        logger.info("User left auction for artwork: " + artworkId);
    }
    
    @OnError
    public void onError(Session session, Throwable throwable) {
        logger.severe("Auction WebSocket error: " + throwable.getMessage());
    }
    
    private void handlePlaceBid(JsonObject messageJson, String artworkId, Session session) {
        try {
            double bidAmount = messageJson.get("bidAmount").getAsDouble();
            String bidderId = messageJson.get("bidderId").getAsString();
            
            // Get current artwork
            Artwork artwork = artworkDAO.findById(artworkId);
            if (artwork == null) {
                sendErrorToSession(session, "Artwork not found");
                return;
            }
            
            // Validate bid
            if (artwork.getSaleType() != Artwork.SaleType.AUCTION) {
                sendErrorToSession(session, "This artwork is not for auction");
                return;
            }
            
            if (artwork.getAuctionEndTime().isBefore(java.time.LocalDateTime.now())) {
                sendErrorToSession(session, "Auction has ended");
                return;
            }
            
            java.math.BigDecimal currentBid = artwork.getCurrentBid() != null ? artwork.getCurrentBid() : artwork.getStartingBid();
            if (java.math.BigDecimal.valueOf(bidAmount).compareTo(currentBid) <= 0) {
                sendErrorToSession(session, "Bid must be higher than current bid");
                return;
            }
            
            // Update artwork with new bid
            artwork.setCurrentBid(java.math.BigDecimal.valueOf(bidAmount));
            artwork.setHighestBidderId(bidderId);
            artworkDAO.updateArtwork(artwork);
            
            // Broadcast bid update to all participants
            broadcastBidUpdate(artworkId, artwork, bidderId, bidAmount);
            
            logger.info("New bid placed: " + bidAmount + " for artwork " + artworkId);
            
        } catch (Exception e) {
            logger.severe("Error handling bid: " + e.getMessage());
            sendErrorToSession(session, "Error processing bid");
        }
    }
    
    private void sendAuctionStatus(String artworkId, Session session) {
        try {
            Artwork artwork = artworkDAO.findById(artworkId);
            if (artwork == null) {
                sendErrorToSession(session, "Artwork not found");
                return;
            }
            
            JsonObject status = createAuctionStatusMessage(artwork);
            session.getBasicRemote().sendText(gson.toJson(status));
            
        } catch (Exception e) {
            logger.severe("Error sending auction status: " + e.getMessage());
        }
    }
    
    private void broadcastBidUpdate(String artworkId, Artwork artwork, String bidderId, double bidAmount) {
        ConcurrentHashMap<String, Session> sessions = auctionSessions.get(artworkId);
        if (sessions == null) return;
        
        JsonObject bidUpdate = new JsonObject();
        bidUpdate.addProperty("type", "bid_update");
        bidUpdate.addProperty("artworkId", artworkId);
        bidUpdate.addProperty("newBid", bidAmount);
        bidUpdate.addProperty("bidderId", bidderId);
        bidUpdate.addProperty("currentPrice", artwork.getCurrentBid() != null ? artwork.getCurrentBid().doubleValue() : 0.0);
        bidUpdate.addProperty("timeRemaining", getTimeRemaining(artwork.getAuctionEndTime()));
        
        String message = gson.toJson(bidUpdate);
        
        sessions.values().forEach(session -> {
            if (session.isOpen()) {
                try {
                    session.getBasicRemote().sendText(message);
                } catch (IOException e) {
                    logger.warning("Failed to send bid update to session: " + e.getMessage());
                }
            }
        });
    }
    
    private void startAuctionTimer(String artworkId) {
        // Check if timer is already running for this auction
        if (isTimerRunning(artworkId)) {
            return;
        }
        
        scheduler.scheduleAtFixedRate(() -> {
            try {
                Artwork artwork = artworkDAO.findById(artworkId);
                if (artwork == null) return;
                
                long timeRemaining = getTimeRemaining(artwork.getAuctionEndTime());
                
                if (timeRemaining <= 0) {
                    // Auction ended - use AuctionProcessor to handle it
                    AuctionProcessor.processEndedAuction(artworkId);
                    return;
                }
                
                // Send timer update
                broadcastTimerUpdate(artworkId, timeRemaining, artwork);
                
            } catch (Exception e) {
                logger.severe("Error in auction timer: " + e.getMessage());
            }
        }, 0, 1, TimeUnit.SECONDS);
    }
    
    private void broadcastTimerUpdate(String artworkId, long timeRemaining, Artwork artwork) {
        ConcurrentHashMap<String, Session> sessions = auctionSessions.get(artworkId);
        if (sessions == null) return;
        
        JsonObject timerUpdate = new JsonObject();
        timerUpdate.addProperty("type", "timer_update");
        timerUpdate.addProperty("artworkId", artworkId);
        timerUpdate.addProperty("timeRemaining", timeRemaining);
        timerUpdate.addProperty("currentPrice", artwork.getCurrentBid() != null ? artwork.getCurrentBid().doubleValue() : 0.0);
        timerUpdate.addProperty("highestBidderId", artwork.getHighestBidderId());
        
        String message = gson.toJson(timerUpdate);
        
        sessions.values().forEach(session -> {
            if (session.isOpen()) {
                try {
                    session.getBasicRemote().sendText(message);
                } catch (IOException e) {
                    logger.warning("Failed to send timer update to session: " + e.getMessage());
                }
            }
        });
    }
    
    private JsonObject createAuctionStatusMessage(Artwork artwork) {
        JsonObject status = new JsonObject();
        status.addProperty("type", "auction_status");
        status.addProperty("artworkId", artwork.getArtworkId());
        status.addProperty("currentPrice", artwork.getCurrentBid() != null ? artwork.getCurrentBid().doubleValue() : 0.0);
        status.addProperty("startingPrice", artwork.getStartingBid() != null ? artwork.getStartingBid().doubleValue() : 0.0);
        status.addProperty("highestBidderId", artwork.getHighestBidderId());
        status.addProperty("timeRemaining", getTimeRemaining(artwork.getAuctionEndTime()));
        status.addProperty("isActive", artwork.getAuctionEndTime().isAfter(java.time.LocalDateTime.now()));
        
        return status;
    }
    
    private long getTimeRemaining(java.time.LocalDateTime endTime) {
        if (endTime == null) return 0;
        return Math.max(0, java.time.Duration.between(java.time.LocalDateTime.now(), endTime).toMillis());
    }
    
    private boolean isTimerRunning(String artworkId) {
        // Simple check - in a real implementation, you'd track running timers
        return auctionSessions.containsKey(artworkId);
    }
    
    private void sendErrorToSession(Session session, String error) {
        try {
            JsonObject errorMessage = new JsonObject();
            errorMessage.addProperty("type", "error");
            errorMessage.addProperty("message", error);
            
            session.getBasicRemote().sendText(gson.toJson(errorMessage));
        } catch (IOException e) {
            logger.severe("Failed to send error message: " + e.getMessage());
        }
    }
}
