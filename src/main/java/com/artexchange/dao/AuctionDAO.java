package com.artexchange.dao;

import com.artexchange.model.Auction;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import com.google.firebase.cloud.FirestoreClient;

import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;
import java.util.concurrent.ExecutionException;
import java.util.logging.Logger;

public class AuctionDAO {
    private static final Logger logger = Logger.getLogger(AuctionDAO.class.getName());
    private final Firestore db;
    
    public AuctionDAO() {
        this.db = FirestoreClient.getFirestore();
    }
    
    public List<Auction> getAllAuctions() {
        try {
            logger.info("Querying Firebase for auctions with saleType=AUCTION (including SOLD auctions)");
            
            // Query for both ACTIVE and SOLD auctions
            ApiFuture<QuerySnapshot> future = db.collection("artworks")
                    .whereEqualTo("saleType", "AUCTION")
                    .whereIn("status", Arrays.asList("ACTIVE", "SOLD"))
                    .get();
                    
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            logger.info("Found " + documents.size() + " documents matching auction criteria");
            
            List<Auction> auctions = new ArrayList<>();
            
            for (QueryDocumentSnapshot document : documents) {
                logger.info("Processing document: " + document.getId());
                logger.info("Document data: " + document.getData());
                
                Auction auction = convertDocumentToAuction(document);
                if (auction != null) {
                    auctions.add(auction);
                    logger.info("Successfully converted auction: " + auction.getTitle());
                } else {
                    logger.warning("Failed to convert document to auction: " + document.getId());
                }
            }
            
            logger.info("Retrieved " + auctions.size() + " auctions from Firebase");
            
            // Sort auctions: ACTIVE first, then SOLD
            auctions.sort((a, b) -> {
                String statusA = a.getStatus() != null ? a.getStatus() : "";
                String statusB = b.getStatus() != null ? b.getStatus() : "";
                
                // ACTIVE comes before SOLD
                if ("ACTIVE".equals(statusA) && "SOLD".equals(statusB)) {
                    return -1;
                } else if ("SOLD".equals(statusA) && "ACTIVE".equals(statusB)) {
                    return 1;
                }
                return 0; // Same status, maintain order
            });
            
            logger.info("Sorted auctions: ACTIVE first, then SOLD");
            return auctions;
            
        } catch (InterruptedException | ExecutionException e) {
            logger.severe("Error fetching auctions: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    public List<Auction> getFeaturedAuctions() {
        try {
            logger.info("Querying Firebase for featured auctions");
            
            ApiFuture<QuerySnapshot> future = db.collection("artworks")
                    .whereEqualTo("saleType", "AUCTION")
                    .whereEqualTo("status", "ACTIVE")
                    .orderBy("views", Query.Direction.DESCENDING)
                    .limit(6)
                    .get();
                    
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            logger.info("Found " + documents.size() + " documents for featured auctions");
            
            List<Auction> auctions = new ArrayList<>();
            
            for (QueryDocumentSnapshot document : documents) {
                logger.info("Processing featured auction document: " + document.getId());
                
                Auction auction = convertDocumentToAuction(document);
                if (auction != null) {
                    auctions.add(auction);
                    logger.info("Successfully converted featured auction: " + auction.getTitle());
                } else {
                    logger.warning("Failed to convert featured auction document: " + document.getId());
                }
            }
            
            logger.info("Retrieved " + auctions.size() + " featured auctions from Firebase");
            return auctions;
            
        } catch (InterruptedException | ExecutionException e) {
            logger.severe("Error fetching featured auctions: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    public Auction getAuctionById(String id) {
        try {
            ApiFuture<DocumentSnapshot> future = db.collection("artworks").document(id).get();
            DocumentSnapshot document = future.get();
            
            if (document.exists()) {
                return convertDocumentToAuction(document);
            }
            
        } catch (InterruptedException | ExecutionException e) {
            logger.severe("Error fetching auction by ID: " + e.getMessage());
        }
        
        return null;
    }
    
    public Map<String, Object> getAuctionStats() {
        Map<String, Object> stats = new HashMap<>();
        
        try {
            // Count live auctions
            ApiFuture<QuerySnapshot> liveAuctions = db.collection("artworks")
                    .whereEqualTo("saleType", "AUCTION")
                    .whereEqualTo("status", "ACTIVE")
                    .get();
            
            int liveCount = liveAuctions.get().getDocuments().size();
            
            // For now, use simple calculations for other stats
            stats.put("liveCount", liveCount);
            stats.put("endingSoonCount", Math.min(liveCount, 5)); // Mock data for ending soon
            stats.put("featuredCount", Math.min(liveCount, 8)); // Mock data for featured
            
            logger.info("Auction stats - Live: " + liveCount + ", Ending Soon: " + stats.get("endingSoonCount") + ", Featured: " + stats.get("featuredCount"));
            
        } catch (InterruptedException | ExecutionException e) {
            logger.severe("Error fetching auction stats: " + e.getMessage());
            stats.put("liveCount", 0);
            stats.put("endingSoonCount", 0);
            stats.put("featuredCount", 0);
        }
        
        return stats;
    }
    
    private Auction convertDocumentToAuction(DocumentSnapshot document) {
        try {
            Auction auction = new Auction();
            auction.setId(document.getId());
            
            // Map all the fields from the Firebase document
            auction.setTitle(document.getString("title"));
            auction.setDescription(document.getString("description"));
            auction.setArtistId(document.getString("artistId"));
            auction.setArtworkId(document.getString("artworkId"));
            auction.setPrimaryImageUrl(document.getString("primaryImageUrl"));
            auction.setMedium(document.getString("medium"));
            
            // Handle numeric fields safely
            if (document.contains("price")) {
                Object priceObj = document.get("price");
                if (priceObj instanceof Number) {
                    auction.setPrice(((Number) priceObj).doubleValue());
                } else if (priceObj instanceof String) {
                    try {
                        auction.setPrice(Double.parseDouble((String) priceObj));
                    } catch (NumberFormatException e) {
                        logger.warning("Invalid price format for auction " + document.getId());
                    }
                }
            }
            
            if (document.contains("startingBid")) {
                Object startingBidObj = document.get("startingBid");
                if (startingBidObj instanceof Number) {
                    auction.setStartingBid(((Number) startingBidObj).doubleValue());
                } else if (startingBidObj instanceof String) {
                    try {
                        auction.setStartingBid(Double.parseDouble((String) startingBidObj));
                    } catch (NumberFormatException e) {
                        logger.warning("Invalid startingBid format for auction " + document.getId());
                    }
                }
            }
            
            // Handle current bid
            if (document.contains("currentBid")) {
                Object currentBidObj = document.get("currentBid");
                if (currentBidObj instanceof Number) {
                    auction.setCurrentBid(((Number) currentBidObj).doubleValue());
                } else if (currentBidObj instanceof String) {
                    try {
                        auction.setCurrentBid(Double.parseDouble((String) currentBidObj));
                    } catch (NumberFormatException e) {
                        logger.warning("Invalid currentBid format for auction " + document.getId());
                    }
                }
            } else {
                // If no current bid, use starting bid as current bid
                auction.setCurrentBid(auction.getStartingBid());
            }
            
            // Handle bid count
            if (document.contains("bidCount")) {
                Object bidCountObj = document.get("bidCount");
                if (bidCountObj instanceof Number) {
                    auction.setBidCount(((Number) bidCountObj).intValue());
                } else if (bidCountObj instanceof String) {
                    try {
                        auction.setBidCount(Integer.parseInt((String) bidCountObj));
                    } catch (NumberFormatException e) {
                        logger.warning("Invalid bidCount format for auction " + document.getId());
                    }
                }
            } else {
                // Default to 0 bids
                auction.setBidCount(0);
            }
            
            auction.setSaleType(document.getString("saleType"));
            auction.setStatus(document.getString("status"));
            
            if (document.contains("shippingCost")) {
                Object shippingObj = document.get("shippingCost");
                if (shippingObj instanceof Number) {
                    auction.setShippingCost(((Number) shippingObj).doubleValue());
                }
            }
            
            if (document.contains("tags")) {
                Object tagsObj = document.get("tags");
                if (tagsObj instanceof List) {
                    @SuppressWarnings("unchecked")
                    List<String> tags = (List<String>) tagsObj;
                    auction.setTags(tags);
                }
            }
            
            if (document.contains("views")) {
                Object viewsObj = document.get("views");
                if (viewsObj instanceof Number) {
                    auction.setViews(((Number) viewsObj).intValue());
                }
            }
            
            if (document.contains("yearCreated")) {
                Object yearObj = document.get("yearCreated");
                if (yearObj instanceof Number) {
                    auction.setYearCreated(((Number) yearObj).intValue());
                }
            }
            
            // Handle timestamp fields - they can be either Timestamp objects or String
            if (document.contains("createdAt")) {
                Object createdAtObj = document.get("createdAt");
                if (createdAtObj instanceof com.google.cloud.Timestamp) {
                    com.google.cloud.Timestamp timestamp = (com.google.cloud.Timestamp) createdAtObj;
                    auction.setCreatedAt(LocalDateTime.ofInstant(timestamp.toDate().toInstant(), ZoneId.systemDefault()));
                } else if (createdAtObj instanceof String) {
                    try {
                        // Parse string timestamp like "2025-06-09T13:08:19.501333"
                        auction.setCreatedAt(LocalDateTime.parse((String) createdAtObj));
                    } catch (Exception e) {
                        logger.warning("Failed to parse createdAt timestamp: " + createdAtObj);
                    }
                }
            }
            
            if (document.contains("updatedAt")) {
                Object updatedAtObj = document.get("updatedAt");
                if (updatedAtObj instanceof com.google.cloud.Timestamp) {
                    com.google.cloud.Timestamp timestamp = (com.google.cloud.Timestamp) updatedAtObj;
                    auction.setUpdatedAt(LocalDateTime.ofInstant(timestamp.toDate().toInstant(), ZoneId.systemDefault()));
                } else if (updatedAtObj instanceof String) {
                    try {
                        // Parse string timestamp like "2025-06-09T13:08:19.501333"
                        auction.setUpdatedAt(LocalDateTime.parse((String) updatedAtObj));
                    } catch (Exception e) {
                        logger.warning("Failed to parse updatedAt timestamp: " + updatedAtObj);
                    }
                }
            }
            
            // Handle endTime field - crucial for auction functionality
            if (document.contains("endTime")) {
                Object endTimeObj = document.get("endTime");
                if (endTimeObj instanceof com.google.cloud.Timestamp) {
                    com.google.cloud.Timestamp timestamp = (com.google.cloud.Timestamp) endTimeObj;
                    auction.setEndTime(LocalDateTime.ofInstant(timestamp.toDate().toInstant(), ZoneId.systemDefault()));
                } else if (endTimeObj instanceof String) {
                    try {
                        // Parse string timestamp like "2025-06-29T17:42"
                        auction.setEndTime(LocalDateTime.parse((String) endTimeObj));
                        logger.info("Parsed endTime: " + endTimeObj + " -> " + auction.getEndTime());
                    } catch (Exception e) {
                        logger.warning("Failed to parse endTime timestamp: " + endTimeObj);
                    }
                }
            }
            
            // Also check for "auctionEndTime" field in case that's what's in Firebase
            if (document.contains("auctionEndTime")) {
                Object endTimeObj = document.get("auctionEndTime");
                if (endTimeObj instanceof com.google.cloud.Timestamp) {
                    com.google.cloud.Timestamp timestamp = (com.google.cloud.Timestamp) endTimeObj;
                    auction.setEndTime(LocalDateTime.ofInstant(timestamp.toDate().toInstant(), ZoneId.systemDefault()));
                } else if (endTimeObj instanceof String) {
                    try {
                        // Parse string timestamp like "2025-06-29T17:42"
                        auction.setEndTime(LocalDateTime.parse((String) endTimeObj));
                        logger.info("Parsed auctionEndTime: " + endTimeObj + " -> " + auction.getEndTime());
                    } catch (Exception e) {
                        logger.warning("Failed to parse auctionEndTime timestamp: " + endTimeObj);
                    }
                }
            }
            
            // Add winner information for sold auctions
            if ("SOLD".equals(auction.getStatus())) {
                // Note: The Auction model doesn't have winner fields, but we'll store them in a map
                // For now, we'll need to check if the Auction model needs to be extended
                // or we can access these fields from the document directly in the servlet
                // For compatibility, we'll leave this for the servlet to handle
            }
            
            return auction;
            
        } catch (Exception e) {
            logger.severe("Error converting document to auction: " + e.getMessage());
            return null;
        }
    }
    
    /**
     * Place a bid on an auction
     */
    public boolean placeBid(String auctionId, String bidderId, double bidAmount) 
            throws ExecutionException, InterruptedException {
        try {
            logger.info("Placing bid for auction " + auctionId + " by user " + bidderId + " with amount " + bidAmount);
            
            // Get the current auction data
            DocumentReference auctionRef = db.collection("artworks").document(auctionId);
            DocumentSnapshot auctionDoc = auctionRef.get().get();
            
            if (!auctionDoc.exists()) {
                logger.warning("Auction not found: " + auctionId);
                return false;
            }
            
            // Get current bid and bid count
            double currentBid = 0;
            if (auctionDoc.contains("currentBid") && auctionDoc.get("currentBid") != null) {
                Object currentBidObj = auctionDoc.get("currentBid");
                if (currentBidObj instanceof Number) {
                    currentBid = ((Number) currentBidObj).doubleValue();
                }
            }
            
            // If no current bid, use starting bid
            if (currentBid == 0 && auctionDoc.contains("startingBid")) {
                Object startingBidObj = auctionDoc.get("startingBid");
                if (startingBidObj instanceof Number) {
                    currentBid = ((Number) startingBidObj).doubleValue();
                }
            }
            
            // Validate bid amount
            if (bidAmount <= currentBid) {
                logger.warning("Bid amount " + bidAmount + " is not higher than current bid " + currentBid);
                return false;
            }
            
            // Get current bid count
            int bidCount = 0;
            if (auctionDoc.contains("bidCount") && auctionDoc.get("bidCount") != null) {
                Object bidCountObj = auctionDoc.get("bidCount");
                if (bidCountObj instanceof Number) {
                    bidCount = ((Number) bidCountObj).intValue();
                }
            }
            
            // Update auction with new bid
            Map<String, Object> updates = new HashMap<>();
            updates.put("currentBid", bidAmount);
            updates.put("bidCount", bidCount + 1);
            updates.put("lastBidderId", bidderId);
            updates.put("lastBidTime", LocalDateTime.now().toString());
            updates.put("updatedAt", LocalDateTime.now().toString());
            
            ApiFuture<WriteResult> result = auctionRef.update(updates);
            result.get(); // Wait for completion
            
            logger.info("Successfully updated auction " + auctionId + " with new bid: " + bidAmount);
            
            // Get bidder name for bid history
            String bidderName = getBidderName(bidderId);
            
            // Store bid history in a separate collection
            saveBidHistory(auctionId, bidderId, bidderName, bidAmount, currentBid);
            
            return true;
            
        } catch (Exception e) {
            logger.severe("Error placing bid: " + e.getMessage());
            return false;
        }
    }
    
    /**
     * Get bidder name from user ID
     */
    private String getBidderName(String bidderId) {
        try {
            DocumentReference userRef = db.collection("users").document(bidderId);
            DocumentSnapshot userDoc = userRef.get().get();
            
            if (userDoc.exists()) {
                String firstName = userDoc.getString("firstName");
                String lastName = userDoc.getString("lastName");
                String username = userDoc.getString("username");
                
                if (firstName != null && lastName != null) {
                    return firstName + " " + lastName;
                } else if (firstName != null) {
                    return firstName;
                } else if (username != null) {
                    return username;
                }
            }
            return "Unknown User";
        } catch (Exception e) {
            logger.warning("Error getting bidder name for " + bidderId + ": " + e.getMessage());
            return "Unknown User";
        }
    }
    
    /**
     * Save bid history to a separate collection
     */
    private void saveBidHistory(String auctionId, String bidderId, String bidderName, double bidAmount, double previousBid) {
        try {
            logger.info("=== saveBidHistory called ===");
            logger.info("Auction ID: " + auctionId);
            logger.info("Bidder ID: " + bidderId);
            logger.info("Bidder Name: " + bidderName);
            logger.info("Bid Amount: " + bidAmount);
            logger.info("Previous Bid: " + previousBid);
            
            Map<String, Object> bidData = new HashMap<>();
            bidData.put("auctionId", auctionId);
            bidData.put("bidderId", bidderId);
            bidData.put("bidderName", bidderName);
            bidData.put("bidAmount", bidAmount);
            bidData.put("previousBid", previousBid);
            bidData.put("timestamp", LocalDateTime.now().toString());
            bidData.put("createdAt", new java.util.Date());
            
            logger.info("Bid data to save: " + bidData);
            
            // Save to bid_history collection
            ApiFuture<DocumentReference> future = db.collection("bid_history").add(bidData);
            DocumentReference docRef = future.get(); // Wait for completion
            
            logger.info("Successfully saved bid history with document ID: " + docRef.getId());
            
        } catch (Exception e) {
            logger.severe("Error saving bid history: " + e.getMessage());
            e.printStackTrace();
            // Don't throw exception here as it shouldn't fail the main bid placement
        }
    }
    
    /**
     * Get all biddings placed by a user
     */
    public List<Map<String, Object>> getUserBiddings(String userId, String status) {
        try {
            logger.info("Getting biddings for user: " + userId + " with status: " + status);
            
            // Query bid_history collection for user's bids
            Query query = db.collection("bid_history")
                    .whereEqualTo("bidderId", userId)
                    .orderBy("timestamp", Query.Direction.DESCENDING);
            
            logger.info("Executing query: collection(bid_history).whereEqualTo(bidderId, " + userId + ").orderBy(timestamp, DESC)");
            
            ApiFuture<QuerySnapshot> future = query.get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            
            logger.info("Raw query returned " + documents.size() + " documents");
            
            // Log the first few documents for debugging
            for (int i = 0; i < Math.min(3, documents.size()); i++) {
                QueryDocumentSnapshot doc = documents.get(i);
                logger.info("Document " + i + ": ID=" + doc.getId() + ", bidderId=" + doc.get("bidderId") + ", bidAmount=" + doc.get("bidAmount"));
            }
            
            List<Map<String, Object>> biddings = new ArrayList<>();
            
            for (QueryDocumentSnapshot doc : documents) {
                Map<String, Object> bidData = doc.getData();
                String auctionId = (String) bidData.get("auctionId");
                
                // Get artwork details
                ApiFuture<DocumentSnapshot> artworkFuture = db.collection("artworks").document(auctionId).get();
                DocumentSnapshot artworkDoc = artworkFuture.get();
                
                if (artworkDoc.exists()) {
                    Map<String, Object> artworkData = artworkDoc.getData();
                    
                    // Create bidding object
                    Map<String, Object> bidding = new HashMap<>();
                    bidding.put("id", doc.getId());
                    bidding.put("amount", bidData.get("bidAmount"));
                    bidding.put("bidTime", bidData.get("timestamp")); // Use timestamp field
                    bidding.put("status", "active"); // Simple status for now
                    
                    // Add artwork details
                    Map<String, Object> artwork = new HashMap<>();
                    artwork.put("id", auctionId);
                    artwork.put("title", artworkData.get("title"));
                    artwork.put("artistName", artworkData.get("artistName"));
                    artwork.put("imageUrl", artworkData.get("imageUrl"));
                    artwork.put("currentBid", artworkData.get("currentBid"));
                    artwork.put("highestBidderId", artworkData.get("highestBidderId"));
                    
                    bidding.put("artwork", artwork);
                    
                    // Add all biddings (ignore status filter for now)
                    biddings.add(bidding);
                }
            }
            
            logger.info("Retrieved " + biddings.size() + " biddings for user " + userId);
            return biddings;
            
        } catch (Exception e) {
            logger.severe("Error getting user biddings: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    
    /**
     * Get all bidders for an auction (for artist to view)
     * Returns list of bidders sorted by bid amount (highest first) or by timestamp (latest first)
     */
    public List<Map<String, Object>> getAuctionBidders(String auctionId, String sortBy) 
            throws ExecutionException, InterruptedException {
        try {
            logger.info("=== Getting bidders for auction: " + auctionId + " sorted by: " + sortBy + " ===");
            
            // First, get the artwork/auction to check status and get highest bidder
            ApiFuture<DocumentSnapshot> artworkFuture = db.collection("artworks").document(auctionId).get();
            DocumentSnapshot artworkDoc = artworkFuture.get();
            
            String highestBidderId = null;
            String auctionStatus = "ACTIVE";
            if (artworkDoc.exists()) {
                Map<String, Object> artworkData = artworkDoc.getData();
                highestBidderId = (String) artworkData.get("highestBidderId");
                auctionStatus = (String) artworkData.get("status");
                if (auctionStatus == null) {
                    auctionStatus = "ACTIVE";
                }
            }
            
            // Query all bids for this auction without ordering (we'll sort in memory if needed)
            Query query = db.collection("bid_history")
                    .whereEqualTo("auctionId", auctionId);
            
            ApiFuture<QuerySnapshot> future = query.get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            
            logger.info("=== Found " + documents.size() + " bid documents for auction " + auctionId + " ===");
            
            // Log first few documents for debugging
            for (int i = 0; i < Math.min(3, documents.size()); i++) {
                QueryDocumentSnapshot doc = documents.get(i);
                Map<String, Object> data = doc.getData();
                logger.info("Bid doc " + i + ": bidderId=" + data.get("bidderId") + 
                           ", bidderName=" + data.get("bidderName") + 
                           ", bidAmount=" + data.get("bidAmount") + 
                           ", auctionId=" + data.get("auctionId"));
            }
            
            List<Map<String, Object>> bidders = new ArrayList<>();
            
            for (QueryDocumentSnapshot doc : documents) {
                Map<String, Object> bidData = doc.getData();
                
                Map<String, Object> bidder = new HashMap<>();
                bidder.put("bidId", doc.getId());
                String bidderId = (String) bidData.get("bidderId");
                bidder.put("bidderId", bidderId);
                bidder.put("bidderName", bidData.get("bidderName"));
                
                // Fetch user details for email and username
                try {
                    ApiFuture<DocumentSnapshot> userFuture = db.collection("users").document(bidderId).get();
                    DocumentSnapshot userDoc = userFuture.get();
                    
                    if (userDoc.exists()) {
                        Map<String, Object> userData = userDoc.getData();
                        bidder.put("email", userData.get("email"));
                        bidder.put("username", userData.get("username"));
                        // Use displayName if available, otherwise use username
                        String displayName = (String) userData.get("displayName");
                        if (displayName != null && !displayName.trim().isEmpty()) {
                            bidder.put("fullName", displayName);
                        } else {
                            bidder.put("fullName", userData.get("username"));
                        }
                    } else {
                        bidder.put("email", "N/A");
                        bidder.put("username", bidData.get("bidderName"));
                        bidder.put("fullName", bidData.get("bidderName"));
                    }
                } catch (Exception e) {
                    logger.warning("Error fetching user details for bidderId: " + bidderId + " - " + e.getMessage());
                    bidder.put("email", "N/A");
                    bidder.put("username", bidData.get("bidderName"));
                    bidder.put("fullName", bidData.get("bidderName"));
                }
                
                // Handle bid amount - convert to number for consistent sorting
                Object bidAmountObj = bidData.get("bidAmount");
                double bidAmount = 0.0;
                if (bidAmountObj instanceof Number) {
                    bidAmount = ((Number) bidAmountObj).doubleValue();
                } else if (bidAmountObj instanceof String) {
                    try {
                        bidAmount = Double.parseDouble((String) bidAmountObj);
                    } catch (NumberFormatException e) {
                        logger.warning("Invalid bidAmount format: " + bidAmountObj);
                    }
                }
                bidder.put("bidAmount", bidAmount);
                
                // Handle previous bid
                Object previousBidObj = bidData.get("previousBid");
                if (previousBidObj != null) {
                    bidder.put("previousBid", previousBidObj);
                }
                
                // Handle timestamp - preserve original format but also provide parsed date
                Object timestampObj = bidData.get("timestamp");
                bidder.put("timestamp", timestampObj);
                
                // Also try to parse timestamp for sorting
                LocalDateTime bidTime = null;
                if (timestampObj instanceof com.google.cloud.Timestamp) {
                    com.google.cloud.Timestamp ts = (com.google.cloud.Timestamp) timestampObj;
                    bidTime = LocalDateTime.ofInstant(
                        ts.toDate().toInstant(),
                        java.time.ZoneId.systemDefault()
                    );
                } else if (timestampObj instanceof String) {
                    try {
                        bidTime = LocalDateTime.parse((String) timestampObj);
                    } catch (Exception e) {
                        logger.warning("Could not parse timestamp string: " + timestampObj);
                    }
                } else if (timestampObj instanceof java.util.Date) {
                    bidTime = LocalDateTime.ofInstant(
                        ((java.util.Date) timestampObj).toInstant(),
                        java.time.ZoneId.systemDefault()
                    );
                }
                
                if (bidTime != null) {
                    bidder.put("bidTime", bidTime.toString());
                    bidder.put("bidTimeObj", bidTime);
                }
                
                // Add auction status and bidder status
                bidder.put("auctionStatus", auctionStatus);
                
                bidders.add(bidder);
            }
            
            // Sort in memory based on sortBy parameter
            if ("amount".equals(sortBy) || "highest".equals(sortBy)) {
                // Sort by bid amount descending (highest first)
                bidders.sort((b1, b2) -> {
                    double amount1 = ((Number) b1.get("bidAmount")).doubleValue();
                    double amount2 = ((Number) b2.get("bidAmount")).doubleValue();
                    return Double.compare(amount2, amount1); // Descending order
                });
            } else {
                // Sort by timestamp descending (latest first)
                bidders.sort((b1, b2) -> {
                    LocalDateTime time1 = (LocalDateTime) b1.get("bidTimeObj");
                    LocalDateTime time2 = (LocalDateTime) b2.get("bidTimeObj");
                    
                    if (time1 == null && time2 == null) return 0;
                    if (time1 == null) return 1;
                    if (time2 == null) return -1;
                    
                    return time2.compareTo(time1); // Descending order (latest first)
                });
            }
            
            // After sorting, determine bid status for each bidder
            double highestBidAmount = 0.0;
            if (!bidders.isEmpty() && ("amount".equals(sortBy) || "highest".equals(sortBy))) {
                highestBidAmount = ((Number) bidders.get(0).get("bidAmount")).doubleValue();
            } else if (!bidders.isEmpty()) {
                // Find highest bid amount when sorted by time
                for (Map<String, Object> b : bidders) {
                    double amt = ((Number) b.get("bidAmount")).doubleValue();
                    if (amt > highestBidAmount) {
                        highestBidAmount = amt;
                    }
                }
            }
            
            // Set bid status for each bidder
            for (Map<String, Object> bidder : bidders) {
                String bidderId = (String) bidder.get("bidderId");
                double bidAmount = ((Number) bidder.get("bidAmount")).doubleValue();
                String status = auctionStatus;
                
                String bidStatus;
                if ("ENDED".equals(status) || "COMPLETED".equals(status)) {
                    // Auction has ended
                    if (bidderId.equals(highestBidderId) && bidAmount == highestBidAmount) {
                        bidStatus = "WINNING";
                    } else {
                        bidStatus = "OUTBID";
                    }
                } else {
                    // Auction is still active
                    if (bidAmount == highestBidAmount && bidderId.equals(highestBidderId)) {
                        bidStatus = "HIGHEST";
                    } else {
                        bidStatus = "OUTBID";
                    }
                }
                
                bidder.put("bidStatus", bidStatus);
            }
            
            logger.info("Retrieved and sorted " + bidders.size() + " bidders for auction " + auctionId);
            return bidders;
            
        } catch (Exception e) {
            logger.severe("Error getting auction bidders: " + e.getMessage());
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
}
