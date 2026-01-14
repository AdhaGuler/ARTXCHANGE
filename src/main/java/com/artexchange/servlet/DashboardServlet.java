package com.artexchange.servlet;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.PurchaseDAO;
import com.artexchange.dao.UserDAO;
import com.artexchange.util.SessionUtil;
import com.artexchange.util.GsonUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;
import java.util.logging.Logger;

@WebServlet("/api/dashboard/*")
public class DashboardServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(DashboardServlet.class.getName());
    private final Gson gson = GsonUtil.getGson();
    private final ArtworkDAO artworkDAO = new ArtworkDAO();
    private final PurchaseDAO purchaseDAO = new PurchaseDAO();
    private final UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Check authentication
        String currentUserId = SessionUtil.getCurrentUserId(request);
        // #region agent log
        try {
            java.io.FileWriter fw = new java.io.FileWriter("d:\\1. UniKL\\fyp\\artexchange\\.cursor\\debug.log", true);
            fw.write("{\"id\":\"log_" + System.currentTimeMillis() + "\",\"timestamp\":" + System.currentTimeMillis() + ",\"location\":\"DashboardServlet.java:34\",\"message\":\"getCurrentUserId called\",\"data\":{\"userId\":" + (currentUserId != null ? "\"" + currentUserId + "\"" : "null") + "},\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"A\"}\n");
            fw.close();
        } catch (Exception e) {}
        // #endregion
        if (currentUserId == null) {
            // #region agent log
            try {
                java.io.FileWriter fw = new java.io.FileWriter("d:\\1. UniKL\\fyp\\artexchange\\.cursor\\debug.log", true);
                fw.write("{\"id\":\"log_" + System.currentTimeMillis() + "\",\"timestamp\":" + System.currentTimeMillis() + ",\"location\":\"DashboardServlet.java:36\",\"message\":\"401 Unauthorized - userId is null\",\"data\":{},\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"A\"}\n");
                fw.close();
            } catch (Exception e) {}
            // #endregion
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Authentication required");
            response.getWriter().write(gson.toJson(error));
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo != null && pathInfo.equals("/stats")) {
                handleGetDashboardStats(request, response, currentUserId);
            } else if (pathInfo != null && pathInfo.equals("/seller")) {
                handleGetSellerDashboard(request, response, currentUserId);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                JsonObject error = new JsonObject();
                error.addProperty("error", "Endpoint not found");
                response.getWriter().write(gson.toJson(error));
            }
        } catch (Exception e) {
            logger.severe("Error in DashboardServlet: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Internal server error");
            response.getWriter().write(gson.toJson(error));
        }
    }
    
    private void handleGetDashboardStats(HttpServletRequest request, HttpServletResponse response, String userId)
            throws Exception {
        
        JsonObject stats = new JsonObject();
        
        // Get user's role to determine appropriate bid count
        String userRole = SessionUtil.getCurrentUserRole(request);
        logger.info("=== Getting dashboard stats for user: " + userId + " with role: " + userRole + " ===");
        
        // Get user's artworks count (if artist)
        try {
            long artworkCount = artworkDAO.getUserArtworkCount(userId);
            stats.addProperty("totalArtworks", artworkCount);
        } catch (Exception e) {
            stats.addProperty("totalArtworks", 0);
        }
        
        // Get user's purchases count
        // For artists: count sales (purchases of their artworks)
        // For buyers: count purchases they made
        try {
            long purchaseCount = 0;
            if ("ARTIST".equals(userRole)) {
                purchaseCount = purchaseDAO.getUserSalesCount(userId);
            } else {
                purchaseCount = purchaseDAO.getUserPurchaseCount(userId);
            }
            stats.addProperty("totalPurchases", purchaseCount);
        } catch (Exception e) {
            logger.warning("Error getting purchase count: " + e.getMessage());
            stats.addProperty("totalPurchases", 0);
        }
        
        // Get bid count based on user role
        try {
            long bidCount = 0;
            
            if ("ARTIST".equals(userRole)) {
                // For artists: show bids received on their artworks
                logger.info("Getting bids received on artist's artworks for user: " + userId);
                bidCount = artworkDAO.getArtistReceivedBidsCount(userId);
                logger.info("Artist received bids count: " + bidCount);
            } else {
                // For buyers/collectors: show bids they placed
                logger.info("Getting bids placed by user: " + userId);
                bidCount = artworkDAO.getUserTotalBidsCount(userId);
                logger.info("User placed bids count: " + bidCount);
            }
            
            stats.addProperty("activeBids", bidCount);
        } catch (Exception e) {
            logger.severe("Error getting bid count: " + e.getMessage());
            stats.addProperty("activeBids", 0);
        }
        
        // Get total earnings (if artist)
        try {
            if ("ARTIST".equals(userRole)) {
                java.math.BigDecimal totalEarnings = purchaseDAO.getUserTotalEarnings(userId);
                stats.addProperty("totalEarnings", totalEarnings.doubleValue());
            } else {
                stats.addProperty("totalEarnings", 0.0);
            }
        } catch (Exception e) {
            logger.warning("Error getting total earnings: " + e.getMessage());
            stats.addProperty("totalEarnings", 0.0);
        }
        
        // Get total likes received
        try {
            long totalLikes = artworkDAO.getUserTotalLikes(userId);
            stats.addProperty("totalLikes", totalLikes);
        } catch (Exception e) {
            stats.addProperty("totalLikes", 0);
        }
        
        // Get profile views (placeholder - implement based on analytics needs)
        stats.addProperty("profileViews", 124);
        
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", true);
        jsonResponse.add("stats", stats);
        
        logger.info("=== Final dashboard response ===");
        logger.info("Response JSON: " + gson.toJson(jsonResponse));
        logger.info("Stats object: " + gson.toJson(stats));
        logger.info("Stats activeBids property: " + stats.get("activeBids"));
        
        // #region agent log
        try {
            java.io.FileWriter fw = new java.io.FileWriter("d:\\1. UniKL\\fyp\\artexchange\\.cursor\\debug.log", true);
            fw.write("{\"id\":\"log_" + System.currentTimeMillis() + "\",\"timestamp\":" + System.currentTimeMillis() + ",\"location\":\"DashboardServlet.java:140\",\"message\":\"Sending dashboard stats response\",\"data\":{\"success\":true,\"hasStats\":true,\"statsKeys\":[\"totalArtworks\",\"totalPurchases\",\"activeBids\",\"totalEarnings\",\"totalLikes\"]},\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"D\"}\n");
            fw.close();
        } catch (Exception e) {}
        // #endregion
        
        response.getWriter().write(gson.toJson(jsonResponse));
    }
    
    /**
     * Get seller/artist dashboard data including active auctions with bidder counts
     */
    private void handleGetSellerDashboard(HttpServletRequest request, HttpServletResponse response, String userId)
            throws Exception {
        
        String userRole = SessionUtil.getCurrentUserRole(request);
        logger.info("=== Getting seller dashboard for user: " + userId + " with role: " + userRole + " ===");
        
        // Verify user is an artist
        if (!"ARTIST".equals(userRole)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            JsonObject error = new JsonObject();
            error.addProperty("error", "This endpoint is only available for artists");
            response.getWriter().write(gson.toJson(error));
            return;
        }
        
        JsonObject dashboardData = new JsonObject();
        
        // Get total likes received
        try {
            long likesCount = artworkDAO.getUserTotalLikes(userId);
            dashboardData.addProperty("likesCount", likesCount);
            logger.info("Likes count: " + likesCount);
        } catch (Exception e) {
            logger.severe("Error getting likes count: " + e.getMessage());
            dashboardData.addProperty("likesCount", 0);
        }
        
        // Get total purchases (purchases of artist's artworks)
        try {
            // Count purchases where sellerId = userId (sales made by this artist)
            long purchasesCount = purchaseDAO.getUserSalesCount(userId);
            dashboardData.addProperty("purchasesCount", purchasesCount);
            logger.info("Purchases count (sales): " + purchasesCount);
        } catch (Exception e) {
            logger.severe("Error getting purchases count: " + e.getMessage());
            dashboardData.addProperty("purchasesCount", 0);
        }
        
        // Get active and ended auctions with bidder counts and winner information
        try {
            // First, try a direct query for auctions to ensure we get all of them
            List<com.artexchange.model.Artwork> artistArtworks = artworkDAO.findArtworksByArtist(userId, 1, 1000); // Increased limit to get all artworks
            logger.info("Found " + artistArtworks.size() + " total artworks for artist " + userId);
            
            // Also log how many are auctions
            long auctionCount = artistArtworks.stream()
                .filter(a -> a.getSaleType() != null && a.getSaleType() == com.artexchange.model.Artwork.SaleType.AUCTION)
                .count();
            logger.info("Found " + auctionCount + " artworks with saleType=AUCTION");
            
            long activeAuctionCount = artistArtworks.stream()
                .filter(a -> a.getSaleType() != null && a.getSaleType() == com.artexchange.model.Artwork.SaleType.AUCTION
                          && a.getStatus() != null && a.getStatus() == com.artexchange.model.Artwork.ArtworkStatus.ACTIVE)
                .count();
            logger.info("Found " + activeAuctionCount + " artworks with saleType=AUCTION and status=ACTIVE");
            
            com.google.gson.JsonArray auctionsArray = new com.google.gson.JsonArray();
            
            for (com.artexchange.model.Artwork artwork : artistArtworks) {
                // Log each artwork for debugging
                logger.info("Checking artwork: " + artwork.getArtworkId() + 
                           ", Title: " + artwork.getTitle() + 
                           ", SaleType: " + (artwork.getSaleType() != null ? artwork.getSaleType().toString() : "null") +
                           ", Status: " + (artwork.getStatus() != null ? artwork.getStatus().toString() : "null"));
                
                // Include both active and sold (ended) auctions
                // Use null-safe comparison
                boolean isAuction = artwork.getSaleType() != null && 
                                   artwork.getSaleType() == com.artexchange.model.Artwork.SaleType.AUCTION;
                boolean isActiveOrSold = artwork.getStatus() != null && 
                                        (artwork.getStatus() == com.artexchange.model.Artwork.ArtworkStatus.ACTIVE 
                                         || artwork.getStatus() == com.artexchange.model.Artwork.ArtworkStatus.SOLD);
                
                if (isAuction && isActiveOrSold) {
                    logger.info("Found auction artwork: " + artwork.getArtworkId() + " with status: " + artwork.getStatus());
                    
                    // Get unique bidder count for this auction
                    long biddersCount = 0;
                    try {
                        com.google.cloud.firestore.Query bidQuery = com.artexchange.config.FirebaseConfig.getFirestore()
                            .collection("bid_history")
                            .whereEqualTo("auctionId", artwork.getArtworkId());
                        com.google.cloud.firestore.QuerySnapshot bidSnapshot = bidQuery.get().get();
                        
                        // Count unique bidders
                        java.util.Set<String> uniqueBidders = new java.util.HashSet<>();
                        for (com.google.cloud.firestore.QueryDocumentSnapshot doc : bidSnapshot.getDocuments()) {
                            String bidderId = doc.getString("bidderId");
                            if (bidderId != null && !bidderId.trim().isEmpty()) {
                                uniqueBidders.add(bidderId);
                            }
                        }
                        biddersCount = uniqueBidders.size();
                    } catch (Exception e) {
                        logger.warning("Error getting bidder count for artwork " + artwork.getArtworkId() + ": " + e.getMessage());
                    }
                    
                    com.google.gson.JsonObject auctionObj = new com.google.gson.JsonObject();
                    auctionObj.addProperty("auctionId", artwork.getArtworkId());
                    auctionObj.addProperty("artworkTitle", artwork.getTitle());
                    auctionObj.addProperty("currentBid", artwork.getCurrentBid() != null ? artwork.getCurrentBid().doubleValue() : 0.0);
                    auctionObj.addProperty("biddersCount", biddersCount);
                    Integer bidCount = artwork.getBidCount();
                    auctionObj.addProperty("bidCount", bidCount != null ? bidCount.intValue() : 0);
                    auctionObj.addProperty("status", artwork.getStatus().toString());
                    
                    // Add winner information if auction has ended (SOLD status)
                    if (artwork.getStatus() == com.artexchange.model.Artwork.ArtworkStatus.SOLD) {
                        // Check if there's a winner
                        if (artwork.getWinnerId() != null && !artwork.getWinnerId().trim().isEmpty()) {
                            auctionObj.addProperty("winnerId", artwork.getWinnerId());
                            auctionObj.addProperty("winnerName", artwork.getWinnerName() != null ? artwork.getWinnerName() : "Unknown");
                            if (artwork.getWinningBidAmount() != null) {
                                auctionObj.addProperty("winningBidAmount", artwork.getWinningBidAmount().doubleValue());
                            }
                            auctionObj.addProperty("hasWinner", true);
                        } else {
                            // Auction ended but no winner (no bids)
                            auctionObj.addProperty("hasWinner", false);
                        }
                        // Always include endedAt if available
                        if (artwork.getEndedAt() != null) {
                            auctionObj.addProperty("endedAt", artwork.getEndedAt().toString());
                        }
                    } else {
                        // Active auction - no winner yet
                        auctionObj.addProperty("hasWinner", false);
                    }
                    
                    auctionsArray.add(auctionObj);
                }
            }
            
            dashboardData.add("auctions", auctionsArray);
            logger.info("Found " + auctionsArray.size() + " auctions (active + ended) for artist " + userId);
        } catch (Exception e) {
            logger.severe("Error getting auctions: " + e.getMessage());
            e.printStackTrace();
            dashboardData.add("auctions", new com.google.gson.JsonArray());
        }
        
        JsonObject jsonResponse = new JsonObject();
        jsonResponse.addProperty("success", true);
        jsonResponse.add("data", dashboardData);
        
        logger.info("=== Seller dashboard response ===");
        logger.info("Response JSON: " + gson.toJson(jsonResponse));
        
        // #region agent log
        try {
            java.io.FileWriter fw = new java.io.FileWriter("d:\\1. UniKL\\fyp\\artexchange\\.cursor\\debug.log", true);
            fw.write("{\"id\":\"log_" + System.currentTimeMillis() + "\",\"timestamp\":" + System.currentTimeMillis() + ",\"location\":\"DashboardServlet.java:231\",\"message\":\"Sending seller dashboard response\",\"data\":{\"success\":true,\"hasData\":true,\"auctionsCount\":" + dashboardData.get("auctions").getAsJsonArray().size() + "},\"sessionId\":\"debug-session\",\"runId\":\"run1\",\"hypothesisId\":\"D\"}\n");
            fw.close();
        } catch (Exception e) {}
        // #endregion
        
        response.getWriter().write(gson.toJson(jsonResponse));
    }
}
