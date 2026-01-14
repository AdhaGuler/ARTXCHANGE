package com.artexchange.servlet;

import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.PurchaseDAO;
import com.artexchange.dao.AuctionDAO;
import com.artexchange.model.Artwork;
import com.artexchange.model.Purchase;
import com.artexchange.util.SessionUtil;
import com.artexchange.util.GsonUtil;
import com.artexchange.util.NotificationUtil;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.math.BigDecimal;
import java.io.BufferedReader;
import java.lang.reflect.Type;

/**
 * Servlet for handling artwork-related API requests
 */
@WebServlet(name = "ArtworkServlet", urlPatterns = {"/api/artworks/*"})
public class ArtworkServlet extends HttpServlet {
    private static final Logger logger = LoggerFactory.getLogger(ArtworkServlet.class);
    private transient ArtworkDAO artworkDAO;
    private transient PurchaseDAO purchaseDAO;
    private transient AuctionDAO auctionDAO;
    private transient Gson gson;
    
    @Override
    public void init() throws ServletException {
        super.init();
        artworkDAO = new ArtworkDAO();
        purchaseDAO = new PurchaseDAO();
        auctionDAO = new AuctionDAO();
        gson = GsonUtil.getGson();
    }
    
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        logger.info("=== ArtworkServlet doGet called ===");
        logger.info("Request URI: {}", request.getRequestURI());
        logger.info("Path Info: {}", pathInfo);
        logger.info("Query String: {}", request.getQueryString());
        logger.info("Context Path: {}", request.getContextPath());
        logger.info("Servlet Path: {}", request.getServletPath());
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                logger.info("Routing to handleGetAllArtworks (pathInfo: null or /)");
                handleGetAllArtworks(request, response);
            } else if (pathInfo.equals("/browse")) {
                logger.info("Routing to handleGetAllArtworks (pathInfo: /browse)");
                handleGetAllArtworks(request, response);
            } else if (pathInfo.equals("/featured")) {
                logger.info("Routing to handleGetFeaturedArtworks");
                handleGetFeaturedArtworks(request, response);
            } else if (pathInfo.equals("/my-artworks")) {
                logger.info("Routing to handleGetMyArtworks");
                handleGetMyArtworks(request, response);
            } else if (pathInfo.startsWith("/")) {
                String[] pathParts = pathInfo.split("/");
                logger.info("Path parts: {}", java.util.Arrays.toString(pathParts));
                if (pathParts.length >= 2) {
                    String artworkId = pathParts[1];
                    
                    if (pathParts.length == 2) {
                        logger.info("Routing to handleGetArtwork for ID: {}", artworkId);
                        handleGetArtwork(request, response, artworkId);
                    } else if (pathParts.length == 3 && "bids".equals(pathParts[2])) {
                        logger.info("Routing to handleGetArtworkBids for ID: {}", artworkId);
                        handleGetArtworkBids(request, response, artworkId);
                    } else if (pathParts.length == 3 && "bidders".equals(pathParts[2])) {
                        logger.info("Routing to handleGetArtworkBidders for ID: {}", artworkId);
                        handleGetArtworkBidders(request, response, artworkId);
                    }
                }
            } else {
                logger.warn("No matching route found for pathInfo: {}", pathInfo);
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendErrorResponse(response, "Endpoint not found");
            }
        } catch (Exception e) {
            logger.error("Error in ArtworkServlet GET: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Internal server error");
        }
        
        logger.info("=== ArtworkServlet doGet completed ===");
    }
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // Create new artwork
                handleCreateArtwork(request, response);
            } else if (pathInfo != null && pathInfo.contains("/like")) {
                String artworkId = pathInfo.split("/")[1];
                handleToggleLike(request, response, artworkId);
            } else if (pathInfo != null && pathInfo.contains("/bid")) {
                String artworkId = pathInfo.split("/")[1];
                handlePlaceBid(request, response, artworkId);
            } else if (pathInfo != null && pathInfo.contains("/purchase")) {
                String artworkId = pathInfo.split("/")[1];
                handlePurchaseArtwork(request, response, artworkId);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                sendErrorResponse(response, "Endpoint not found");
            }
        } catch (Exception e) {
            logger.error("Error in ArtworkServlet POST: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Internal server error");
        }
    }
    
    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            if (pathInfo != null && pathInfo.startsWith("/")) {
                String[] pathParts = pathInfo.split("/");
                if (pathParts.length >= 2) {
                    String artworkId = pathParts[1];
                    handleUpdateArtwork(request, response, artworkId);
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    sendErrorResponse(response, "Artwork ID is required");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Invalid request path");
            }
        } catch (Exception e) {
            logger.error("Error in ArtworkServlet PUT: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Internal server error");
        }
    }
    
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        String pathInfo = request.getPathInfo();
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            if (pathInfo != null && pathInfo.startsWith("/")) {
                String[] pathParts = pathInfo.split("/");
                if (pathParts.length >= 2) {
                    String artworkId = pathParts[1];
                    handleDeleteArtwork(request, response, artworkId);
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    sendErrorResponse(response, "Artwork ID is required");
                }
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Invalid request path");
            }
        } catch (Exception e) {
            logger.error("Error in ArtworkServlet DELETE: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Internal server error");
        }
    }
    
    /**
     * Get all artworks with pagination
     */
    private void handleGetAllArtworks(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ExecutionException, InterruptedException {
        
        logger.info("=== handleGetAllArtworks called ===");
        logger.info("Request URI: {}", request.getRequestURI());
        logger.info("Path Info: {}", request.getPathInfo());
        logger.info("Query String: {}", request.getQueryString());
        
        String pageParam = request.getParameter("page");
        String limitParam = request.getParameter("limit");
        String categoryParam = request.getParameter("category");
        String searchParam = request.getParameter("search");
        String minPriceParam = request.getParameter("minPrice");
        String maxPriceParam = request.getParameter("maxPrice");
        String listingTypeParam = request.getParameter("listingType");
        String sortByParam = request.getParameter("sortBy");
        
        logger.info("Parameters - page: {}, limit: {}, category: {}, search: {}, minPrice: {}, maxPrice: {}, listingType: {}, sortBy: {}", 
                   pageParam, limitParam, categoryParam, searchParam, minPriceParam, maxPriceParam, listingTypeParam, sortByParam);
        
        int page = pageParam != null ? Integer.parseInt(pageParam) : 1;
        int limit = limitParam != null ? Integer.parseInt(limitParam) : 12;
        
        logger.info("Calling artworkDAO.findActiveArtworks with page: {}, limit: {}, category: {}, search: {}, minPrice: {}, maxPrice: {}, listingType: {}, sortBy: {}", 
                   page, limit, categoryParam, searchParam, minPriceParam, maxPriceParam, listingTypeParam, sortByParam);
        
        List<Artwork> artworks = artworkDAO.findActiveArtworks(page, limit, categoryParam, searchParam, 
                                                               minPriceParam, maxPriceParam, listingTypeParam, sortByParam);
        
        logger.info("Retrieved {} artworks from DAO", artworks != null ? artworks.size() : 0);
        if (artworks != null) {
            for (int i = 0; i < Math.min(3, artworks.size()); i++) {
                Artwork artwork = artworks.get(i);
                logger.info("Artwork {}: id={}, title={}, status={}", 
                           i, artwork.getArtworkId(), artwork.getTitle(), artwork.getStatus());
            }
        }
        
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("artworks", artworks);
        responseData.put("currentPage", page);
        responseData.put("totalPages", 1); // TODO: implement proper pagination
        responseData.put("page", page);
        responseData.put("limit", limit);
        
        String jsonResponse = gson.toJson(responseData);
        logger.info("Response JSON length: {} characters", jsonResponse.length());
        logger.info("First 200 characters of response: {}", 
                   jsonResponse.length() > 200 ? jsonResponse.substring(0, 200) + "..." : jsonResponse);
        
        response.getWriter().write(jsonResponse);
        logger.info("=== handleGetAllArtworks completed ===");
    }
    
    /**
     * Get featured artworks
     */
    private void handleGetFeaturedArtworks(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ExecutionException, InterruptedException {
        
        List<Artwork> featuredArtworks = artworkDAO.findFeaturedArtworks(6);
        
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("artworks", featuredArtworks);
        
        response.getWriter().write(gson.toJson(responseData));
    }
    
    /**
     * Get artworks created by the current user
     */
    private void handleGetMyArtworks(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ExecutionException, InterruptedException {
        
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Authentication required");
            return;
        }
        
        String pageParam = request.getParameter("page");
        String limitParam = request.getParameter("limit");
        
        int page = pageParam != null ? Integer.parseInt(pageParam) : 1;
        int limit = limitParam != null ? Integer.parseInt(limitParam) : 12;
        
        List<Artwork> myArtworks = artworkDAO.findArtworksByArtist(currentUserId, page, limit);
        
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("artworks", myArtworks);
        responseData.put("page", page);
        responseData.put("limit", limit);
        
        response.getWriter().write(gson.toJson(responseData));
    }
    
    /**
     * Get single artwork
     */
    private void handleGetArtwork(HttpServletRequest request, HttpServletResponse response, String artworkId) 
            throws IOException, ExecutionException, InterruptedException {
        
        Artwork artwork = artworkDAO.findById(artworkId);
        
        if (artwork == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            sendErrorResponse(response, "Artwork not found");
            return;
        }
        
        // Increment view count
        artwork.incrementViews();
        artworkDAO.updateArtwork(artwork);
        
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("artwork", artwork);
        
        response.getWriter().write(gson.toJson(responseData));
    }
    
    /**
     * Get artwork bids (for auctions)
     */
    private void handleGetArtworkBids(HttpServletRequest request, HttpServletResponse response, String artworkId) 
            throws IOException, ExecutionException, InterruptedException {
        
        // This would be implemented with a BidDAO
        // For now, return empty list
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("bids", new java.util.ArrayList<>());
        
        response.getWriter().write(gson.toJson(responseData));
    }
    
    /**
     * Get all bidders for an artwork auction (artist only)
     */
    private void handleGetArtworkBidders(HttpServletRequest request, HttpServletResponse response, String artworkId) 
            throws IOException, ExecutionException, InterruptedException {
        
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Authentication required");
            return;
        }
        
        // Get artwork to verify ownership
        Artwork artwork = artworkDAO.findById(artworkId);
        if (artwork == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            sendErrorResponse(response, "Artwork not found");
            return;
        }
        
        // Verify that the current user is the artist who owns this artwork
        if (!currentUserId.equals(artwork.getArtistId())) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            sendErrorResponse(response, "You can only view bidders for your own auctions");
            return;
        }
        
        // Verify that this is an auction
        if (!artwork.isAuction()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendErrorResponse(response, "This artwork is not an auction");
            return;
        }
        
        // Get sort parameter (default to "latest")
        String sortBy = request.getParameter("sortBy");
        if (sortBy == null || sortBy.trim().isEmpty()) {
            sortBy = "latest";
        }
        
        // Get bidders from AuctionDAO
        List<Map<String, Object>> bidders = auctionDAO.getAuctionBidders(artworkId, sortBy);
        
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("bidders", bidders);
        responseData.put("totalBidders", bidders.size());
        responseData.put("artworkId", artworkId);
        responseData.put("artworkTitle", artwork.getTitle());
        
        response.getWriter().write(gson.toJson(responseData));
    }
    
    /**
     * Toggle like/unlike artwork
     */
    private void handleToggleLike(HttpServletRequest request, HttpServletResponse response, String artworkId) 
            throws IOException, ExecutionException, InterruptedException {
        
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Authentication required");
            return;
        }
        
        Artwork artwork = artworkDAO.findById(artworkId);
        if (artwork == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            sendErrorResponse(response, "Artwork not found");
            return;
        }
        
        // This would be implemented with a LikeDAO to track user likes
        // For now, just increment likes
        artwork.incrementLikes();
        artworkDAO.updateArtwork(artwork);
        
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("liked", true);
        responseData.put("totalLikes", artwork.getLikes());
        
        response.getWriter().write(gson.toJson(responseData));
    }
    
    /**
     * Place bid on artwork (auction)
     */
    private void handlePlaceBid(HttpServletRequest request, HttpServletResponse response, String artworkId) 
            throws IOException, ExecutionException, InterruptedException {
        
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Authentication required");
            return;
        }
        
        // Parse bid amount from request
        Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
        Map<String, Object> requestData = gson.fromJson(request.getReader(), mapType);
        Double bidAmount = (Double) requestData.get("amount");
        
        if (bidAmount == null || bidAmount <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendErrorResponse(response, "Invalid bid amount");
            return;
        }
        
        Artwork artwork = artworkDAO.findById(artworkId);
        if (artwork == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            sendErrorResponse(response, "Artwork not found");
            return;
        }
        
        if (!artwork.isAuction()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendErrorResponse(response, "This artwork is not for auction");
            return;
        }
        
        if (!artwork.isAuctionActive()) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendErrorResponse(response, "Auction is not active");
            return;
        }
        
        // SECURITY: Prevent auction owner from bidding on their own auction
        if (artwork.getArtistId() != null && artwork.getArtistId().equals(currentUserId)) {
            logger.warn("Auction owner attempted to bid on their own auction. User ID: " + currentUserId + ", Artwork ID: " + artworkId);
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            sendErrorResponse(response, "Owners cannot bid on their own auctions.");
            return;
        }
        
        // Check if bid is higher than current bid
        java.math.BigDecimal newBid = java.math.BigDecimal.valueOf(bidAmount);
        java.math.BigDecimal currentBid = artwork.getCurrentBid() != null ? 
            artwork.getCurrentBid() : artwork.getStartingBid();
        
        if (newBid.compareTo(currentBid) <= 0) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendErrorResponse(response, "Bid must be higher than current bid");
            return;
        }
        
        // Use AuctionDAO to place the bid (this will save bid history)
        boolean bidPlaced = auctionDAO.placeBid(artworkId, currentUserId, bidAmount);
        
        if (!bidPlaced) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendErrorResponse(response, "Failed to place bid");
            return;
        }
        
        // Get updated artwork info
        artwork = artworkDAO.findById(artworkId);
        
        Map<String, Object> responseData = new HashMap<>();
        responseData.put("success", true);
        responseData.put("message", "Bid placed successfully");
        responseData.put("currentBid", artwork.getCurrentBid());
        responseData.put("bidCount", artwork.getBidCount());
        
        response.getWriter().write(gson.toJson(responseData));
    }
    
    /**
     * Handle artwork purchase
     */
    private void handlePurchaseArtwork(HttpServletRequest request, HttpServletResponse response, String artworkId) 
            throws IOException, ExecutionException, InterruptedException {
        
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Authentication required");
            return;
        }
        
        // Get artwork
        Artwork artwork = artworkDAO.findById(artworkId);
        if (artwork == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            sendErrorResponse(response, "Artwork not found");
            return;
        }
        
        // Check if artwork is available for purchase
        if (artwork.getStatus() == Artwork.ArtworkStatus.SOLD) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendErrorResponse(response, "Artwork has already been sold");
            return;
        }
        
        // Check if artwork is for sale (not auction)
        if (artwork.getSaleType() == Artwork.SaleType.AUCTION) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendErrorResponse(response, "Cannot purchase auction items directly. Please place a bid instead.");
            return;
        }
        
        // Check if user is trying to buy their own artwork
        if (currentUserId.equals(artwork.getArtistId())) {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            sendErrorResponse(response, "Cannot purchase your own artwork");
            return;
        }
        
        try {
            // Parse JSON request body for purchase details
            StringBuilder jsonBuffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
            
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> requestData = gson.fromJson(jsonBuffer.toString(), mapType);
            
            String paymentMethod = (String) requestData.get("paymentMethod");
            String shippingAddress = (String) requestData.get("shippingAddress");
            String notes = (String) requestData.get("notes");
            
            // Validate required fields
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Payment method is required");
                return;
            }
            
            if (shippingAddress == null || shippingAddress.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Shipping address is required");
                return;
            }
            
            // Create purchase record
            Purchase purchase = new Purchase(
                artworkId,
                currentUserId,
                artwork.getArtistId(),
                artwork.getPrice()
            );
            
            // Set additional purchase details
            purchase.setPaymentMethod(paymentMethod);
            purchase.setShippingAddress(shippingAddress);
            purchase.setStatus("COMPLETED"); // Mark as completed after successful payment
            
            // Generate mock transaction ID (in real implementation, this would come from payment processor)
            purchase.setTransactionId("TXN_" + System.currentTimeMillis());
            
            // Add notes if provided
            if (notes != null && !notes.trim().isEmpty()) {
                purchase.setNotes(notes.trim());
            }
            
            // Atomically mark artwork as sold (prevents race conditions)
            boolean markedAsSold = artworkDAO.markArtworkAsSold(artworkId);
            
            if (!markedAsSold) {
                // Artwork was already sold by another transaction
                response.setStatus(HttpServletResponse.SC_CONFLICT);
                sendErrorResponse(response, "This artwork has already been sold. Please refresh and try another artwork.");
                return;
            }
            
            // Reload artwork to get updated soldAt timestamp
            artwork = artworkDAO.findById(artworkId);
            
            // Save purchase record
            String purchaseId = purchaseDAO.savePurchase(purchase);
            
            // Send purchase notifications to buyer and seller
            try {
                NotificationUtil.sendPurchaseNotifications(
                    artworkId, 
                    currentUserId, 
                    artwork.getArtistId(), 
                    purchaseId
                );
            } catch (Exception e) {
                logger.warn("Failed to send purchase notifications: {}", e.getMessage());
                // Continue even if notification fails - purchase is already completed
            }
            
            // Return success response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("message", "Purchase completed successfully");
            responseData.put("purchaseId", purchaseId);
            responseData.put("transactionId", purchase.getTransactionId());
            responseData.put("purchasePrice", purchase.getPurchasePrice());
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(gson.toJson(responseData));
            
            logger.info("Artwork purchased successfully: {} by user: {} for: {}", 
                       artworkId, currentUserId, purchase.getPurchasePrice());
            
        } catch (Exception e) {
            logger.error("Error processing purchase for artwork {}: {}", artworkId, e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Failed to process purchase");
        }
    }
    
    /**
     * Create new artwork
     */
    private void handleCreateArtwork(HttpServletRequest request, HttpServletResponse response) 
            throws IOException, ExecutionException, InterruptedException {
        
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Authentication required");
            return;
        }
        
        try {
            // Parse JSON request body
            StringBuilder jsonBuffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
            
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> requestData = gson.fromJson(jsonBuffer.toString(), mapType);
            
            // Validate required fields
            String title = (String) requestData.get("title");
            String description = (String) requestData.get("description");
            String category = (String) requestData.get("category");
            String listingType = (String) requestData.get("listingType");
            String imageUrl = (String) requestData.get("imageUrl");
            Object imageUrlsObj = requestData.get("imageUrls"); // Array of image URLs
            Object priceObj = requestData.get("price");
            
            // Handle multiple images - get from imageUrls array or fallback to single imageUrl
            java.util.List<String> imageUrls = new java.util.ArrayList<>();
            if (imageUrlsObj != null) {
                if (imageUrlsObj instanceof java.util.List) {
                    @SuppressWarnings("unchecked")
                    java.util.List<Object> urlsList = (java.util.List<Object>) imageUrlsObj;
                    for (Object url : urlsList) {
                        if (url != null) {
                            imageUrls.add(url.toString().trim());
                        }
                    }
                }
            }
            
            // Fallback to single imageUrl if imageUrls is empty
            if (imageUrls.isEmpty() && imageUrl != null && !imageUrl.trim().isEmpty()) {
                imageUrls.add(imageUrl.trim());
            }
            
            // Validate we have at least one image
            if (imageUrls.isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "At least one image is required");
                return;
            }
            
            // Validate maximum 10 images
            if (imageUrls.size() > 10) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Maximum 10 images allowed");
                return;
            }
            
            if (title == null || title.trim().isEmpty() ||
                description == null || description.trim().isEmpty() ||
                category == null || category.trim().isEmpty() ||
                listingType == null || listingType.trim().isEmpty() ||
                priceObj == null) {
                
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Missing required fields");
                return;
            }
            
            // Convert price to BigDecimal
            BigDecimal price;
            try {
                if (priceObj instanceof Double) {
                    price = BigDecimal.valueOf((Double) priceObj);
                } else if (priceObj instanceof String) {
                    price = new BigDecimal((String) priceObj);
                } else {
                    throw new NumberFormatException("Invalid price format");
                }
            } catch (NumberFormatException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Invalid price format");
                return;
            }
            
            // Create artwork object
            Artwork artwork = new Artwork();
            artwork.setTitle(title.trim());
            artwork.setDescription(description.trim());
            artwork.setArtistId(currentUserId);
            
            // Set primary image (first image) and all images
            artwork.setPrimaryImageUrl(imageUrls.get(0));
            artwork.setImageUrls(imageUrls);
            artwork.setPrice(price);
            
            // Set category
            try {
                artwork.setCategory(Artwork.ArtCategory.valueOf(category.toUpperCase()));
            } catch (IllegalArgumentException e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Invalid category");
                return;
            }
            
            // Set listing type
            if ("FIXED_PRICE".equals(listingType)) {
                artwork.setSaleType(Artwork.SaleType.FIXED_PRICE);
                artwork.setStatus(Artwork.ArtworkStatus.ACTIVE);
            } else if ("AUCTION".equals(listingType)) {
                artwork.setSaleType(Artwork.SaleType.AUCTION);
                artwork.setStatus(Artwork.ArtworkStatus.ACTIVE);
                artwork.setStartingBid(price);
                artwork.setCurrentBid(price);
                artwork.setBidCount(0);
                artwork.setAuctionStartTime(LocalDateTime.now());
                
                // Handle auction end time
                String auctionEndTime = (String) requestData.get("auctionEndTime");
                if (auctionEndTime != null && !auctionEndTime.trim().isEmpty()) {
                    try {
                        LocalDateTime endTime = LocalDateTime.parse(auctionEndTime, 
                            DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm"));
                        
                        // Validate auction end time constraints
                        LocalDateTime now = LocalDateTime.now();
                        LocalDateTime minTime = now.plusMinutes(5); // Minimum: 5 minutes from now
                        LocalDateTime maxTime = now.plusDays(30); // Maximum: 30 days from now
                        
                        if (endTime.isBefore(minTime)) {
                            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                            sendErrorResponse(response, "Auction end time must be at least 5 minutes from now");
                            return;
                        }
                        
                        if (endTime.isAfter(maxTime)) {
                            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                            sendErrorResponse(response, "Auction end time cannot be more than 30 days from now");
                            return;
                        }
                        
                        artwork.setAuctionEndTime(endTime);
                    } catch (Exception e) {
                        response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                        sendErrorResponse(response, "Invalid auction end time format");
                        return;
                    }
                } else {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    sendErrorResponse(response, "Auction end time is required for auctions");
                    return;
                }
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                sendErrorResponse(response, "Invalid listing type");
                return;
            }
            
            // Handle optional fields
            Boolean isFeatured = (Boolean) requestData.get("isFeatured");
            if (isFeatured != null && isFeatured) {
                // For now, just log that featured was requested
                // In a real system, you might have restrictions on who can feature artworks
                logger.info("Featured artwork requested for: {}", title);
            }
            
            // Set defaults
            artwork.setCurrency("MYR");
            artwork.setOriginal(true);
            artwork.setShippingAvailable(true);
            artwork.setCreatedAt(LocalDateTime.now());
            artwork.setUpdatedAt(LocalDateTime.now());
            
            // Save artwork to database
            String artworkId = artworkDAO.saveArtwork(artwork);
            
            // Return success response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("message", "Artwork created successfully");
            responseData.put("artworkId", artworkId);
            responseData.put("artwork", artwork);
            
            response.setStatus(HttpServletResponse.SC_CREATED);
            response.getWriter().write(gson.toJson(responseData));
            
            logger.info("Artwork created successfully: {} by user: {}", artworkId, currentUserId);
            
        } catch (Exception e) {
            logger.error("Error creating artwork: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Failed to create artwork");
        }
    }

    /**
     * Update artwork (seller only)
     */
    private void handleUpdateArtwork(HttpServletRequest request, HttpServletResponse response, String artworkId) 
            throws IOException, ExecutionException, InterruptedException {
        
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Authentication required");
            return;
        }
        
        // Get current user to check role
        com.artexchange.dao.UserDAO userDAO = new com.artexchange.dao.UserDAO();
        com.artexchange.model.User currentUser = userDAO.findById(currentUserId);
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "User not found");
            return;
        }
        
        // SECURITY: Only sellers (ARTIST role) can edit artworks
        if (currentUser.getRole() != com.artexchange.model.User.UserRole.ARTIST) {
            logger.warn("Non-seller attempted to edit artwork. User ID: {}, Role: {}", currentUserId, currentUser.getRole());
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            sendErrorResponse(response, "Only sellers can edit artworks");
            return;
        }
        
        // Get artwork to verify ownership
        Artwork artwork = artworkDAO.findById(artworkId);
        if (artwork == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            sendErrorResponse(response, "Artwork not found");
            return;
        }
        
        // SECURITY: Only the artwork owner can edit it
        if (!currentUserId.equals(artwork.getArtistId())) {
            logger.warn("User attempted to edit artwork they don't own. User ID: {}, Artwork Owner ID: {}", 
                       currentUserId, artwork.getArtistId());
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            sendErrorResponse(response, "You can only edit your own artworks");
            return;
        }
        
        try {
            // Parse JSON request body
            StringBuilder jsonBuffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            while ((line = reader.readLine()) != null) {
                jsonBuffer.append(line);
            }
            
            Type mapType = new TypeToken<Map<String, Object>>(){}.getType();
            Map<String, Object> requestData = gson.fromJson(jsonBuffer.toString(), mapType);
            
            // Update allowed fields
            if (requestData.containsKey("title")) {
                artwork.setTitle((String) requestData.get("title"));
            }
            if (requestData.containsKey("description")) {
                artwork.setDescription((String) requestData.get("description"));
            }
            if (requestData.containsKey("category")) {
                try {
                    artwork.setCategory(Artwork.ArtCategory.valueOf(((String) requestData.get("category")).toUpperCase()));
                } catch (IllegalArgumentException e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    sendErrorResponse(response, "Invalid category");
                    return;
                }
            }
            if (requestData.containsKey("price")) {
                Object priceObj = requestData.get("price");
                try {
                    BigDecimal price;
                    if (priceObj instanceof Double) {
                        price = BigDecimal.valueOf((Double) priceObj);
                    } else if (priceObj instanceof String) {
                        price = new BigDecimal((String) priceObj);
                    } else {
                        throw new NumberFormatException("Invalid price format");
                    }
                    artwork.setPrice(price);
                } catch (NumberFormatException e) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    sendErrorResponse(response, "Invalid price format");
                    return;
                }
            }
            // Handle image updates - support both single imageUrl and multiple imageUrls
            if (requestData.containsKey("imageUrls")) {
                Object imageUrlsObj = requestData.get("imageUrls");
                java.util.List<String> imageUrls = new java.util.ArrayList<>();
                
                if (imageUrlsObj instanceof java.util.List) {
                    @SuppressWarnings("unchecked")
                    java.util.List<Object> urlsList = (java.util.List<Object>) imageUrlsObj;
                    for (Object url : urlsList) {
                        if (url != null) {
                            imageUrls.add(url.toString().trim());
                        }
                    }
                }
                
                // Validate image count
                if (imageUrls.size() > 10) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    sendErrorResponse(response, "Maximum 10 images allowed");
                    return;
                }
                
                if (!imageUrls.isEmpty()) {
                    artwork.setImageUrls(imageUrls);
                    artwork.setPrimaryImageUrl(imageUrls.get(0)); // Set first image as primary
                }
            } else if (requestData.containsKey("imageUrl") || requestData.containsKey("primaryImageUrl")) {
                String imageUrl = (String) (requestData.get("imageUrl") != null ? 
                    requestData.get("imageUrl") : requestData.get("primaryImageUrl"));
                artwork.setPrimaryImageUrl(imageUrl);
                // If updating single image, update the list too
                if (artwork.getImageUrls() == null || artwork.getImageUrls().isEmpty()) {
                    java.util.List<String> imageUrls = new java.util.ArrayList<>();
                    imageUrls.add(imageUrl);
                    artwork.setImageUrls(imageUrls);
                } else {
                    // Replace first image in the list
                    artwork.getImageUrls().set(0, imageUrl);
                }
            }
            
            // Update timestamp
            artwork.setUpdatedAt(LocalDateTime.now());
            
            // Save updated artwork
            artworkDAO.updateArtwork(artwork);
            
            // Return success response with updated artwork
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("message", "Artwork updated successfully");
            responseData.put("artwork", artwork);
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(gson.toJson(responseData));
            
            logger.info("Artwork updated successfully: {} by user: {}", artworkId, currentUserId);
            
        } catch (Exception e) {
            logger.error("Error updating artwork: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Failed to update artwork");
        }
    }
    
    /**
     * Delete artwork (seller only)
     */
    private void handleDeleteArtwork(HttpServletRequest request, HttpServletResponse response, String artworkId) 
            throws IOException, ExecutionException, InterruptedException {
        
        String currentUserId = SessionUtil.getCurrentUserId(request);
        if (currentUserId == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "Authentication required");
            return;
        }
        
        // Get current user to check role
        com.artexchange.dao.UserDAO userDAO = new com.artexchange.dao.UserDAO();
        com.artexchange.model.User currentUser = userDAO.findById(currentUserId);
        
        if (currentUser == null) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            sendErrorResponse(response, "User not found");
            return;
        }
        
        // SECURITY: Only sellers (ARTIST role) can delete artworks
        if (currentUser.getRole() != com.artexchange.model.User.UserRole.ARTIST) {
            logger.warn("Non-seller attempted to delete artwork. User ID: {}, Role: {}", currentUserId, currentUser.getRole());
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            sendErrorResponse(response, "Only sellers can delete artworks");
            return;
        }
        
        // Get artwork to verify ownership
        Artwork artwork = artworkDAO.findById(artworkId);
        if (artwork == null) {
            response.setStatus(HttpServletResponse.SC_NOT_FOUND);
            sendErrorResponse(response, "Artwork not found");
            return;
        }
        
        // SECURITY: Only the artwork owner can delete it
        if (!currentUserId.equals(artwork.getArtistId())) {
            logger.warn("User attempted to delete artwork they don't own. User ID: {}, Artwork Owner ID: {}", 
                       currentUserId, artwork.getArtistId());
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            sendErrorResponse(response, "You can only delete your own artworks");
            return;
        }
        
        try {
            // Delete artwork
            artworkDAO.deleteArtwork(artworkId);
            
            // Return success response
            Map<String, Object> responseData = new HashMap<>();
            responseData.put("success", true);
            responseData.put("message", "Artwork deleted successfully");
            responseData.put("artworkId", artworkId);
            
            response.setStatus(HttpServletResponse.SC_OK);
            response.getWriter().write(gson.toJson(responseData));
            
            logger.info("Artwork deleted successfully: {} by user: {}", artworkId, currentUserId);
            
        } catch (Exception e) {
            logger.error("Error deleting artwork: {}", e.getMessage(), e);
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            sendErrorResponse(response, "Failed to delete artwork");
        }
    }

    /**
     * Send error response
     */
    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        Map<String, Object> errorData = new HashMap<>();
        errorData.put("success", false);
        errorData.put("message", message);
        
        response.getWriter().write(gson.toJson(errorData));
    }
}
