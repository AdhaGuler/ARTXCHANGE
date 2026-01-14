package com.artexchange.servlet;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.PurchaseDAO;
import com.artexchange.dao.ReviewDAO;
import com.artexchange.model.Artwork;
import com.artexchange.model.Purchase;
import com.artexchange.model.Review;
import com.artexchange.util.GsonUtil;
import com.artexchange.util.SessionUtil;
import com.google.gson.Gson;
import com.google.gson.JsonObject;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.time.Instant;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;

/**
 * Servlet for handling review-related operations
 */
@WebServlet(name = "ReviewServlet", urlPatterns = {"/api/reviews/*"})
public class ReviewServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(ReviewServlet.class.getName());
    private ReviewDAO reviewDAO;
    private PurchaseDAO purchaseDAO;
    private ArtworkDAO artworkDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.reviewDAO = new ReviewDAO();
        this.purchaseDAO = new PurchaseDAO();
        this.artworkDAO = new ArtworkDAO();
        this.gson = GsonUtil.getGson();
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        // Get current user (buyer)
        String buyerId = SessionUtil.getCurrentUserId(request);
        if (buyerId == null) {
            sendError(response, 401, "Authentication required");
            return;
        }
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/") || pathInfo.equals("")) {
                // POST /api/reviews - Create a new review
                createReview(request, response, buyerId);
            } else {
                sendError(response, 404, "Endpoint not found");
            }
        } catch (Exception e) {
            logger.severe("Error in ReviewServlet POST: " + e.getMessage());
            e.printStackTrace();
            sendError(response, 500, "Internal server error: " + e.getMessage());
        }
    }
    
    /**
     * Create a new review
     * POST /api/reviews
     * Body: {
     *   "purchaseId": "purchase123",
     *   "rating": 5,
     *   "reviewText": "Great artwork!"
     * }
     */
    private void createReview(HttpServletRequest request, HttpServletResponse response, String buyerId)
            throws IOException, ExecutionException, InterruptedException {
        
        try {
            // Parse request body
            StringBuilder requestBody = new StringBuilder();
            String line;
            while ((line = request.getReader().readLine()) != null) {
                requestBody.append(line);
            }
            
            JsonObject jsonRequest = gson.fromJson(requestBody.toString(), JsonObject.class);
            
            if (jsonRequest == null) {
                sendError(response, 400, "Invalid request body");
                return;
            }
            
            String purchaseId = jsonRequest.has("purchaseId") ? jsonRequest.get("purchaseId").getAsString() : null;
            Integer rating = jsonRequest.has("rating") ? jsonRequest.get("rating").getAsInt() : null;
            String reviewText = jsonRequest.has("reviewText") ? jsonRequest.get("reviewText").getAsString() : null;
            
            // Validation
            if (purchaseId == null || purchaseId.isEmpty()) {
                sendError(response, 400, "purchaseId is required");
                return;
            }
            
            if (rating == null || rating < 1 || rating > 5) {
                sendError(response, 400, "rating must be between 1 and 5");
                return;
            }
            
            if (reviewText == null || reviewText.trim().isEmpty()) {
                sendError(response, 400, "reviewText is required");
                return;
            }
            
            // Fetch purchase to get artwork_id and verify buyer
            Purchase purchase = purchaseDAO.findById(purchaseId);
            if (purchase == null) {
                sendError(response, 404, "Purchase not found");
                return;
            }
            
            // Verify buyer owns this purchase
            if (!buyerId.equals(purchase.getBuyerId())) {
                sendError(response, 403, "You can only review your own purchases");
                return;
            }
            
            // Verify purchase is COMPLETED
            if (!"COMPLETED".equals(purchase.getStatus())) {
                sendError(response, 400, "You can only review completed purchases");
                return;
            }
            
            // Check if review already exists for this purchase
            // (Optional: allow only one review per purchase)
            // For now, we'll allow multiple reviews (user can update their review)
            
            // Fetch artwork to get artist_id
            String artworkId = purchase.getArtworkId();
            if (artworkId == null || artworkId.isEmpty()) {
                sendError(response, 400, "Purchase does not have an associated artwork");
                return;
            }
            
            Artwork artwork = artworkDAO.findById(artworkId);
            if (artwork == null) {
                sendError(response, 404, "Artwork not found");
                return;
            }
            
            // Get artist_id from artwork
            String artistId = artwork.getArtistId();
            if (artistId == null || artistId.isEmpty()) {
                // Fallback to sellerId from purchase if artwork doesn't have artistId
                artistId = purchase.getSellerId();
            }
            
            if (artistId == null || artistId.isEmpty()) {
                sendError(response, 400, "Cannot determine artist ID");
                return;
            }
            
            // Debug log
            logger.info("Creating review - purchaseId: " + purchaseId + 
                       ", artworkId: " + artworkId + 
                       ", artistId: " + artistId + 
                       ", buyerId: " + buyerId + 
                       ", rating: " + rating);
            
            // Create review object
            Review review = new Review();
            review.setArtworkId(artworkId);
            review.setArtistId(artistId); // CRITICAL: Store artist_id explicitly
            review.setBuyerId(buyerId);
            review.setRating(rating);
            review.setReviewText(reviewText.trim());
            review.setReviewDate(Instant.now()); // Set timestamp using Instant for Java 17 compatibility
            review.setVerified(true); // All reviews from purchases are verified
            
            // Save review to database
            String reviewId = reviewDAO.saveReview(review);
            review.setReviewId(reviewId);
            
            // Debug log
            logger.info("Review saved successfully - reviewId: " + reviewId + ", artistId: " + artistId);
            
            // Return success response
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Review submitted successfully");
            result.put("reviewId", reviewId);
            result.put("artistId", artistId); // Return for debugging
            
            sendSuccess(response, result);
            
        } catch (Exception e) {
            logger.severe("Error creating review: " + e.getMessage());
            e.printStackTrace();
            sendError(response, 500, "Error creating review: " + e.getMessage());
        }
    }
    
    /**
     * Send success response
     */
    private void sendSuccess(HttpServletResponse response, Object data) throws IOException {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", data);
        
        response.setStatus(HttpServletResponse.SC_OK);
        response.getWriter().write(gson.toJson(result));
        response.getWriter().flush();
    }
    
    /**
     * Send error response
     */
    private void sendError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        
        response.getWriter().write(gson.toJson(error));
        response.getWriter().flush();
    }
}

