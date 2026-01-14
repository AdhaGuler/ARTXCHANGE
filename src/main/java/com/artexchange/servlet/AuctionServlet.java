package com.artexchange.servlet;

import com.artexchange.dao.AuctionDAO;
import com.artexchange.dao.ArtworkDAO;
import com.artexchange.dao.UserDAO;
import com.artexchange.model.Auction;
import com.artexchange.model.Artwork;
import com.artexchange.model.User;
import com.artexchange.util.GsonUtil;
import com.artexchange.util.SessionUtil;
import com.artexchange.util.AuctionProcessor;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import com.google.gson.Gson;
import com.google.gson.JsonObject;
import java.time.LocalDateTime;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.BufferedReader;
import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;

@WebServlet("/api/auctions/*")
public class AuctionServlet extends HttpServlet {
    private static final Logger logger = Logger.getLogger(AuctionServlet.class.getName());
    private final AuctionDAO auctionDAO = new AuctionDAO();
    private final ArtworkDAO artworkDAO = new ArtworkDAO();
    private final UserDAO userDAO = new UserDAO();
    private final Gson gson = GsonUtil.getGson();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo == null || pathInfo.equals("/")) {
                // Get all auctions with optional filters
                handleGetAuctions(request, response);
            } else if (pathInfo.equals("/stats")) {
                handleGetStats(request, response);
            } else if (pathInfo.equals("/featured")) {
                handleGetFeaturedAuctions(request, response);
            } else if (pathInfo.equals("/process-ended")) {
                handleProcessEndedAuctions(request, response);
            } else if (pathInfo.matches("/[^/]+/process-end")) {
                // Process a specific auction
                String auctionId = pathInfo.substring(1, pathInfo.length() - "/process-end".length());
                handleProcessSpecificAuction(request, response, auctionId);
            } else if (pathInfo.matches("/[^/]+")) {
                // Get specific auction by ID
                String auctionId = pathInfo.substring(1);
                handleGetAuction(request, response, auctionId);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"success\": false, \"message\": \"Endpoint not found\"}");
            }
        } catch (Exception e) {
            logger.severe("Error in AuctionServlet: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Internal server error\"}");
        }
    }

    private void handleGetStats(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Get real stats from Firebase
            Map<String, Object> stats = auctionDAO.getAuctionStats();
            stats.put("success", true);
            
            response.getWriter().write(GsonUtil.getGson().toJson(stats));
        } catch (Exception e) {
            logger.severe("Error getting auction stats: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error getting stats\"}");
        }
    }

    private void handleGetFeaturedAuctions(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Get featured auctions from Firebase
            List<Auction> auctions = auctionDAO.getFeaturedAuctions();
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("auctions", auctions);
            
            response.getWriter().write(GsonUtil.getGson().toJson(result));
        } catch (Exception e) {
            logger.severe("Error getting featured auctions: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error getting featured auctions\"}");
        }
    }

    private void handleGetAuctions(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            // Get all auctions from Firebase
            List<Auction> auctions = auctionDAO.getAllAuctions();
            
            // For now, implement simple pagination
            int page = 1;
            int limit = 9;
            try {
                page = Integer.parseInt(request.getParameter("page"));
            } catch (NumberFormatException e) {
                // Use default page 1
            }
            try {
                limit = Integer.parseInt(request.getParameter("limit"));
            } catch (NumberFormatException e) {
                // Use default limit 9
            }
            
            int totalCount = auctions.size();
            int totalPages = (int) Math.ceil((double) totalCount / limit);
            int startIndex = (page - 1) * limit;
            int endIndex = Math.min(startIndex + limit, totalCount);
            
            List<Auction> paginatedAuctions = startIndex < totalCount ? 
                auctions.subList(startIndex, endIndex) : List.of();
            
            // Enrich auctions with winner information for sold auctions
            List<Map<String, Object>> enrichedAuctions = new ArrayList<>();
            for (Auction auction : paginatedAuctions) {
                Map<String, Object> auctionMap = convertAuctionToMap(auction);
                enrichedAuctions.add(auctionMap);
            }
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("auctions", enrichedAuctions);
            result.put("totalCount", totalCount);
            result.put("page", page);
            result.put("totalPages", totalPages);
            
            response.getWriter().write(GsonUtil.getGson().toJson(result));
        } catch (Exception e) {
            logger.severe("Error getting auctions: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error getting auctions\"}");
        }
    }

    private void handleGetAuction(HttpServletRequest request, HttpServletResponse response, String auctionId) 
            throws IOException {
        try {
            // Get specific auction from Firebase
            Auction auction = auctionDAO.getAuctionById(auctionId);
            
            if (auction != null) {
                // Enrich auction with winner information
                Map<String, Object> auctionMap = convertAuctionToMap(auction);
                
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("auction", auctionMap);
                response.getWriter().write(GsonUtil.getGson().toJson(result));
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"success\": false, \"message\": \"Auction not found\"}");
            }
        } catch (Exception e) {
            logger.severe("Error getting auction: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error getting auction\"}");
        }
    }
    
    /**
     * Convert Auction to Map and enrich with winner information from artwork
     */
    private Map<String, Object> convertAuctionToMap(Auction auction) {
        Map<String, Object> map = new HashMap<>();
        
        // Add all auction fields
        map.put("id", auction.getId());
        map.put("title", auction.getTitle());
        map.put("description", auction.getDescription());
        map.put("artistId", auction.getArtistId());
        map.put("artworkId", auction.getArtworkId());
        map.put("primaryImageUrl", auction.getPrimaryImageUrl());
        map.put("medium", auction.getMedium());
        map.put("price", auction.getPrice());
        map.put("startingBid", auction.getStartingBid());
        map.put("currentBid", auction.getCurrentBid());
        map.put("bidCount", auction.getBidCount());
        map.put("saleType", auction.getSaleType());
        map.put("status", auction.getStatus());
        map.put("shippingCost", auction.getShippingCost());
        map.put("tags", auction.getTags());
        map.put("views", auction.getViews());
        map.put("yearCreated", auction.getYearCreated());
        map.put("createdAt", auction.getCreatedAt());
        map.put("updatedAt", auction.getUpdatedAt());
        map.put("endTime", auction.getEndTime());
        map.put("auctionEndTime", auction.getEndTime()); // Also include as auctionEndTime for compatibility
        
        // For sold auctions, get winner information from artwork
        if ("SOLD".equals(auction.getStatus()) && auction.getId() != null) {
            try {
                Artwork artwork = artworkDAO.findById(auction.getId());
                if (artwork != null) {
                    map.put("winnerId", artwork.getWinnerId());
                    map.put("winnerName", artwork.getWinnerName());
                    if (artwork.getWinningBidAmount() != null) {
                        map.put("winningBidAmount", artwork.getWinningBidAmount().doubleValue());
                    }
                    map.put("endedAt", artwork.getEndedAt());
                }
            } catch (Exception e) {
                logger.warning("Error fetching winner information for auction " + auction.getId() + ": " + e.getMessage());
            }
        }
        
        // Also get artist name
        try {
            if (auction.getArtistId() != null) {
                User artist = userDAO.findById(auction.getArtistId());
                if (artist != null) {
                    map.put("artistName", artist.getDisplayName());
                }
            }
        } catch (Exception e) {
            logger.warning("Error fetching artist name for auction " + auction.getId() + ": " + e.getMessage());
        }
        
        return map;
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo != null && pathInfo.matches("/[^/]+/bid")) {
                // Handle bidding - extract auction ID from path
                String auctionId = pathInfo.split("/")[1];
                handlePlaceBid(request, response, auctionId);
            } else {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"success\": false, \"message\": \"Endpoint not found\"}");
            }
        } catch (Exception e) {
            logger.severe("Error in AuctionServlet POST: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Internal server error\"}");
        }
    }

    private void handlePlaceBid(HttpServletRequest request, HttpServletResponse response, String auctionId) 
            throws IOException {
        try {
            logger.info("Placing bid for auction ID: " + auctionId);

            // Parse request body ONCE (can only be read once)
            JsonObject requestData = parseRequestBody(request);
            
            // Try to authenticate using Firebase ID token first
            User authenticatedUser = null;
            
            // Check Authorization header for Bearer token
            String authHeader = request.getHeader("Authorization");
            String idToken = null;
            
            if (authHeader != null && authHeader.startsWith("Bearer ")) {
                idToken = authHeader.substring(7);
                logger.info("Found Authorization header with Bearer token");
            }
            
            // If no Authorization header, try to get idToken from parsed request body
            if (idToken == null && requestData != null && requestData.has("idToken")) {
                idToken = requestData.get("idToken").getAsString();
                logger.info("Found idToken in request body");
            }
            
            // Verify Firebase token if present
            if (idToken != null) {
                try {
                    FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
                    String firebaseUid = decodedToken.getUid();
                    
                    authenticatedUser = userDAO.findByFirebaseUid(firebaseUid);
                    if (authenticatedUser != null) {
                        logger.info("Successfully authenticated user via Firebase token: " + authenticatedUser.getEmail());
                        // Create session for this request if user is found
                        SessionUtil.createUserSession(request, authenticatedUser);
                    }
                } catch (Exception e) {
                    logger.warning("Failed to verify Firebase token: " + e.getMessage());
                }
            }
            
            // Fall back to session-based authentication if Firebase auth failed
            if (authenticatedUser == null) {
                authenticatedUser = SessionUtil.getCurrentUser(request);
                if (authenticatedUser != null) {
                    logger.info("Using session-based authentication for user: " + authenticatedUser.getEmail());
                } else {
                    logger.warning("Session check failed - no user in session. Session exists: " + (request.getSession(false) != null));
                }
            }
            
            // If still no authenticated user, return unauthorized
            if (authenticatedUser == null) {
                logger.warning("No authenticated user found for bid request");
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\": false, \"message\": \"User not authenticated\"}");
                return;
            }

            logger.info("Authenticated user for bid: " + authenticatedUser.getEmail() + " (ID: " + authenticatedUser.getUserId() + ")");

            // SECURITY: Prevent auction owner from bidding on their own auction
            Auction auction = auctionDAO.getAuctionById(auctionId);
            if (auction == null) {
                logger.warning("Auction not found: " + auctionId);
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"success\": false, \"error\": \"Auction not found\"}");
                return;
            }
            
            if (auction.getArtistId() != null && auction.getArtistId().equals(authenticatedUser.getUserId())) {
                logger.warning("Auction owner attempted to bid on their own auction. User ID: " + authenticatedUser.getUserId() + ", Auction ID: " + auctionId);
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\": false, \"error\": \"Owners cannot bid on their own auctions.\"}");
                return;
            }
            
            // Check if auction has ended
            if (auction.getStatus() != null && (auction.getStatus().equals("ENDED") || auction.getStatus().equals("CANCELED") || auction.getStatus().equals("INACTIVE"))) {
                logger.warning("Attempt to bid on ended/canceled auction. Auction ID: " + auctionId + ", Status: " + auction.getStatus());
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"error\": \"Auction is not active\"}");
                return;
            }
            
            // Check if end time has passed
            if (auction.getEndTime() != null && auction.getEndTime().isBefore(java.time.LocalDateTime.now())) {
                logger.warning("Attempt to bid on expired auction. Auction ID: " + auctionId + ", End time: " + auction.getEndTime());
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"error\": \"Auction has ended\"}");
                return;
            }

            // Get bid amount from already-parsed request body
            if (requestData == null || !requestData.has("amount")) {
                logger.warning("No bid amount provided in request. Request data: " + (requestData != null ? requestData.toString() : "null"));
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Bid amount is required\"}");
                return;
            }
            
            double bidAmount;
            try {
                bidAmount = requestData.get("amount").getAsDouble();
                logger.info("Parsed bid amount: " + bidAmount);
            } catch (Exception e) {
                logger.warning("Invalid bid amount format: " + e.getMessage());
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Invalid bid amount format\"}");
                return;
            }
            
            // Place the bid
            boolean bidPlaced = auctionDAO.placeBid(auctionId, authenticatedUser.getUserId(), bidAmount);
            
            if (bidPlaced) {
                logger.info("Bid placed successfully for auction " + auctionId + " by user " + authenticatedUser.getUserId() + " with amount " + bidAmount);
                
                Map<String, Object> result = new HashMap<>();
                result.put("success", true);
                result.put("message", "Bid placed successfully");
                result.put("bidAmount", bidAmount);
                result.put("auctionId", auctionId);
                result.put("userId", authenticatedUser.getUserId());
                
                response.getWriter().write(GsonUtil.getGson().toJson(result));
            } else {
                logger.warning("Failed to place bid for auction " + auctionId);
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Failed to place bid. Your bid may not be high enough or the auction may no longer be active.\"}");
            }
        } catch (Exception e) {
            logger.severe("Error placing bid: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error placing bid\"}");
        }
    }

    @Override
    protected void doPut(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo != null && pathInfo.matches("/[^/]+/end")) {
                // End auction manually
                String auctionId = pathInfo.substring(1, pathInfo.length() - "/end".length());
                handleEndAuction(request, response, auctionId);
            } else if (pathInfo != null && pathInfo.matches("/[^/]+")) {
                String auctionId = pathInfo.substring(1);
                handleUpdateAuction(request, response, auctionId);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Auction ID is required\"}");
            }
        } catch (Exception e) {
            logger.severe("Error in AuctionServlet PUT: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Internal server error\"}");
        }
    }
    
    @Override
    protected void doDelete(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        String pathInfo = request.getPathInfo();
        
        try {
            if (pathInfo != null && pathInfo.matches("/[^/]+")) {
                String auctionId = pathInfo.substring(1);
                handleDeleteAuction(request, response, auctionId);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Auction ID is required\"}");
            }
        } catch (Exception e) {
            logger.severe("Error in AuctionServlet DELETE: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Internal server error\"}");
        }
    }
    
    /**
     * End auction manually (seller only)
     */
    private void handleEndAuction(HttpServletRequest request, HttpServletResponse response, String auctionId) 
            throws IOException {
        try {
            String currentUserId = SessionUtil.getCurrentUserId(request);
            if (currentUserId == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\": false, \"message\": \"Authentication required\"}");
                return;
            }
            
            // Get current user to check role
            User currentUser = userDAO.findById(currentUserId);
            if (currentUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\": false, \"message\": \"User not found\"}");
                return;
            }
            
            // SECURITY: Only sellers (ARTIST role) can end auctions
            if (currentUser.getRole() != User.UserRole.ARTIST) {
                logger.warning("Non-seller attempted to end auction. User ID: " + currentUserId + ", Role: " + currentUser.getRole());
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\": false, \"message\": \"Only sellers can end auctions\"}");
                return;
            }
            
            // Get artwork (auction is stored as artwork with saleType=AUCTION)
            Artwork artwork = artworkDAO.findById(auctionId);
            if (artwork == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"success\": false, \"message\": \"Auction not found\"}");
                return;
            }
            
            // Verify it's an auction
            if (artwork.getSaleType() != Artwork.SaleType.AUCTION) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"This artwork is not an auction\"}");
                return;
            }
            
            // SECURITY: Only the auction owner can end it
            if (!currentUserId.equals(artwork.getArtistId())) {
                logger.warning("User attempted to end auction they don't own. User ID: " + currentUserId + ", Auction Owner ID: " + artwork.getArtistId());
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\": false, \"message\": \"You can only end your own auctions\"}");
                return;
            }
            
            // Check if auction is already ended
            if (artwork.getStatus() == Artwork.ArtworkStatus.SOLD || 
                artwork.getStatus() == Artwork.ArtworkStatus.INACTIVE) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Auction is already ended\"}");
                return;
            }
            
            // Mark auction as ended by setting end time to now
            artwork.setAuctionEndTime(LocalDateTime.now());
            artwork.setEndedAt(LocalDateTime.now());
            artwork.setUpdatedAt(LocalDateTime.now());
            artworkDAO.updateArtwork(artwork);
            
            // Process the ended auction (determine winner, create purchase, etc.)
            try {
                AuctionProcessor.processEndedAuction(auctionId);
            } catch (Exception e) {
                logger.warning("Error processing ended auction: " + e.getMessage());
                // Continue even if processing fails - auction is still marked as ended
            }
            
            // Return success response
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Auction ended successfully");
            result.put("auctionId", auctionId);
            
            response.getWriter().write(GsonUtil.getGson().toJson(result));
            logger.info("Auction ended successfully: " + auctionId + " by user: " + currentUserId);
            
        } catch (Exception e) {
            logger.severe("Error ending auction: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error ending auction: " + e.getMessage() + "\"}");
        }
    }
    
    /**
     * Update auction description (seller only)
     */
    private void handleUpdateAuction(HttpServletRequest request, HttpServletResponse response, String auctionId) 
            throws IOException {
        try {
            String currentUserId = SessionUtil.getCurrentUserId(request);
            if (currentUserId == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\": false, \"message\": \"Authentication required\"}");
                return;
            }
            
            // Get current user to check role
            User currentUser = userDAO.findById(currentUserId);
            if (currentUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\": false, \"message\": \"User not found\"}");
                return;
            }
            
            // SECURITY: Only sellers (ARTIST role) can edit auctions
            if (currentUser.getRole() != User.UserRole.ARTIST) {
                logger.warning("Non-seller attempted to edit auction. User ID: " + currentUserId + ", Role: " + currentUser.getRole());
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\": false, \"message\": \"Only sellers can edit auctions\"}");
                return;
            }
            
            // Get artwork (auction is stored as artwork with saleType=AUCTION)
            Artwork artwork = artworkDAO.findById(auctionId);
            if (artwork == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"success\": false, \"message\": \"Auction not found\"}");
                return;
            }
            
            // Verify it's an auction
            if (artwork.getSaleType() != Artwork.SaleType.AUCTION) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"This artwork is not an auction\"}");
                return;
            }
            
            // SECURITY: Only the auction owner can edit it
            if (!currentUserId.equals(artwork.getArtistId())) {
                logger.warning("User attempted to edit auction they don't own. User ID: " + currentUserId + ", Auction Owner ID: " + artwork.getArtistId());
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\": false, \"message\": \"You can only edit your own auctions\"}");
                return;
            }
            
            // Parse JSON request body
            JsonObject requestData = parseRequestBody(request);
            if (requestData == null || !requestData.has("description")) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Description is required\"}");
                return;
            }
            
            // Update description
            String description = requestData.get("description").getAsString();
            if (description == null || description.trim().isEmpty()) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"Description cannot be empty\"}");
                return;
            }
            
            artwork.setDescription(description.trim());
            artwork.setUpdatedAt(LocalDateTime.now());
            
            // Save updated artwork
            artworkDAO.updateArtwork(artwork);
            
            // Return success response
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Auction description updated successfully");
            result.put("auctionId", auctionId);
            
            response.getWriter().write(GsonUtil.getGson().toJson(result));
            logger.info("Auction description updated successfully: " + auctionId + " by user: " + currentUserId);
            
        } catch (Exception e) {
            logger.severe("Error updating auction: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error updating auction\"}");
        }
    }
    
    /**
     * Delete auction (seller only)
     */
    private void handleDeleteAuction(HttpServletRequest request, HttpServletResponse response, String auctionId) 
            throws IOException {
        try {
            String currentUserId = SessionUtil.getCurrentUserId(request);
            if (currentUserId == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\": false, \"message\": \"Authentication required\"}");
                return;
            }
            
            // Get current user to check role
            User currentUser = userDAO.findById(currentUserId);
            if (currentUser == null) {
                response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.getWriter().write("{\"success\": false, \"message\": \"User not found\"}");
                return;
            }
            
            // SECURITY: Only sellers (ARTIST role) can delete auctions
            if (currentUser.getRole() != User.UserRole.ARTIST) {
                logger.warning("Non-seller attempted to delete auction. User ID: " + currentUserId + ", Role: " + currentUser.getRole());
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\": false, \"message\": \"Only sellers can delete auctions\"}");
                return;
            }
            
            // Get artwork (auction is stored as artwork with saleType=AUCTION)
            Artwork artwork = artworkDAO.findById(auctionId);
            if (artwork == null) {
                response.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.getWriter().write("{\"success\": false, \"message\": \"Auction not found\"}");
                return;
            }
            
            // Verify it's an auction
            if (artwork.getSaleType() != Artwork.SaleType.AUCTION) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("{\"success\": false, \"message\": \"This artwork is not an auction\"}");
                return;
            }
            
            // SECURITY: Only the auction owner can delete it
            if (!currentUserId.equals(artwork.getArtistId())) {
                logger.warning("User attempted to delete auction they don't own. User ID: " + currentUserId + ", Auction Owner ID: " + artwork.getArtistId());
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.getWriter().write("{\"success\": false, \"message\": \"You can only delete your own auctions\"}");
                return;
            }
            
            // Delete artwork (auction)
            artworkDAO.deleteArtwork(auctionId);
            
            // Return success response
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Auction deleted successfully");
            result.put("auctionId", auctionId);
            
            response.getWriter().write(GsonUtil.getGson().toJson(result));
            logger.info("Auction deleted successfully: " + auctionId + " by user: " + currentUserId);
            
        } catch (Exception e) {
            logger.severe("Error deleting auction: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error deleting auction\"}");
        }
    }

    /**
     * Process all ended auctions that haven't been processed yet
     * This can be called manually or by a scheduled job
     */
    private void handleProcessEndedAuctions(HttpServletRequest request, HttpServletResponse response) 
            throws IOException {
        try {
            logger.info("Processing ended auctions...");
            
            // Process all ended auctions
            AuctionProcessor.processAllEndedAuctions();
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Ended auctions processed successfully");
            
            response.getWriter().write(GsonUtil.getGson().toJson(result));
            logger.info("Successfully processed ended auctions");
            
        } catch (Exception e) {
            logger.severe("Error processing ended auctions: " + e.getMessage());
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("{\"success\": false, \"message\": \"Error processing ended auctions\"}");
        }
    }
    
    /**
     * Process a specific auction by ID
     * Useful for testing or manually triggering auction end processing
     */
    private void handleProcessSpecificAuction(HttpServletRequest request, HttpServletResponse response, String artworkId) 
            throws IOException {
        try {
            logger.info("Processing specific auction: " + artworkId);
            
            // Process the specific auction
            AuctionProcessor.processEndedAuction(artworkId);
            
            Map<String, Object> result = new HashMap<>();
            result.put("success", true);
            result.put("message", "Auction processed successfully");
            result.put("artworkId", artworkId);
            
            response.getWriter().write(GsonUtil.getGson().toJson(result));
            logger.info("Successfully processed auction: " + artworkId);
            
        } catch (Exception e) {
            logger.severe("Error processing auction: " + e.getMessage());
            e.printStackTrace();
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            Map<String, Object> error = new HashMap<>();
            error.put("success", false);
            error.put("message", "Error processing auction: " + e.getMessage());
            response.getWriter().write(GsonUtil.getGson().toJson(error));
        }
    }
    
    /**
     * Parse JSON request body
     */
    private JsonObject parseRequestBody(HttpServletRequest request) {
        try {
            StringBuilder buffer = new StringBuilder();
            BufferedReader reader = request.getReader();
            String line;
            
            while ((line = reader.readLine()) != null) {
                buffer.append(line);
            }
            
            String jsonString = buffer.toString();
            if (jsonString.trim().isEmpty()) {
                return null;
            }
            
            return gson.fromJson(jsonString, JsonObject.class);
        } catch (Exception e) {
            logger.warning("Failed to parse request body as JSON: " + e.getMessage());
            return null;
        }
    }
}