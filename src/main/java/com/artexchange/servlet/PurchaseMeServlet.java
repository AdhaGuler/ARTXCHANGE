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
import java.util.List;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;

/**
 * Servlet for handling /api/me/purchases endpoint
 */
@WebServlet(name = "PurchaseMeServlet", urlPatterns = {"/api/me/purchases"})
public class PurchaseMeServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(PurchaseMeServlet.class.getName());
    private transient PurchaseDAO purchaseDAO;
    private transient ArtworkDAO artworkDAO;
    private transient UserDAO userDAO;
    private transient Gson gson;
    
    @Override
    public void init() throws ServletException {
        super.init();
        purchaseDAO = new PurchaseDAO();
        artworkDAO = new ArtworkDAO();
        userDAO = new UserDAO();
        gson = GsonUtil.getGson();
    }
    
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
        
        try {
            // Fetch purchases for this user (as buyer)
            List<Purchase> purchases = purchaseDAO.findByBuyerId(currentUserId);
            
            JsonArray purchasesArray = new JsonArray();
            
            for (Purchase purchase : purchases) {
                try {
                    JsonObject purchaseObj = createPurchaseJsonObject(purchase);
                    purchasesArray.add(purchaseObj);
                } catch (Exception e) {
                    logger.warning("Error creating purchase JSON object: " + e.getMessage());
                    // Continue with next purchase instead of failing completely
                }
            }
            
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.add("purchases", purchasesArray);
            jsonResponse.addProperty("count", purchasesArray.size());
            
            response.getWriter().write(gson.toJson(jsonResponse));
            
        } catch (Exception e) {
            logger.severe("Error fetching purchases: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("error", "Internal server error");
            error.addProperty("message", e.getMessage() != null ? e.getMessage() : "Failed to fetch purchases");
            try {
                response.getWriter().write(gson.toJson(error));
            } catch (IOException ioException) {
                logger.severe("Error writing error response: " + ioException.getMessage());
            }
        }
    }
    
    /**
     * Create a JSON object with purchase details including artwork and seller info
     */
    private JsonObject createPurchaseJsonObject(Purchase purchase) 
            throws ExecutionException, InterruptedException {
        
        JsonObject purchaseObj = new JsonObject();
        purchaseObj.addProperty("purchaseId", purchase.getPurchaseId());
        purchaseObj.addProperty("artworkId", purchase.getArtworkId());
        purchaseObj.addProperty("buyerId", purchase.getBuyerId());
        purchaseObj.addProperty("sellerId", purchase.getSellerId());
        purchaseObj.addProperty("purchasePrice", purchase.getPurchasePrice() != null ? 
            purchase.getPurchasePrice().doubleValue() : 0.0);
        purchaseObj.addProperty("purchaseDate", purchase.getPurchaseDate() != null ? 
            purchase.getPurchaseDate().toString() : null);
        purchaseObj.addProperty("status", purchase.getStatus());
        purchaseObj.addProperty("paymentMethod", purchase.getPaymentMethod());
        purchaseObj.addProperty("transactionId", purchase.getTransactionId());
        purchaseObj.addProperty("shippingAddress", purchase.getShippingAddress());
        purchaseObj.addProperty("shippingCost", purchase.getShippingCost() != null ? 
            purchase.getShippingCost().doubleValue() : 0.0);
        purchaseObj.addProperty("notes", purchase.getNotes());
        purchaseObj.addProperty("paymentDeadline", purchase.getPaymentDeadline() != null ? 
            purchase.getPaymentDeadline().toString() : null);
        purchaseObj.addProperty("paymentExpired", purchase.isPaymentExpired());
        purchaseObj.addProperty("paidAt", purchase.getPaidAt() != null ? 
            purchase.getPaidAt().toString() : null);
        
        // Fetch and include artwork details
        try {
            if (purchase.getArtworkId() != null && !purchase.getArtworkId().trim().isEmpty()) {
                Artwork artwork = artworkDAO.findById(purchase.getArtworkId());
                if (artwork != null) {
                    JsonObject artworkObj = new JsonObject();
                    artworkObj.addProperty("artworkId", artwork.getArtworkId());
                    artworkObj.addProperty("title", artwork.getTitle() != null ? artwork.getTitle() : "Unknown Artwork");
                    artworkObj.addProperty("description", artwork.getDescription());
                    artworkObj.addProperty("primaryImageUrl", artwork.getPrimaryImageUrl());
                    artworkObj.addProperty("category", artwork.getCategory() != null ? 
                        artwork.getCategory().name() : null);
                    artworkObj.addProperty("artistName", artwork.getArtistName() != null ? artwork.getArtistName() : "Unknown Artist");
                    purchaseObj.add("artwork", artworkObj);
                } else {
                    // Add placeholder artwork if not found
                    JsonObject artworkObj = new JsonObject();
                    artworkObj.addProperty("artworkId", purchase.getArtworkId());
                    artworkObj.addProperty("title", "Artwork Not Found");
                    artworkObj.addProperty("artistName", "Unknown Artist");
                    purchaseObj.add("artwork", artworkObj);
                }
            }
        } catch (Exception e) {
            logger.warning("Error fetching artwork for purchase: " + e.getMessage());
            // Add placeholder artwork on error
            JsonObject artworkObj = new JsonObject();
            artworkObj.addProperty("artworkId", purchase.getArtworkId() != null ? purchase.getArtworkId() : "");
            artworkObj.addProperty("title", "Error Loading Artwork");
            artworkObj.addProperty("artistName", "Unknown");
            purchaseObj.add("artwork", artworkObj);
        }
        
        // Fetch and include seller details
        try {
            if (purchase.getSellerId() != null && !purchase.getSellerId().trim().isEmpty()) {
                User seller = userDAO.findById(purchase.getSellerId());
                if (seller != null) {
                    JsonObject sellerObj = new JsonObject();
                    sellerObj.addProperty("userId", seller.getUserId());
                    sellerObj.addProperty("displayName", seller.getDisplayName() != null ? seller.getDisplayName() : "Unknown Seller");
                    sellerObj.addProperty("email", seller.getEmail());
                    purchaseObj.add("seller", sellerObj);
                } else {
                    // Add placeholder seller if not found
                    JsonObject sellerObj = new JsonObject();
                    sellerObj.addProperty("userId", purchase.getSellerId());
                    sellerObj.addProperty("displayName", "Unknown Seller");
                    purchaseObj.add("seller", sellerObj);
                }
            }
        } catch (Exception e) {
            logger.warning("Error fetching seller for purchase: " + e.getMessage());
            // Add placeholder seller on error
            if (purchase.getSellerId() != null) {
                JsonObject sellerObj = new JsonObject();
                sellerObj.addProperty("userId", purchase.getSellerId());
                sellerObj.addProperty("displayName", "Unknown Seller");
                purchaseObj.add("seller", sellerObj);
            }
        }
        
        return purchaseObj;
    }
}

