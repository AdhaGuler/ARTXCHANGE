package com.artexchange.servlet;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.PurchaseDAO;
import com.artexchange.dao.UserDAO;
import com.artexchange.model.Artwork;
import com.artexchange.model.Purchase;
import com.artexchange.model.User;
import com.artexchange.util.SessionUtil;
import com.artexchange.util.GsonUtil;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;
import java.util.stream.Collectors;

@WebServlet("/api/sales-report")
public class SalesReportServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(SalesReportServlet.class.getName());
    private final Gson gson = GsonUtil.getGson();
    private final PurchaseDAO purchaseDAO = new PurchaseDAO();
    private final ArtworkDAO artworkDAO = new ArtworkDAO();
    private final UserDAO userDAO = new UserDAO();
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Check authentication
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Authentication required");
            response.getWriter().write(gson.toJson(error));
            return;
        }
        
        // Check if user is an artist
        String userRole = SessionUtil.getCurrentUserRole(request);
        if (!"ARTIST".equals(userRole)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            JsonObject error = new JsonObject();
            error.addProperty("error", "This endpoint is only available for artists");
            response.getWriter().write(gson.toJson(error));
            return;
        }
        
        try {
            // Get date range parameters
            String startDateParam = request.getParameter("startDate");
            String endDateParam = request.getParameter("endDate");
            
            LocalDateTime startDate = null;
            LocalDateTime endDate = null;
            
            if (startDateParam != null && !startDateParam.isEmpty()) {
                try {
                    startDate = LocalDateTime.parse(startDateParam + "T00:00:00");
                } catch (Exception e) {
                    logger.warning("Invalid startDate format: " + startDateParam);
                }
            }
            
            if (endDateParam != null && !endDateParam.isEmpty()) {
                try {
                    endDate = LocalDateTime.parse(endDateParam + "T23:59:59");
                } catch (Exception e) {
                    logger.warning("Invalid endDate format: " + endDateParam);
                }
            }
            
            // Get sales report data
            JsonObject reportData = generateSalesReport(currentUserId, startDate, endDate);
            
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.add("data", reportData);
            
            response.getWriter().write(gson.toJson(jsonResponse));
            
        } catch (Exception e) {
            logger.severe("Error generating sales report for artist " + currentUserId + ": " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("error", "Error generating sales report. Please check server logs for details.");
            // Log full stack trace but don't expose it to client
            response.getWriter().write(gson.toJson(error));
        }
    }
    
    /**
     * Generate sales report for an artist
     */
    private JsonObject generateSalesReport(String artistId, LocalDateTime startDate, LocalDateTime endDate)
            throws ExecutionException, InterruptedException {
        
        JsonObject report = new JsonObject();
        
        // Get all purchases (direct sales) for this artist
        List<Purchase> allPurchases;
        try {
            allPurchases = purchaseDAO.findBySellerId(artistId);
            logger.info("Found " + allPurchases.size() + " purchases for artist " + artistId);
        } catch (Exception e) {
            logger.severe("Error fetching purchases for artist " + artistId + ": " + e.getMessage());
            e.printStackTrace();
            // Return empty list to allow report generation to continue
            allPurchases = new ArrayList<>();
        }
        
        // Filter by date range if provided
        List<Purchase> filteredPurchases = allPurchases.stream()
            .filter(p -> {
                if (p.getPurchaseDate() == null) return false;
                if (startDate != null && p.getPurchaseDate().isBefore(startDate)) return false;
                if (endDate != null && p.getPurchaseDate().isAfter(endDate)) return false;
                return "COMPLETED".equals(p.getStatus());
            })
            .collect(Collectors.toList());
        
        // Get all artworks by artist to find auction winners
        List<Artwork> allArtworks;
        try {
            allArtworks = artworkDAO.findArtworksByArtist(artistId, 1, 10000);
            logger.info("Found " + allArtworks.size() + " artworks for artist " + artistId);
        } catch (Exception e) {
            logger.severe("Error fetching artworks for artist " + artistId + ": " + e.getMessage());
            e.printStackTrace();
            // Return empty list to allow report generation to continue
            allArtworks = new ArrayList<>();
        }
        
        // Filter sold auction artworks with winners
        List<Artwork> soldAuctions = allArtworks.stream()
            .filter(a -> a.getStatus() == Artwork.ArtworkStatus.SOLD 
                      && a.getSaleType() == Artwork.SaleType.AUCTION
                      && a.getWinnerId() != null
                      && !a.getWinnerId().isEmpty())
            .filter(a -> {
                LocalDateTime saleDate = a.getEndedAt() != null ? a.getEndedAt() : 
                                       (a.getSoldAt() != null ? a.getSoldAt() : a.getUpdatedAt());
                if (saleDate == null) return false;
                if (startDate != null && saleDate.isBefore(startDate)) return false;
                if (endDate != null && saleDate.isAfter(endDate)) return false;
                return true;
            })
            .collect(Collectors.toList());
        
        // Build sales records list
        JsonArray salesRecords = new JsonArray();
        
        // Add direct purchases
        BigDecimal totalDirectSales = BigDecimal.ZERO;
        for (Purchase purchase : filteredPurchases) {
            try {
                JsonObject saleRecord = new JsonObject();
                saleRecord.addProperty("artworkId", purchase.getArtworkId() != null ? purchase.getArtworkId() : "");
                
                // Get artwork title
                try {
                    Artwork artwork = artworkDAO.findById(purchase.getArtworkId());
                    saleRecord.addProperty("artworkTitle", artwork != null && artwork.getTitle() != null ? artwork.getTitle() : "Unknown");
                } catch (Exception e) {
                    logger.warning("Error fetching artwork " + purchase.getArtworkId() + ": " + e.getMessage());
                    saleRecord.addProperty("artworkTitle", "Unknown");
                }
                
                // Get buyer username
                try {
                    if (purchase.getBuyerId() != null) {
                        User buyer = userDAO.findById(purchase.getBuyerId());
                        String username = "Unknown";
                        if (buyer != null) {
                            if (buyer.getUsername() != null && !buyer.getUsername().isEmpty()) {
                                username = buyer.getUsername();
                            } else if (buyer.getFirstName() != null) {
                                username = buyer.getFirstName();
                                if (buyer.getLastName() != null && !buyer.getLastName().isEmpty()) {
                                    username += " " + buyer.getLastName();
                                }
                            }
                        }
                        saleRecord.addProperty("buyerUsername", username);
                    } else {
                        saleRecord.addProperty("buyerUsername", "Unknown");
                    }
                } catch (Exception e) {
                    logger.warning("Error fetching buyer " + purchase.getBuyerId() + ": " + e.getMessage());
                    saleRecord.addProperty("buyerUsername", "Unknown");
                }
                
                saleRecord.addProperty("saleType", "DIRECT_PURCHASE");
                saleRecord.addProperty("finalPrice", purchase.getPurchasePrice() != null ? 
                    purchase.getPurchasePrice().doubleValue() : 0.0);
                saleRecord.addProperty("saleDate", purchase.getPurchaseDate() != null ? 
                    purchase.getPurchaseDate().toString() : "");
                
                BigDecimal purchasePrice = purchase.getPurchasePrice() != null ? 
                    purchase.getPurchasePrice() : BigDecimal.ZERO;
                totalDirectSales = totalDirectSales.add(purchasePrice);
                
                salesRecords.add(saleRecord);
            } catch (Exception e) {
                logger.warning("Error processing purchase record: " + e.getMessage());
                // Continue with next purchase
            }
        }
        
        // Add auction sales
        BigDecimal totalAuctionSales = BigDecimal.ZERO;
        for (Artwork artwork : soldAuctions) {
            try {
                JsonObject saleRecord = new JsonObject();
                saleRecord.addProperty("artworkId", artwork.getArtworkId() != null ? artwork.getArtworkId() : "");
                saleRecord.addProperty("artworkTitle", artwork.getTitle() != null ? artwork.getTitle() : "Unknown");
                
                // Get buyer username - prefer username from UserDAO, fallback to winnerName
                String buyerUsername = "Unknown";
                if (artwork.getWinnerId() != null && !artwork.getWinnerId().isEmpty()) {
                    try {
                        User buyer = userDAO.findById(artwork.getWinnerId());
                        if (buyer != null) {
                            if (buyer.getUsername() != null && !buyer.getUsername().isEmpty()) {
                                buyerUsername = buyer.getUsername();
                            } else if (buyer.getFirstName() != null) {
                                buyerUsername = buyer.getFirstName();
                                if (buyer.getLastName() != null && !buyer.getLastName().isEmpty()) {
                                    buyerUsername += " " + buyer.getLastName();
                                }
                            }
                        } else if (artwork.getWinnerName() != null && !artwork.getWinnerName().isEmpty()) {
                            buyerUsername = artwork.getWinnerName();
                        }
                    } catch (Exception e) {
                        logger.warning("Error fetching winner user " + artwork.getWinnerId() + ": " + e.getMessage());
                        // Fallback to winnerName from artwork
                        if (artwork.getWinnerName() != null && !artwork.getWinnerName().isEmpty()) {
                            buyerUsername = artwork.getWinnerName();
                        }
                    }
                } else if (artwork.getWinnerName() != null && !artwork.getWinnerName().isEmpty()) {
                    buyerUsername = artwork.getWinnerName();
                }
                
                saleRecord.addProperty("buyerUsername", buyerUsername);
                saleRecord.addProperty("saleType", "AUCTION");
                
                BigDecimal winningBid = artwork.getWinningBidAmount() != null ? artwork.getWinningBidAmount() : 
                                      (artwork.getCurrentBid() != null ? artwork.getCurrentBid() : BigDecimal.ZERO);
                saleRecord.addProperty("finalPrice", winningBid.doubleValue());
                
                LocalDateTime saleDate = artwork.getEndedAt() != null ? artwork.getEndedAt() : 
                                       (artwork.getSoldAt() != null ? artwork.getSoldAt() : artwork.getUpdatedAt());
                saleRecord.addProperty("saleDate", saleDate != null ? saleDate.toString() : "");
                
                totalAuctionSales = totalAuctionSales.add(winningBid);
                
                salesRecords.add(saleRecord);
            } catch (Exception e) {
                logger.warning("Error processing auction sale record: " + e.getMessage());
                // Continue with next artwork
            }
        }
        
        // Calculate totals
        int totalArtworksSold = filteredPurchases.size() + soldAuctions.size();
        BigDecimal totalRevenue = totalDirectSales.add(totalAuctionSales);
        
        // Add summary statistics
        report.addProperty("totalArtworksSold", totalArtworksSold);
        report.addProperty("totalRevenue", totalRevenue.doubleValue());
        report.addProperty("directPurchaseCount", filteredPurchases.size());
        report.addProperty("directPurchaseRevenue", totalDirectSales.doubleValue());
        report.addProperty("auctionSaleCount", soldAuctions.size());
        report.addProperty("auctionSaleRevenue", totalAuctionSales.doubleValue());
        
        // Add sales records
        report.add("salesRecords", salesRecords);
        
        // Add date range info
        if (startDate != null) {
            report.addProperty("startDate", startDate.toString());
        }
        if (endDate != null) {
            report.addProperty("endDate", endDate.toString());
        }
        
        return report;
    }
}
