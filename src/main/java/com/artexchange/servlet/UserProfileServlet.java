package com.artexchange.servlet;

import com.artexchange.dao.UserDAO;
import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.FollowDAO;
import com.artexchange.dao.PurchaseDAO;
import com.artexchange.model.User;
import com.artexchange.model.Artwork;
import com.artexchange.model.Purchase;
import com.artexchange.util.SessionUtil;
import com.artexchange.util.GsonUtil;
import com.google.gson.Gson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Servlet for handling user profile-related operations
 */
@WebServlet(name = "UserProfileServlet", urlPatterns = {"/api/users/*"})
public class UserProfileServlet extends HttpServlet {
    
    private UserDAO userDAO;
    private ArtworkDAO artworkDAO;
    private FollowDAO followDAO;
    private PurchaseDAO purchaseDAO;
    private com.artexchange.dao.ReviewDAO reviewDAO;
    private Gson gson;
    
    @Override
    public void init() throws ServletException {
        super.init();
        this.userDAO = new UserDAO();
        this.artworkDAO = new ArtworkDAO();
        this.followDAO = new FollowDAO();
        this.purchaseDAO = new PurchaseDAO();
        this.reviewDAO = new com.artexchange.dao.ReviewDAO();
        this.gson = GsonUtil.getGson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                sendError(response, 400, "User ID is required");
                return;
            }
            
            String[] pathParts = pathInfo.split("/");
            if (pathParts.length < 2) {
                sendError(response, 400, "Invalid URL format");
                return;
            }
            
            String identifier = pathParts[1];
            
            if (pathParts.length == 2) {
                // GET /api/users/{userId} or /api/users/{username} - Get user profile
                // Try to find by userId first, then by username
                getUserProfileByIdentifier(request, response, identifier);
            } else if (pathParts.length == 3) {
                String userId = identifier;
                String action = pathParts[2];
                switch (action) {
                    case "stats":
                        // GET /api/users/{userId}/stats - Get user statistics
                        getUserStats(request, response, userId);
                        break;
                    case "artworks":
                        // GET /api/users/{userId}/artworks - Get user's artworks
                        getUserArtworks(request, response, userId);
                        break;
                    case "purchases":
                        // GET /api/users/{userId}/purchases - Get user's purchased artworks
                        getUserPurchases(request, response, userId);
                        break;
                    case "follow-status":
                        // GET /api/users/{userId}/follow-status - Check if current user follows this user
                        getFollowStatus(request, response, userId);
                        break;
                    case "reviews":
                        // GET /api/users/{userId}/reviews - Get reviews for this artist/seller
                        getUserReviews(request, response, userId);
                        break;
                    default:
                        sendError(response, 404, "Endpoint not found");
                }
            } else {
                sendError(response, 404, "Endpoint not found");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, 500, "Internal server error: " + e.getMessage());
        }
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String pathInfo = request.getPathInfo();
        
        try {
            String[] pathParts = pathInfo.split("/");
            if (pathParts.length < 3) {
                sendError(response, 400, "Invalid URL format");
                return;
            }
            
            String userId = pathParts[1];
            String action = pathParts[2];
            
            if ("follow".equals(action)) {
                // POST /api/users/{userId}/follow - Follow/unfollow user
                handleFollowToggle(request, response, userId);
            } else {
                sendError(response, 404, "Endpoint not found");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            sendError(response, 500, "Internal server error: " + e.getMessage());
        }
    }
    
    /**
     * Get user profile by identifier (userId or username)
     */
    private void getUserProfileByIdentifier(HttpServletRequest request, HttpServletResponse response, String identifier) 
            throws IOException, ExecutionException, InterruptedException {
        
        User user = userDAO.findById(identifier);
        if (user == null) {
            // Try finding by username
            user = userDAO.findByUsername(identifier);
        }
        
        if (user == null) {
            sendError(response, 404, "User not found");
            return;
        }
        
        getUserProfile(request, response, user);
    }
    
    /**
     * Get user profile information
     */
    private void getUserProfile(HttpServletRequest request, HttpServletResponse response, User user) 
            throws IOException, ExecutionException, InterruptedException {
        
        String userId = user.getUserId();
        
        // Update user statistics
        updateUserStatistics(user);
        
        // Get current user to check if they're viewing their own profile
        User currentUser = SessionUtil.getCurrentUser(request);
        boolean isOwnProfile = currentUser != null && currentUser.getUserId().equals(userId);
        
        // Check if current user follows this user
        boolean isFollowing = false;
        if (currentUser != null && !isOwnProfile) {
            isFollowing = followDAO.isFollowing(currentUser.getUserId(), userId);
        }
        
        Map<String, Object> profileData = new HashMap<>();
        profileData.put("user", createUserResponse(user));
        profileData.put("isOwnProfile", isOwnProfile);
        profileData.put("isFollowing", isFollowing);
        
        sendSuccess(response, profileData);
    }
    
    /**
     * Get user statistics
     */
    private void getUserStats(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws IOException, ExecutionException, InterruptedException {
        
        User user = userDAO.findById(userId);
        if (user == null) {
            sendError(response, 404, "User not found");
            return;
        }
        
        // Update and get fresh statistics
        updateUserStatistics(user);
        
        // Get purchased artworks count (for buyers)
        long purchasedCount = 0;
        try {
            List<Purchase> purchases = purchaseDAO.findByBuyerId(userId);
            purchasedCount = purchases.stream()
                .filter(p -> "COMPLETED".equals(p.getStatus()))
                .count();
        } catch (Exception e) {
            // If error, keep purchasedCount as 0
        }
        
        Map<String, Object> stats = new HashMap<>();
        stats.put("artworkCount", user.getArtworkCount());
        stats.put("followerCount", user.getFollowerCount());
        stats.put("followingCount", user.getFollowingCount());
        stats.put("likesCount", user.getLikesCount());
        stats.put("salesCount", user.getSalesCount());
        stats.put("purchasedCount", purchasedCount); // Included in stats response for buyers
        
        sendSuccess(response, stats);
    }
    
    /**
     * Get user's artworks with pagination and filtering
     * Includes visibility rules: public viewers see only ACTIVE/SOLD, owners see ALL artworks
     * SOLD artworks must remain visible and be clearly marked
     */
    private void getUserArtworks(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws IOException, ExecutionException, InterruptedException {
        
        User user = userDAO.findById(userId);
        if (user == null) {
            sendError(response, 404, "User not found");
            return;
        }
        
        // Get current user to check if they're viewing their own profile
        User currentUser = SessionUtil.getCurrentUser(request);
        boolean isOwnProfile = currentUser != null && currentUser.getUserId().equals(userId);
        
        // Parse pagination parameters
        int page = 1;
        int limit = 12;
        String category = request.getParameter("category");
        
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }
            
            String limitParam = request.getParameter("limit");
            if (limitParam != null) {
                limit = Integer.parseInt(limitParam);
            }
        } catch (NumberFormatException e) {
            sendError(response, 400, "Invalid pagination parameters");
            return;
        }
        
        // Get ALL user's uploaded artworks (artworks where artistId = userId)
        List<Artwork> artworks = artworkDAO.findByArtistId(userId);
        
        // Apply visibility rules
        if (!isOwnProfile) {
            // Public view: only show ACTIVE and SOLD artworks (hide DRAFT, INACTIVE, etc.)
            artworks = artworks.stream()
                .filter(artwork -> artwork.getStatus() == Artwork.ArtworkStatus.ACTIVE || 
                                 artwork.getStatus() == Artwork.ArtworkStatus.SOLD)
                .collect(java.util.stream.Collectors.toList());
        }
        // Owner view: show ALL artworks (including DRAFT, INACTIVE, SOLD, etc.)
        // SOLD artworks must remain visible and be clearly marked
        
        // Filter by category if specified
        if (category != null && !category.trim().isEmpty() && !"All".equalsIgnoreCase(category)) {
            artworks = artworks.stream()
                .filter(artwork -> {
                    if (artwork.getCategory() == null) return false;
                    return category.equalsIgnoreCase(artwork.getCategory().name());
                })
                .collect(java.util.stream.Collectors.toList());
        }
        
        // Apply pagination
        int totalCount = artworks.size();
        int startIndex = (page - 1) * limit;
        int endIndex = Math.min(startIndex + limit, totalCount);
        
        // Fix pagination bounds to prevent IndexOutOfBoundsException
        List<Artwork> paginatedArtworks;
        if (startIndex >= totalCount || startIndex < 0 || startIndex >= endIndex) {
            // Return empty list if startIndex is beyond available items
            paginatedArtworks = new ArrayList<>();
        } else {
            paginatedArtworks = artworks.subList(startIndex, endIndex);
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("artworks", paginatedArtworks);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / limit));
        result.put("hasMore", endIndex < totalCount);
        
        sendSuccess(response, result);
    }
    
    /**
     * Get user's purchased artworks
     * ONLY visible to profile owner - hidden from public view
     */
    private void getUserPurchases(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws IOException, ExecutionException, InterruptedException {
        
        User user = userDAO.findById(userId);
        if (user == null) {
            sendError(response, 404, "User not found");
            return;
        }
        
        // Get current user to check if they're viewing their own profile
        User currentUser = SessionUtil.getCurrentUser(request);
        boolean isOwnProfile = currentUser != null && currentUser.getUserId().equals(userId);
        
        // ONLY allow viewing own purchases - hide from public view
        if (!isOwnProfile) {
            sendError(response, 403, "Purchased artworks are only visible to the profile owner");
            return;
        }
        
        // Parse pagination parameters
        int page = 1;
        int limit = 12;
        
        try {
            String pageParam = request.getParameter("page");
            if (pageParam != null) {
                page = Integer.parseInt(pageParam);
            }
            
            String limitParam = request.getParameter("limit");
            if (limitParam != null) {
                limit = Integer.parseInt(limitParam);
            }
        } catch (NumberFormatException e) {
            sendError(response, 400, "Invalid pagination parameters");
            return;
        }
        
        // Get user's purchases - include both fixed-price and auction wins
        // Only show COMPLETED purchases (payment completed)
        List<Purchase> purchases = purchaseDAO.findByBuyerId(userId);
        
        // Filter to only COMPLETED purchases (payment completed)
        purchases = purchases.stream()
            .filter(purchase -> "COMPLETED".equals(purchase.getStatus()))
            .collect(java.util.stream.Collectors.toList());
        
        // Get artwork details for each purchase
        List<Map<String, Object>> purchaseArtworks = new ArrayList<>();
        for (Purchase purchase : purchases) {
            try {
                Artwork artwork = artworkDAO.findById(purchase.getArtworkId());
                if (artwork != null) {
                    Map<String, Object> purchaseData = new HashMap<>();
                    purchaseData.put("purchaseId", purchase.getPurchaseId());
                    purchaseData.put("purchaseDate", purchase.getPurchaseDate() != null ? purchase.getPurchaseDate().toString() : null);
                    purchaseData.put("purchasePrice", purchase.getPurchasePrice() != null ? purchase.getPurchasePrice().toString() : null);
                    purchaseData.put("status", purchase.getStatus());
                    purchaseData.put("artwork", artwork);
                    purchaseArtworks.add(purchaseData);
                }
            } catch (Exception e) {
                // Skip if artwork not found
                continue;
            }
        }
        
        // Apply pagination
        int totalCount = purchaseArtworks.size();
        int startIndex = (page - 1) * limit;
        int endIndex = Math.min(startIndex + limit, totalCount);
        
        List<Map<String, Object>> paginatedPurchases;
        if (startIndex >= totalCount || startIndex < 0 || startIndex >= endIndex) {
            paginatedPurchases = new ArrayList<>();
        } else {
            paginatedPurchases = purchaseArtworks.subList(startIndex, endIndex);
        }
        
        Map<String, Object> result = new HashMap<>();
        result.put("purchases", paginatedPurchases);
        result.put("totalCount", totalCount);
        result.put("currentPage", page);
        result.put("totalPages", (int) Math.ceil((double) totalCount / limit));
        result.put("hasMore", endIndex < totalCount);
        
        sendSuccess(response, result);
    }
    
    /**
     * Check follow status between current user and target user
     */
    private void getFollowStatus(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws IOException, ExecutionException, InterruptedException {
        
        User currentUser = SessionUtil.getCurrentUser(request);
        if (currentUser == null) {
            sendError(response, 401, "Authentication required");
            return;
        }
        
        boolean isFollowing = followDAO.isFollowing(currentUser.getUserId(), userId);
        
        Map<String, Object> result = new HashMap<>();
        result.put("isFollowing", isFollowing);
        result.put("followerId", currentUser.getUserId());
        result.put("followingId", userId);
        
        sendSuccess(response, result);
    }
    
    /**
     * Get reviews for an artist/seller
     * GET /api/users/{userId}/reviews
     * This endpoint is PUBLIC - no authentication required
     */
    private void getUserReviews(HttpServletRequest request, HttpServletResponse response, String artistId) 
            throws IOException, ExecutionException, InterruptedException {
        
        try {
            // Debug: Log artist ID being queried
            System.out.println("=== FETCHING REVIEWS FOR ARTIST ===");
            System.out.println("Artist ID (viewedArtistId): " + artistId);
            
            // Verify user exists
            User artist = userDAO.findById(artistId);
            if (artist == null) {
                System.out.println("ERROR: Artist not found for ID: " + artistId);
                sendError(response, 404, "Artist not found");
                return;
            }
            
            System.out.println("Artist found: " + artist.getDisplayName() + " (" + artist.getUsername() + ")");
            
            // Fetch reviews for this artist
            // CRITICAL: Query reviews WHERE artist_id == viewedArtistId
            // DO NOT use current user ID or buyer ID
            System.out.println("Querying reviews WHERE artistId = " + artistId);
            List<com.artexchange.model.Review> reviews = reviewDAO.findByArtistId(artistId);
            
            // Debug: Log review count
            System.out.println("Reviews found: " + reviews.size());
            for (com.artexchange.model.Review review : reviews) {
                System.out.println("  - Review ID: " + review.getReviewId() + 
                                 ", Artist ID: " + review.getArtistId() + 
                                 ", Rating: " + review.getRating());
            }
            
            // Enrich reviews with artwork and buyer information
            List<Map<String, Object>> enrichedReviews = new ArrayList<>();
            for (com.artexchange.model.Review review : reviews) {
                Map<String, Object> reviewData = new HashMap<>();
                reviewData.put("reviewId", review.getReviewId());
                reviewData.put("artworkId", review.getArtworkId());
                reviewData.put("artistId", review.getArtistId());
                reviewData.put("buyerId", review.getBuyerId());
                reviewData.put("rating", review.getRating());
                reviewData.put("reviewText", review.getReviewText());
                // Convert Instant to ISO-8601 string for JSON serialization
                reviewData.put("reviewDate", review.getReviewDate() != null ? review.getReviewDate().toString() : null);
                reviewData.put("verified", review.isVerified());
                
                // Get artwork information
                if (review.getArtworkId() != null) {
                    try {
                        Artwork artwork = artworkDAO.findById(review.getArtworkId());
                        if (artwork != null) {
                            Map<String, Object> artworkData = new HashMap<>();
                            artworkData.put("artworkId", artwork.getArtworkId());
                            artworkData.put("title", artwork.getTitle());
                            artworkData.put("primaryImageUrl", artwork.getPrimaryImageUrl());
                            reviewData.put("artwork", artworkData);
                        }
                    } catch (Exception e) {
                        // Artwork not found or error - continue without artwork data
                        System.err.println("Error fetching artwork for review: " + e.getMessage());
                    }
                }
                
                // Get buyer information (optional - for buyer name display)
                if (review.getBuyerId() != null) {
                    try {
                        User buyer = userDAO.findById(review.getBuyerId());
                        if (buyer != null) {
                            Map<String, Object> buyerData = new HashMap<>();
                            buyerData.put("buyerId", buyer.getUserId());
                            buyerData.put("displayName", buyer.getDisplayName());
                            buyerData.put("username", buyer.getUsername());
                            reviewData.put("buyer", buyerData);
                        }
                    } catch (Exception e) {
                        // Buyer not found or error - continue without buyer data
                        System.err.println("Error fetching buyer for review: " + e.getMessage());
                    }
                }
                
                enrichedReviews.add(reviewData);
            }
            
            // Create response with reviews and summary
            Map<String, Object> result = new HashMap<>();
            result.put("reviews", enrichedReviews);
            result.put("totalReviews", enrichedReviews.size());
            
            // Calculate average rating
            if (!enrichedReviews.isEmpty()) {
                double avgRating = enrichedReviews.stream()
                    .filter(r -> r.get("rating") != null)
                    .mapToInt(r -> ((Number) r.get("rating")).intValue())
                    .average()
                    .orElse(0.0);
                result.put("averageRating", Math.round(avgRating * 10.0) / 10.0); // Round to 1 decimal
            } else {
                result.put("averageRating", 0.0);
            }
            
            sendSuccess(response, result);
            
        } catch (Exception e) {
            System.err.println("Error fetching reviews for artist " + artistId + ": " + e.getMessage());
            e.printStackTrace();
            sendError(response, 500, "Error fetching reviews: " + e.getMessage());
        }
    }
    
    /**
     * Handle follow/unfollow toggle
     */
    private void handleFollowToggle(HttpServletRequest request, HttpServletResponse response, String userId) 
            throws IOException, ExecutionException, InterruptedException {
        
        User currentUser = SessionUtil.getCurrentUser(request);
        if (currentUser == null) {
            sendError(response, 401, "Authentication required");
            return;
        }
        
        if (currentUser.getUserId().equals(userId)) {
            sendError(response, 400, "Cannot follow yourself");
            return;
        }
        
        User targetUser = userDAO.findById(userId);
        if (targetUser == null) {
            sendError(response, 404, "User not found");
            return;
        }
        
        boolean isCurrentlyFollowing = followDAO.isFollowing(currentUser.getUserId(), userId);
        boolean success;
        String action;
        
        if (isCurrentlyFollowing) {
            // Unfollow
            success = followDAO.unfollowUser(currentUser.getUserId(), userId);
            action = "unfollowed";
        } else {
            // Follow
            String followId = followDAO.followUser(currentUser.getUserId(), userId);
            success = followId != null;
            action = "followed";
        }
        
        if (success) {
            // Update statistics for both users
            updateUserStatistics(currentUser);
            updateUserStatistics(targetUser);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("action", action);
            result.put("isFollowing", !isCurrentlyFollowing);
            result.put("followerCount", followDAO.getFollowerCount(userId));
            result.put("followingCount", followDAO.getFollowingCount(currentUser.getUserId()));
            
            sendSuccess(response, result);
        } else {
            sendError(response, 500, "Failed to " + action + " user");
        }
    }
    
    /**
     * Update user statistics from database
     * Includes purchased artworks count and accurate sales count from PurchaseDAO
     */
    private void updateUserStatistics(User user) throws ExecutionException, InterruptedException {
        if (user == null) return;
        
        String userId = user.getUserId();
        
        // Get current statistics
        int followerCount = followDAO.getFollowerCount(userId);
        int followingCount = followDAO.getFollowingCount(userId);
        
        // Get ALL uploaded artworks (artworks where artistId = userId)
        List<Artwork> userArtworks = artworkDAO.findByArtistId(userId);
        
        // Artwork count: only ACTIVE and SOLD for public stats (visible artworks)
        int artworkCount = (int) userArtworks.stream()
            .filter(artwork -> artwork.getStatus() == Artwork.ArtworkStatus.ACTIVE || 
                             artwork.getStatus() == Artwork.ArtworkStatus.SOLD)
            .count();
        
        // Calculate likes from ALL artworks (including SOLD)
        int likesCount = userArtworks.stream()
            .mapToInt(Artwork::getLikes)
            .sum();
        
        // Sales count: number of COMPLETED transactions where user is the seller
        long salesCount = purchaseDAO.getUserSalesCount(userId);
        
        // Note: purchasedCount is calculated in getUserStats method, not here
        // This method only updates uploaded artworks stats
        
        // Update user object
        user.setFollowerCount(followerCount);
        user.setFollowingCount(followingCount);
        user.setArtworkCount(artworkCount);
        user.setLikesCount(likesCount);
        user.setSalesCount((int) salesCount);
        
        // Update in database
        userDAO.updateUserStats(userId, followerCount, followingCount, artworkCount, likesCount, (int) salesCount);
    }
    
    /**
     * Create a safe user response map without LocalDateTime fields
     */
    private Map<String, Object> createUserResponse(User user) {
        Map<String, Object> userResponse = new HashMap<>();
        userResponse.put("userId", user.getUserId());
        userResponse.put("email", user.getEmail());
        userResponse.put("username", user.getUsername());
        userResponse.put("firstName", user.getFirstName());
        userResponse.put("lastName", user.getLastName());
        userResponse.put("displayName", user.getDisplayName()); // Add displayName for easier frontend use
        userResponse.put("profileImage", user.getProfileImage());
        userResponse.put("bio", user.getBio());
        userResponse.put("role", user.getRole() != null ? user.getRole().name() : "BUYER"); // Ensure role is a string
        userResponse.put("isActive", user.isActive());
        userResponse.put("isVerified", user.isVerified());
        userResponse.put("phone", user.getPhone());
        userResponse.put("address", user.getAddress());
        userResponse.put("city", user.getCity());
        userResponse.put("state", user.getState());
        userResponse.put("country", user.getCountry());
        userResponse.put("artistStatement", user.getArtistStatement());
        userResponse.put("website", user.getWebsite());
        userResponse.put("socialMediaLinks", user.getSocialMediaLinks());
        userResponse.put("followerCount", user.getFollowerCount());
        userResponse.put("followingCount", user.getFollowingCount());
        userResponse.put("artworkCount", user.getArtworkCount());
        userResponse.put("likesCount", user.getLikesCount());
        userResponse.put("salesCount", user.getSalesCount());
        
        // Convert LocalDateTime to string format
        if (user.getCreatedAt() != null) {
            userResponse.put("createdAt", user.getCreatedAt().toString());
        }
        if (user.getUpdatedAt() != null) {
            userResponse.put("updatedAt", user.getUpdatedAt().toString());
        }
        
        return userResponse;
    }

    /**
     * Send success response
     */
    private void sendSuccess(HttpServletResponse response, Object data) throws IOException {
        Map<String, Object> result = new HashMap<>();
        result.put("success", true);
        result.put("data", data);
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(result));
        out.flush();
    }
    
    /**
     * Send error response
     */
    private void sendError(HttpServletResponse response, int statusCode, String message) throws IOException {
        response.setStatus(statusCode);
        
        Map<String, Object> error = new HashMap<>();
        error.put("success", false);
        error.put("error", message);
        
        PrintWriter out = response.getWriter();
        out.print(gson.toJson(error));
        out.flush();
    }
}
