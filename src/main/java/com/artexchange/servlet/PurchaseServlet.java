package com.artexchange.servlet;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.PurchaseDAO;
import com.artexchange.dao.UserDAO;
import com.artexchange.model.Artwork;
import com.artexchange.model.Purchase;
import com.artexchange.model.User;
import com.artexchange.util.SessionUtil;
import com.artexchange.util.GsonUtil;
import com.artexchange.util.NotificationUtil;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.BufferedReader;
import java.io.IOException;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;

/**
 * Servlet for handling purchase-related API requests
 */
@WebServlet(name = "PurchaseServlet", urlPatterns = {"/api/purchases/*"})
public class PurchaseServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(PurchaseServlet.class.getName());
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
        
        String pathInfo = request.getPathInfo();
        
        try {
            // Handle /api/purchases (list all for current user) or /api/purchases/me
            if (pathInfo == null || pathInfo.isEmpty() || "/".equals(pathInfo) || "/me".equals(pathInfo)) {
                handleGetMyPurchases(request, response, currentUserId);
            } 
            // Handle /api/purchases/{purchaseId}
            else if (pathInfo != null && pathInfo.startsWith("/") && pathInfo.length() > 1) {
                String purchaseId = pathInfo.substring(1);
                // Skip "me" as it's handled above
                if (!"me".equals(purchaseId)) {
                    handleGetPurchaseById(request, response, currentUserId, purchaseId);
                } else {
                    handleGetMyPurchases(request, response, currentUserId);
                }
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                JsonObject error = new JsonObject();
                error.addProperty("error", "Endpoint not found");
                response.getWriter().write(gson.toJson(error));
            }
        } catch (Exception e) {
            logger.severe("Error in PurchaseServlet: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("error", "Internal server error");
            response.getWriter().write(gson.toJson(error));
        }
    }
    
    /**
     * Get purchases for the authenticated user with artwork details
     */
    private void handleGetMyPurchases(HttpServletRequest request, HttpServletResponse response, String userId)
            throws IOException, ExecutionException, InterruptedException {
        
        try {
            // Fetch purchases for this user (as buyer)
            List<Purchase> purchases = purchaseDAO.findByBuyerId(userId);
            
            JsonArray purchasesArray = new JsonArray();
            
            for (Purchase purchase : purchases) {
                JsonObject purchaseObj = createPurchaseJsonObject(purchase);
                purchasesArray.add(purchaseObj);
            }
            
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.add("purchases", purchasesArray);
            jsonResponse.addProperty("count", purchasesArray.size());
            
            response.getWriter().write(gson.toJson(jsonResponse));
            
        } catch (Exception e) {
            logger.severe("Error fetching purchases: " + e.getMessage());
            throw e;
        }
    }
    
    /**
     * Get a specific purchase by ID (only if user is the buyer)
     */
    private void handleGetPurchaseById(HttpServletRequest request, HttpServletResponse response, 
                                      String userId, String purchaseId)
            throws IOException, ExecutionException, InterruptedException {
        
        try {
            Purchase purchase = purchaseDAO.findById(purchaseId);
            
            if (purchase == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                JsonObject error = new JsonObject();
                error.addProperty("error", "Purchase not found");
                response.getWriter().write(gson.toJson(error));
                return;
            }
            
            // Authorization check: only the buyer can view their purchase
            if (!userId.equals(purchase.getBuyerId())) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                JsonObject error = new JsonObject();
                error.addProperty("error", "Access denied");
                response.getWriter().write(gson.toJson(error));
                return;
            }
            
            JsonObject purchaseObj = createPurchaseJsonObject(purchase);
            
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.add("purchase", purchaseObj);
            
            response.getWriter().write(gson.toJson(jsonResponse));
            
        } catch (Exception e) {
            logger.severe("Error fetching purchase: " + e.getMessage());
            throw e;
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
            Artwork artwork = artworkDAO.findById(purchase.getArtworkId());
            if (artwork != null) {
                JsonObject artworkObj = new JsonObject();
                artworkObj.addProperty("artworkId", artwork.getArtworkId());
                artworkObj.addProperty("title", artwork.getTitle());
                artworkObj.addProperty("description", artwork.getDescription());
                artworkObj.addProperty("primaryImageUrl", artwork.getPrimaryImageUrl());
                artworkObj.addProperty("category", artwork.getCategory() != null ? 
                    artwork.getCategory().name() : null);
                artworkObj.addProperty("artistName", artwork.getArtistName());
                purchaseObj.add("artwork", artworkObj);
            }
        } catch (Exception e) {
            logger.warning("Error fetching artwork for purchase: " + e.getMessage());
        }
        
        // Fetch and include seller details
        try {
            if (purchase.getSellerId() != null) {
                User seller = userDAO.findById(purchase.getSellerId());
                if (seller != null) {
                    JsonObject sellerObj = new JsonObject();
                    sellerObj.addProperty("userId", seller.getUserId());
                    sellerObj.addProperty("displayName", seller.getDisplayName());
                    sellerObj.addProperty("email", seller.getEmail());
                    purchaseObj.add("seller", sellerObj);
                }
            }
        } catch (Exception e) {
            logger.warning("Error fetching seller for purchase: " + e.getMessage());
        }
        
        return purchaseObj;
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Check authentication
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("error", "Authentication required");
            response.getWriter().write(gson.toJson(error));
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        try {
            // Handle /api/purchases/{purchaseId}/complete-payment
            if (pathInfo != null && pathInfo.contains("/complete-payment")) {
                String[] parts = pathInfo.split("/");
                if (parts.length >= 2) {
                    String purchaseId = parts[1];
                    handleCompletePayment(request, response, currentUserId, purchaseId);
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    JsonObject error = new JsonObject();
                    error.addProperty("success", false);
                    error.addProperty("error", "Purchase ID required");
                    response.getWriter().write(gson.toJson(error));
                }
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("error", "Endpoint not found");
                response.getWriter().write(gson.toJson(error));
            }
        } catch (Exception e) {
            logger.severe("Error in PurchaseServlet POST: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            JsonObject error = new JsonObject();
            error.addProperty("success", false);
            error.addProperty("error", "Internal server error");
            error.addProperty("message", e.getMessage());
            response.getWriter().write(gson.toJson(error));
        }
    }
    
    /**
     * Handle payment completion for auction wins
     */
    private void handleCompletePayment(HttpServletRequest request, HttpServletResponse response,
                                      String userId, String purchaseId)
            throws IOException, ExecutionException, InterruptedException {
        
        try {
            // Get purchase
            Purchase purchase = purchaseDAO.findById(purchaseId);
            if (purchase == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("error", "Purchase not found");
                response.getWriter().write(gson.toJson(error));
                return;
            }
            
            // Authorization check: only the buyer can complete payment
            if (!userId.equals(purchase.getBuyerId())) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("error", "You can only complete payment for your own purchases");
                response.getWriter().write(gson.toJson(error));
                return;
            }
            
            // Check if purchase is in PENDING_PAYMENT status
            if (!"PENDING_PAYMENT".equals(purchase.getStatus())) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("error", "This purchase is not pending payment");
                response.getWriter().write(gson.toJson(error));
                return;
            }
            
            // Check if payment deadline has passed
            if (purchase.getPaymentDeadline() != null && 
                purchase.getPaymentDeadline().isBefore(LocalDateTime.now())) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("error", "Payment deadline has passed");
                response.getWriter().write(gson.toJson(error));
                return;
            }
            
            // Parse request body for payment details
            StringBuilder jsonBuffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
            
            TypeToken<Map<String, Object>> mapType = new TypeToken<Map<String, Object>>(){};
            Map<String, Object> requestData = gson.fromJson(jsonBuffer.toString(), mapType.getType());
            
            String paymentMethod = (String) requestData.get("paymentMethod");
            String shippingAddress = (String) requestData.get("shippingAddress");
            String notes = (String) requestData.get("notes");
            
            // Validate required fields
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("error", "Payment method is required");
                response.getWriter().write(gson.toJson(error));
                return;
            }
            
            if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                JsonObject error = new JsonObject();
                error.addProperty("success", false);
                error.addProperty("error", "Shipping address is required");
                response.getWriter().write(gson.toJson(error));
                return;
            }
            
            // Update purchase with payment details
            purchase.setPaymentMethod(paymentMethod);
            purchase.setShippingAddress(shippingAddress);
            if (notes != null && !notes.trim().isEmpty()) {
                purchase.setNotes(notes.trim());
            }
            purchase.setStatus("COMPLETED");
            purchase.setPaymentExpired(false);
            purchase.setPaidAt(LocalDateTime.now()); // Set payment completion timestamp
            
            // Update transaction ID
            purchase.setTransactionId("PAYMENT_" + purchaseId + "_" + System.currentTimeMillis());
            
            // Save updated purchase
            purchaseDAO.savePurchase(purchase);
            
            // Update artwork status to SOLD
            Artwork artwork = artworkDAO.findById(purchase.getArtworkId());
            if (artwork != null) {
                artwork.setStatus(Artwork.ArtworkStatus.SOLD);
                artwork.setSoldAt(LocalDateTime.now());
                artworkDAO.updateArtwork(artwork);
            }
            
            // Send purchase completion notifications
            try {
                NotificationUtil.sendPurchaseNotifications(
                    purchase.getArtworkId(),
                    purchase.getBuyerId(),
                    purchase.getSellerId(),
                    purchaseId
                );
            } catch (Exception e) {
                logger.warning("Failed to send purchase notifications: " + e.getMessage());
            }
            
            // Return success response
            JsonObject jsonResponse = new JsonObject();
            jsonResponse.addProperty("success", true);
            jsonResponse.addProperty("message", "Payment completed successfully");
            jsonResponse.addProperty("purchaseId", purchaseId);
            jsonResponse.addProperty("transactionId", purchase.getTransactionId());
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(gson.toJson(jsonResponse));
            
        } catch (Exception e) {
            logger.severe("Error completing payment: " + e.getMessage());
            throw e;
        }
    }
}

