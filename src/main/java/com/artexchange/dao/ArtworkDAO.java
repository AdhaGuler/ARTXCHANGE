package com.artexchange.dao;

import com.artexchange.config.FirebaseConfig;
import com.artexchange.model.Artwork;
import com.artexchange.model.User;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Data Access Object for Artwork operations with Firestore
 */
public class ArtworkDAO {
    private static final Logger logger = LoggerFactory.getLogger(ArtworkDAO.class);
    private static final String COLLECTION_NAME = "artworks";
    private final Firestore firestore;
    
    public ArtworkDAO() {
        this.firestore = FirebaseConfig.getFirestore();
    }
    
    /**
     * Save artwork to Firestore
     */
    public String saveArtwork(Artwork artwork) throws ExecutionException, InterruptedException {
        try {
            // Generate ID if not provided
            if (artwork.getArtworkId() == null || artwork.getArtworkId().isEmpty()) {
                DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
                artwork.setArtworkId(docRef.getId());
            }
            
            Map<String, Object> artworkData = artworkToMap(artwork);
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(artwork.getArtworkId())
                .set(artworkData);
            
            result.get();
            logger.info("Artwork saved successfully: {}", artwork.getArtworkId());
            return artwork.getArtworkId();
            
        } catch (Exception e) {
            logger.error("Error saving artwork: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find artwork by ID
     */
    public Artwork findById(String artworkId) throws ExecutionException, InterruptedException {
        try {
            DocumentReference docRef = firestore.collection(COLLECTION_NAME).document(artworkId);
            ApiFuture<DocumentSnapshot> future = docRef.get();
            DocumentSnapshot document = future.get();
            
            if (document.exists()) {
                return mapToArtwork(document);
            }
            return null;
            
        } catch (Exception e) {
            logger.error("Error finding artwork by ID: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find active artworks with pagination and filters
     */
    public List<Artwork> findActiveArtworks(int page, int limit, String category, String search) 
            throws ExecutionException, InterruptedException {
        logger.info("=== findActiveArtworks called ===");
        logger.info("Parameters: page={}, limit={}, category={}, search={}", page, limit, category, search);
        
        try {
            // Query for both ACTIVE and SOLD artworks (include sold artworks in listings)
            // Note: Firestore doesn't support whereIn with multiple orderBy easily, so we'll fetch all and sort in memory
            Query query = firestore.collection(COLLECTION_NAME)
                .whereIn("status", java.util.Arrays.asList("ACTIVE", "SOLD"))
                .orderBy("createdAt", Query.Direction.DESCENDING);
            
            logger.info("Initial query created for collection: {} (including SOLD artworks)", COLLECTION_NAME);
            
            // Add category filter if provided
            if (category != null && !category.trim().isEmpty()) {
                query = query.whereEqualTo("category", category.toUpperCase());
                logger.info("Added category filter: {}", category.toUpperCase());
            }
            
            // Calculate offset
            int offset = (page - 1) * limit;
            logger.info("Calculated offset: {} (page {} * limit {})", offset, page, limit);
            
            // Apply pagination
            query = query.limit(limit).offset(offset);
            logger.info("Applied pagination - limit: {}, offset: {}", limit, offset);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            logger.info("Executing Firestore query...");
            
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            logger.info("Query executed. Found {} documents in Firestore", documents.size());
            
            List<Artwork> artworks = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                logger.debug("Processing document: {}", doc.getId());
                Artwork artwork = mapToArtwork(doc);
                
                // Apply search filter if provided
                if (search == null || search.trim().isEmpty() || 
                    matchesSearch(artwork, search)) {
                    artworks.add(artwork);
                    logger.debug("Added artwork: {} - {}", artwork.getArtworkId(), artwork.getTitle());
                } else {
                    logger.debug("Artwork {} filtered out by search criteria", artwork.getArtworkId());
                }
            }
            
            logger.info("After search filtering: {} artworks", artworks.size());
            
            // If no artworks found and this is the first page, return sample data for demonstration
            if (artworks.isEmpty() && page == 1) {
                logger.info("No active artworks found in database, returning sample data for demonstration");
                List<Artwork> sampleArtworks = createSampleArtworks();
                logger.info("Created {} sample artworks", sampleArtworks.size());
                
                // Apply category and search filters to sample data
                List<Artwork> filteredSamples = new ArrayList<>();
                for (Artwork artwork : sampleArtworks) {
                    boolean matchesCategory = category == null || category.trim().isEmpty() || 
                                            (artwork.getCategory() != null && 
                                             artwork.getCategory().name().equalsIgnoreCase(category));
                    boolean matchesSearchTerm = search == null || search.trim().isEmpty() || 
                                               matchesSearch(artwork, search);
                    
                    if (matchesCategory && matchesSearchTerm) {
                        filteredSamples.add(artwork);
                        logger.debug("Sample artwork added: {} - {}", artwork.getArtworkId(), artwork.getTitle());
                    } else {
                        logger.debug("Sample artwork filtered out: {} - {}", artwork.getArtworkId(), artwork.getTitle());
                    }
                }
                
                logger.info("After filtering sample data: {} artworks", filteredSamples.size());
                
                // Apply limit to sample data
                List<Artwork> limitedSamples = filteredSamples.stream()
                    .limit(limit)
                    .collect(java.util.stream.Collectors.toList());
                
                logger.info("Final sample artworks returned: {}", limitedSamples.size());
                logger.info("=== findActiveArtworks completed (sample data) ===");
                return limitedSamples;
            }
            
            logger.info("Final artworks returned from database: {}", artworks.size());
            logger.info("=== findActiveArtworks completed (database data) ===");
            return artworks;
            
        } catch (Exception e) {
            logger.error("Error finding active artworks: {}", e.getMessage(), e);
            // Return sample artworks for demonstration when there's an error
            if (page == 1) {
                logger.info("Returning sample artworks due to error");
                List<Artwork> samples = createSampleArtworks().stream()
                    .limit(limit)
                    .collect(java.util.stream.Collectors.toList());
                logger.info("Sample artworks returned due to error: {}", samples.size());
                return samples;
            }
            throw e;
        }
    }
    
    /**
     * Find active artworks with advanced filtering including price range
     */
    public List<Artwork> findActiveArtworks(int page, int limit, String category, String search, 
                                          String minPrice, String maxPrice, String listingType, String sortBy) 
            throws ExecutionException, InterruptedException {
        logger.info("=== findActiveArtworks (with filters) called ===");
        logger.info("Parameters: page={}, limit={}, category={}, search={}, minPrice={}, maxPrice={}, listingType={}, sortBy={}", 
                   page, limit, category, search, minPrice, maxPrice, listingType, sortBy);
        
        try {
            // Query for both ACTIVE and SOLD artworks (include sold artworks in listings)
            // Note: Firestore doesn't support whereIn with multiple orderBy easily, so we'll fetch all and sort in memory
            Query query = firestore.collection(COLLECTION_NAME)
                .whereIn("status", java.util.Arrays.asList("ACTIVE", "SOLD"))
                .orderBy("createdAt", Query.Direction.DESCENDING);
            
            logger.info("Initial query created for collection: {} (including SOLD artworks)", COLLECTION_NAME);
            
            // Add category filter if provided
            if (category != null && !category.trim().isEmpty()) {
                query = query.whereEqualTo("category", category.toUpperCase());
                logger.info("Added category filter: {}", category.toUpperCase());
            }
            
            // Add listing type filter if provided
            if (listingType != null && !listingType.trim().isEmpty()) {
                query = query.whereEqualTo("saleType", listingType.toUpperCase());
                logger.info("Added listing type filter: {}", listingType.toUpperCase());
            }
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            logger.info("Retrieved {} documents from Firestore before filtering", documents.size());
            
            List<Artwork> allArtworks = new ArrayList<>();
            for (QueryDocumentSnapshot document : documents) {
                Artwork artwork = mapToArtwork(document);
                if (artwork != null) {
                    allArtworks.add(artwork);
                }
            }
            
            logger.info("Mapped {} artworks from documents", allArtworks.size());
            
            // Apply filters that can't be done at database level
            List<Artwork> filteredArtworks = new ArrayList<>();
            
            for (Artwork artwork : allArtworks) {
                boolean includeArtwork = true;
                double artworkPrice = artwork.getPrice() != null ? artwork.getPrice().doubleValue() : 0.0;
                
                logger.info("Processing artwork: id={}, title={}, price={}", 
                           artwork.getArtworkId(), artwork.getTitle(), artworkPrice);
                
                // Filter by price range
                if (minPrice != null && !minPrice.trim().isEmpty()) {
                    try {
                        double minPriceValue = Double.parseDouble(minPrice);
                        if (artworkPrice < minPriceValue) {
                            includeArtwork = false;
                            logger.info("Artwork {} FILTERED OUT: price {} < minPrice {}", 
                                       artwork.getArtworkId(), artworkPrice, minPriceValue);
                        } else {
                            logger.info("Artwork {} PASSED minPrice filter: price {} >= minPrice {}", 
                                       artwork.getArtworkId(), artworkPrice, minPriceValue);
                        }
                    } catch (NumberFormatException e) {
                        logger.warn("Invalid minPrice format: {}", minPrice);
                    }
                }
                
                if (maxPrice != null && !maxPrice.trim().isEmpty() && includeArtwork) {
                    try {
                        double maxPriceValue = Double.parseDouble(maxPrice);
                        if (artworkPrice > maxPriceValue) {
                            includeArtwork = false;
                            logger.info("Artwork {} FILTERED OUT: price {} > maxPrice {}", 
                                       artwork.getArtworkId(), artworkPrice, maxPriceValue);
                        } else {
                            logger.info("Artwork {} PASSED maxPrice filter: price {} <= maxPrice {}", 
                                       artwork.getArtworkId(), artworkPrice, maxPriceValue);
                        }
                    } catch (NumberFormatException e) {
                        logger.warn("Invalid maxPrice format: {}", maxPrice);
                    }
                }
                
                // Filter by search term
                if (search != null && !search.trim().isEmpty() && includeArtwork) {
                    String searchLower = search.toLowerCase();
                    boolean matchesSearch = false;
                    
                    if (artwork.getTitle() != null && artwork.getTitle().toLowerCase().contains(searchLower)) {
                        matchesSearch = true;
                    } else if (artwork.getDescription() != null && artwork.getDescription().toLowerCase().contains(searchLower)) {
                        matchesSearch = true;
                    } else if (artwork.getArtistName() != null && artwork.getArtistName().toLowerCase().contains(searchLower)) {
                        matchesSearch = true;
                    }
                    
                    if (!matchesSearch) {
                        includeArtwork = false;
                        logger.info("Artwork {} FILTERED OUT: doesn't match search term '{}'", 
                                   artwork.getArtworkId(), search);
                    } else {
                        logger.info("Artwork {} PASSED search filter for term '{}'", 
                                   artwork.getArtworkId(), search);
                    }
                }
                
                if (includeArtwork) {
                    filteredArtworks.add(artwork);
                    logger.info("Artwork {} INCLUDED in final results", artwork.getArtworkId());
                } else {
                    logger.info("Artwork {} EXCLUDED from final results", artwork.getArtworkId());
                }
            }
            
            logger.info("After filtering: {} artworks remain from original {}", 
                       filteredArtworks.size(), allArtworks.size());
            
            // Separate ACTIVE and SOLD artworks
            List<Artwork> activeArtworks = new ArrayList<>();
            List<Artwork> soldArtworks = new ArrayList<>();
            
            for (Artwork artwork : filteredArtworks) {
                if (artwork.getStatus() == Artwork.ArtworkStatus.ACTIVE) {
                    activeArtworks.add(artwork);
                } else if (artwork.getStatus() == Artwork.ArtworkStatus.SOLD) {
                    soldArtworks.add(artwork);
                }
            }
            
            // Apply sorting within each group
            if (sortBy != null && !sortBy.trim().isEmpty()) {
                switch (sortBy.toLowerCase()) {
                    case "price_low":
                        activeArtworks.sort((a, b) -> {
                            double priceA = a.getPrice() != null ? a.getPrice().doubleValue() : 0.0;
                            double priceB = b.getPrice() != null ? b.getPrice().doubleValue() : 0.0;
                            return Double.compare(priceA, priceB);
                        });
                        soldArtworks.sort((a, b) -> {
                            double priceA = a.getPrice() != null ? a.getPrice().doubleValue() : 0.0;
                            double priceB = b.getPrice() != null ? b.getPrice().doubleValue() : 0.0;
                            return Double.compare(priceA, priceB);
                        });
                        logger.info("Sorted artworks by price (low to high)");
                        break;
                    case "price_high":
                        activeArtworks.sort((a, b) -> {
                            double priceA = a.getPrice() != null ? a.getPrice().doubleValue() : 0.0;
                            double priceB = b.getPrice() != null ? b.getPrice().doubleValue() : 0.0;
                            return Double.compare(priceB, priceA);
                        });
                        soldArtworks.sort((a, b) -> {
                            double priceA = a.getPrice() != null ? a.getPrice().doubleValue() : 0.0;
                            double priceB = b.getPrice() != null ? b.getPrice().doubleValue() : 0.0;
                            return Double.compare(priceB, priceA);
                        });
                        logger.info("Sorted artworks by price (high to low)");
                        break;
                    case "newest":
                        activeArtworks.sort((a, b) -> {
                            if (a.getCreatedAt() == null && b.getCreatedAt() == null) return 0;
                            if (a.getCreatedAt() == null) return 1;
                            if (b.getCreatedAt() == null) return -1;
                            return b.getCreatedAt().compareTo(a.getCreatedAt());
                        });
                        soldArtworks.sort((a, b) -> {
                            if (a.getCreatedAt() == null && b.getCreatedAt() == null) return 0;
                            if (a.getCreatedAt() == null) return 1;
                            if (b.getCreatedAt() == null) return -1;
                            return b.getCreatedAt().compareTo(a.getCreatedAt());
                        });
                        logger.info("Sorted artworks by date (newest first)");
                        break;
                    case "oldest":
                        activeArtworks.sort((a, b) -> {
                            if (a.getCreatedAt() == null && b.getCreatedAt() == null) return 0;
                            if (a.getCreatedAt() == null) return 1;
                            if (b.getCreatedAt() == null) return -1;
                            return a.getCreatedAt().compareTo(b.getCreatedAt());
                        });
                        soldArtworks.sort((a, b) -> {
                            if (a.getCreatedAt() == null && b.getCreatedAt() == null) return 0;
                            if (a.getCreatedAt() == null) return 1;
                            if (b.getCreatedAt() == null) return -1;
                            return a.getCreatedAt().compareTo(b.getCreatedAt());
                        });
                        logger.info("Sorted artworks by date (oldest first)");
                        break;
                    default:
                        logger.info("No sorting applied for sortBy: {}", sortBy);
                }
            }
            
            // Combine: ACTIVE first, then SOLD
            filteredArtworks = new ArrayList<>();
            filteredArtworks.addAll(activeArtworks);
            filteredArtworks.addAll(soldArtworks);
            
            logger.info("Final sorted artworks: {} active, {} sold", activeArtworks.size(), soldArtworks.size());
            
            // Apply pagination
            int startIndex = (page - 1) * limit;
            int endIndex = Math.min(startIndex + limit, filteredArtworks.size());
            
            List<Artwork> paginatedArtworks = new ArrayList<>();
            if (startIndex < filteredArtworks.size() && startIndex < endIndex) {
                paginatedArtworks = filteredArtworks.subList(startIndex, endIndex);
            }
            
            logger.info("Applied pagination: page={}, limit={}, startIndex={}, endIndex={}, filteredSize={}, returning {} artworks", 
                       page, limit, startIndex, endIndex, filteredArtworks.size(), paginatedArtworks.size());
            logger.info("=== findActiveArtworks (with filters) completed ===");
            
            return paginatedArtworks;
            
        } catch (Exception e) {
            logger.error("Error finding active artworks with filters: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find featured artworks
     */
    public List<Artwork> findFeaturedArtworks(int limit) throws ExecutionException, InterruptedException {
        try {
            // For now, return most liked and recent artworks
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("status", "ACTIVE")
                .orderBy("likes", Query.Direction.DESCENDING)
                .orderBy("createdAt", Query.Direction.DESCENDING)
                .limit(limit);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            List<Artwork> artworks = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                artworks.add(mapToArtwork(doc));
            }
            
            return artworks;
            
        } catch (Exception e) {
            logger.error("Error finding featured artworks: {}", e.getMessage(), e);
            // Return sample artworks for demonstration
            return createSampleArtworks();
        }
    }
    
    /**
     * Find artworks by artist
     */
    public List<Artwork> findByArtistId(String artistId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("artistId", artistId)
                .orderBy("createdAt", Query.Direction.DESCENDING);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            List<Artwork> artworks = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                artworks.add(mapToArtwork(doc));
            }
            
            return artworks;
            
        } catch (Exception e) {
            logger.error("Error finding artworks by artist: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find artworks by artist with pagination
     */
    public List<Artwork> findArtworksByArtist(String artistId, int page, int limit) throws ExecutionException, InterruptedException {
        try {
            // Calculate offset
            int offset = (page - 1) * limit;
            
            Query query;
            try {
                // Try with orderBy first (requires index)
                query = firestore.collection(COLLECTION_NAME)
                    .whereEqualTo("artistId", artistId)
                    .orderBy("createdAt", Query.Direction.DESCENDING)
                    .limit(limit)
                    .offset(offset);
                
                ApiFuture<QuerySnapshot> querySnapshot = query.get();
                List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
                
                logger.info("Query returned " + documents.size() + " documents for artist " + artistId);
                
                List<Artwork> artworks = new ArrayList<>();
                for (DocumentSnapshot doc : documents) {
                    try {
                        Artwork artwork = mapToArtwork(doc);
                        if (artwork != null) {
                            artworks.add(artwork);
                            logger.debug("Mapped artwork: " + artwork.getArtworkId() + 
                                       ", SaleType: " + artwork.getSaleType() + 
                                       ", Status: " + artwork.getStatus());
                        }
                    } catch (Exception e) {
                        logger.warn("Error mapping artwork document " + doc.getId() + ": " + e.getMessage());
                    }
                }
                
                logger.info("Successfully mapped " + artworks.size() + " artworks for artist " + artistId);
                return artworks;
            } catch (Exception orderByError) {
                // If orderBy fails (e.g., missing index), try without it
                logger.warn("OrderBy query failed, trying without orderBy: {}", orderByError.getMessage());
                query = firestore.collection(COLLECTION_NAME)
                    .whereEqualTo("artistId", artistId)
                    .limit(limit)
                    .offset(offset);
                
                ApiFuture<QuerySnapshot> querySnapshot = query.get();
                List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
                
                logger.info("Fallback query returned " + documents.size() + " documents for artist " + artistId);
                
                List<Artwork> artworks = new ArrayList<>();
                for (DocumentSnapshot doc : documents) {
                    try {
                        Artwork artwork = mapToArtwork(doc);
                        if (artwork != null) {
                            artworks.add(artwork);
                        }
                    } catch (Exception e) {
                        logger.warn("Error mapping artwork document " + doc.getId() + ": " + e.getMessage());
                    }
                }
                
                // Sort in memory by createdAt if available
                artworks.sort((a, b) -> {
                    if (a.getCreatedAt() == null && b.getCreatedAt() == null) return 0;
                    if (a.getCreatedAt() == null) return 1;
                    if (b.getCreatedAt() == null) return -1;
                    return b.getCreatedAt().compareTo(a.getCreatedAt()); // Descending
                });
                
                logger.info("Successfully mapped " + artworks.size() + " artworks (fallback query) for artist " + artistId);
                return artworks;
            }
            
        } catch (Exception e) {
            logger.error("Error finding artworks by artist with pagination: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find auction artworks
     */
    public List<Artwork> findActiveAuctions() throws ExecutionException, InterruptedException {
        try {
            LocalDateTime now = LocalDateTime.now();
            
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("status", "ACTIVE")
                .whereEqualTo("saleType", "AUCTION")
                .orderBy("auctionEndTime", Query.Direction.ASCENDING);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            List<Artwork> auctions = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                Artwork artwork = mapToArtwork(doc);
                
                // Only include active auctions
                if (artwork.isAuctionActive()) {
                    auctions.add(artwork);
                }
            }
            
            return auctions;
            
        } catch (Exception e) {
            logger.error("Error finding active auctions: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Update artwork
     */
    public void updateArtwork(Artwork artwork) throws ExecutionException, InterruptedException {
        try {
            artwork.setUpdatedAt(LocalDateTime.now());
            Map<String, Object> artworkData = artworkToMap(artwork);
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(artwork.getArtworkId())
                .set(artworkData);
            
            result.get();
            logger.info("Artwork updated successfully: {}", artwork.getArtworkId());
            
        } catch (Exception e) {
            logger.error("Error updating artwork: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Atomically mark artwork as sold with race condition protection
     * Returns true if successfully marked as sold, false if already sold
     */
    public boolean markArtworkAsSold(String artworkId) throws ExecutionException, InterruptedException {
        try {
            DocumentReference artworkRef = firestore.collection(COLLECTION_NAME).document(artworkId);
            
            // Use a transaction to atomically check and update
            return firestore.runTransaction(transaction -> {
                try {
                    DocumentSnapshot artworkDoc = transaction.get(artworkRef).get();
                    
                    if (!artworkDoc.exists()) {
                        throw new RuntimeException("Artwork not found: " + artworkId);
                    }
                    
                    String currentStatus = artworkDoc.getString("status");
                    
                    // Check if already sold
                    if ("SOLD".equals(currentStatus)) {
                        logger.warn("Artwork {} is already sold", artworkId);
                        return false;
                    }
                    
                    // Atomically update to SOLD
                    LocalDateTime now = LocalDateTime.now();
                    Map<String, Object> updates = new HashMap<>();
                    updates.put("status", "SOLD");
                    updates.put("soldAt", now.toString());
                    updates.put("updatedAt", now.toString());
                    
                    transaction.update(artworkRef, updates);
                    logger.info("Artwork {} marked as sold at {}", artworkId, now);
                    return true;
                } catch (InterruptedException | ExecutionException e) {
                    Thread.currentThread().interrupt();
                    throw new RuntimeException("Error in transaction: " + e.getMessage(), e);
                }
            }).get();
            
        } catch (Exception e) {
            logger.error("Error marking artwork as sold: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Delete artwork
     */
    public void deleteArtwork(String artworkId) throws ExecutionException, InterruptedException {
        try {
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(artworkId)
                .delete();
            
            result.get();
            logger.info("Artwork deleted successfully: {}", artworkId);
            
        } catch (Exception e) {
            logger.error("Error deleting artwork: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get count of artworks for a specific user (artist)
     */
    public long getUserArtworkCount(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("artistId", userId);
            
            QuerySnapshot querySnapshot = query.get().get();
            return querySnapshot.size();
            
        } catch (Exception e) {
            logger.error("Error getting user artwork count", e);
            return 0;
        }
    }
    
    /**
     * Get count of purchases made by a user
     */
    public long getUserPurchaseCount(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("buyerId", userId);
            
            QuerySnapshot querySnapshot = query.get().get();
            return querySnapshot.size();
            
        } catch (Exception e) {
            logger.error("Error getting user purchase count", e);
            return 0;
        }
    }
    
    /**
     * Get count of all bids placed by a user (from bid history)
     */
    public long getUserTotalBidsCount(String userId) throws ExecutionException, InterruptedException {
        try {
            logger.info("=== getUserTotalBidsCount called for userId: " + userId + " ===");
            
            Query query = firestore.collection("bid_history")
                .whereEqualTo("bidderId", userId);
            
            QuerySnapshot querySnapshot = query.get().get();
            long bidCount = querySnapshot.size();
            
            logger.info("Found " + bidCount + " bids for user " + userId);
            
            // Log some sample bids for debugging
            if (bidCount > 0) {
                logger.info("Sample bids for user " + userId + ":");
                querySnapshot.getDocuments().stream().limit(3).forEach(doc -> {
                    logger.info("  - Bid ID: " + doc.getId() + ", Amount: " + doc.get("bidAmount") + ", Auction: " + doc.get("auctionId"));
                });
            }
            
            return bidCount;
            
        } catch (Exception e) {
            logger.error("Error getting user total bids count", e);
            return 0;
        }
    }
    
    /**
     * Get count of active bids by a user (where user is currently highest bidder)
     */
    public long getUserActiveBidsCount(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("highestBidderId", userId)
                .whereEqualTo("listingType", "AUCTION")
                .whereGreaterThan("auctionEndTime", new java.util.Date());
            
            QuerySnapshot querySnapshot = query.get().get();
            return querySnapshot.size();
            
        } catch (Exception e) {
            logger.error("Error getting user active bids count", e);
            return 0;
        }
    }
    
    /**
     * Get total earnings for an artist
     */
    public double getUserTotalEarnings(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("artistId", userId)
                .whereIn("listingType", java.util.Arrays.asList("SOLD", "COMPLETED"));
            
            QuerySnapshot querySnapshot = query.get().get();
            double totalEarnings = 0.0;
            
            for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
                Double price = document.getDouble("currentPrice");
                if (price != null) {
                    totalEarnings += price;
                }
            }
            
            return totalEarnings;
            
        } catch (Exception e) {
            logger.error("Error getting user total earnings", e);
            return 0.0;
        }
    }
    
    /**
     * Get total likes received by a user's artworks
     */
    public long getUserTotalLikes(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("artistId", userId);
            
            QuerySnapshot querySnapshot = query.get().get();
            long totalLikes = 0;
            
            for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
                Long likeCount = document.getLong("likeCount");
                if (likeCount != null) {
                    totalLikes += likeCount;
                }
            }
            
            return totalLikes;
            
        } catch (Exception e) {
            logger.error("Error getting user total likes", e);
            return 0;
        }
    }
    
    /**
     * Get artworks uploaded by a specific user
     */
    public List<Artwork> getUserArtworks(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("artistId", userId)
                .orderBy("createdAt", Query.Direction.DESCENDING);
            
            QuerySnapshot querySnapshot = query.get().get();
            List<Artwork> artworks = new ArrayList<>();
            
            for (QueryDocumentSnapshot document : querySnapshot.getDocuments()) {
                Artwork artwork = mapToArtwork(document);
                if (artwork != null) {
                    artworks.add(artwork);
                }
            }
            
            return artworks;
            
        } catch (Exception e) {
            logger.error("Error getting user artworks", e);
            return new ArrayList<>();
        }
    }
    
    /**
     * Convert Artwork object to Firestore Map
     */
    private Map<String, Object> artworkToMap(Artwork artwork) {
        Map<String, Object> map = new HashMap<>();
        map.put("artworkId", artwork.getArtworkId());
        map.put("title", artwork.getTitle());
        map.put("description", artwork.getDescription());
        map.put("artistId", artwork.getArtistId());
        map.put("artistName", artwork.getArtistName());
        map.put("imageUrls", artwork.getImageUrls());
        map.put("primaryImageUrl", artwork.getPrimaryImageUrl());
        map.put("category", artwork.getCategory() != null ? artwork.getCategory().name() : null);
        map.put("medium", artwork.getMedium());
        map.put("dimensions", artwork.getDimensions());
        map.put("yearCreated", artwork.getYearCreated());
        map.put("price", artwork.getPrice() != null ? artwork.getPrice().toString() : null);
        map.put("currency", artwork.getCurrency());
        map.put("status", artwork.getStatus() != null ? artwork.getStatus().name() : null);
        map.put("saleType", artwork.getSaleType() != null ? artwork.getSaleType().name() : null);
        map.put("isFramed", artwork.isFramed());
        map.put("isOriginal", artwork.isOriginal());
        map.put("tags", artwork.getTags());
        map.put("views", artwork.getViews());
        map.put("likes", artwork.getLikes());
        map.put("createdAt", artwork.getCreatedAt() != null ? artwork.getCreatedAt().toString() : null);
        map.put("updatedAt", artwork.getUpdatedAt() != null ? artwork.getUpdatedAt().toString() : null);
        map.put("soldAt", artwork.getSoldAt() != null ? artwork.getSoldAt().toString() : null);
        map.put("location", artwork.getLocation());
        map.put("isShippingAvailable", artwork.isShippingAvailable());
        map.put("shippingCost", artwork.getShippingCost() != null ? artwork.getShippingCost().toString() : null);
        
        // Auction fields
        map.put("auctionStartTime", artwork.getAuctionStartTime() != null ? artwork.getAuctionStartTime().toString() : null);
        map.put("auctionEndTime", artwork.getAuctionEndTime() != null ? artwork.getAuctionEndTime().toString() : null);
        map.put("startingBid", artwork.getStartingBid() != null ? artwork.getStartingBid().toString() : null);
        map.put("currentBid", artwork.getCurrentBid() != null ? artwork.getCurrentBid().toString() : null);
        map.put("highestBidderId", artwork.getHighestBidderId());
        map.put("bidCount", artwork.getBidCount());
        
        // Auction winner fields
        map.put("winnerId", artwork.getWinnerId());
        map.put("winnerName", artwork.getWinnerName());
        map.put("winningBidAmount", artwork.getWinningBidAmount() != null ? artwork.getWinningBidAmount().toString() : null);
        map.put("endedAt", artwork.getEndedAt() != null ? artwork.getEndedAt().toString() : null);
        
        return map;
    }
    
    /**
     * Convert Firestore DocumentSnapshot to Artwork object
     */
    private Artwork mapToArtwork(DocumentSnapshot doc) {
        Artwork artwork = new Artwork();
        artwork.setArtworkId(doc.getId());
        artwork.setTitle(doc.getString("title"));
        artwork.setDescription(doc.getString("description"));
        artwork.setArtistId(doc.getString("artistId"));
        artwork.setArtistName(doc.getString("artistName"));
        // Ensure artistName is always set
        if ((artwork.getArtistName() == null || artwork.getArtistName().trim().isEmpty()) && artwork.getArtistId() != null) {
            try {
                UserDAO userDAO = new UserDAO();
                User artist = userDAO.findById(artwork.getArtistId());
                if (artist != null) {
                    artwork.setArtistName(artist.getDisplayName());
                } else {
                    artwork.setArtistName("Unknown Artist");
                }
            } catch (InterruptedException ie) {
                Thread.currentThread().interrupt();
                throw new RuntimeException("Interrupted while fetching artist name", ie);
            } catch (Exception e) {
                logger.warn("Could not fetch artist name for artistId {}: {}", artwork.getArtistId(), e.getMessage());
                artwork.setArtistName("Unknown Artist");
            }
        }
        @SuppressWarnings("unchecked")
        List<String> imageUrls = (List<String>) doc.get("imageUrls");
        if (imageUrls != null) {
            artwork.setImageUrls(imageUrls);
        }
        artwork.setPrimaryImageUrl(doc.getString("primaryImageUrl"));
        String categoryStr = doc.getString("category");
        if (categoryStr != null) {
            artwork.setCategory(Artwork.ArtCategory.valueOf(categoryStr));
        }
        artwork.setMedium(doc.getString("medium"));
        artwork.setDimensions(doc.getString("dimensions"));
        Long yearCreated = doc.getLong("yearCreated");
        if (yearCreated != null) {
            artwork.setYearCreated(yearCreated.intValue());
        }
        
        // Handle price - can be String or Double
        Object priceObj = doc.get("price");
        if (priceObj != null) {
            if (priceObj instanceof String) {
                artwork.setPrice(new BigDecimal((String) priceObj));
            } else if (priceObj instanceof Double) {
                artwork.setPrice(BigDecimal.valueOf((Double) priceObj));
            } else if (priceObj instanceof Number) {
                artwork.setPrice(BigDecimal.valueOf(((Number) priceObj).doubleValue()));
            }
        }
        
        artwork.setCurrency(doc.getString("currency"));
        String statusStr = doc.getString("status");
        if (statusStr != null && !statusStr.trim().isEmpty()) {
            try {
                artwork.setStatus(Artwork.ArtworkStatus.valueOf(statusStr.toUpperCase()));
            } catch (IllegalArgumentException e) {
                logger.warn("Invalid status value in Firestore: " + statusStr + " for artwork " + doc.getId() + ", defaulting to DRAFT");
                artwork.setStatus(Artwork.ArtworkStatus.DRAFT);
            }
        }
        String saleTypeStr = doc.getString("saleType");
        if (saleTypeStr != null && !saleTypeStr.trim().isEmpty()) {
            try {
                artwork.setSaleType(Artwork.SaleType.valueOf(saleTypeStr.toUpperCase()));
            } catch (IllegalArgumentException e) {
                logger.warn("Invalid saleType value in Firestore: " + saleTypeStr + " for artwork " + doc.getId() + ", defaulting to FIXED_PRICE");
                artwork.setSaleType(Artwork.SaleType.FIXED_PRICE);
            }
        }
        artwork.setFramed(Boolean.TRUE.equals(doc.getBoolean("isFramed")));
        artwork.setOriginal(Boolean.TRUE.equals(doc.getBoolean("isOriginal")));
        artwork.setTags(doc.getString("tags"));
        Long views = doc.getLong("views");
        if (views != null) {
            artwork.setViews(views.intValue());
        }
        Long likes = doc.getLong("likes");
        if (likes != null) {
            artwork.setLikes(likes.intValue());
        }
        String createdAtStr = doc.getString("createdAt");
        if (createdAtStr != null) {
            artwork.setCreatedAt(LocalDateTime.parse(createdAtStr));
        }
        String updatedAtStr = doc.getString("updatedAt");
        if (updatedAtStr != null) {
            artwork.setUpdatedAt(LocalDateTime.parse(updatedAtStr));
        }
        String soldAtStr = doc.getString("soldAt");
        if (soldAtStr != null) {
            artwork.setSoldAt(LocalDateTime.parse(soldAtStr));
        }
        artwork.setLocation(doc.getString("location"));
        artwork.setShippingAvailable(Boolean.TRUE.equals(doc.getBoolean("isShippingAvailable")));
        String shippingCostStr = doc.getString("shippingCost");
        if (shippingCostStr != null) {
            artwork.setShippingCost(new BigDecimal(shippingCostStr));
        }
        // Auction fields
        String auctionStartStr = doc.getString("auctionStartTime");
        if (auctionStartStr != null) {
            artwork.setAuctionStartTime(LocalDateTime.parse(auctionStartStr));
        }
        String auctionEndStr = doc.getString("auctionEndTime");
        if (auctionEndStr != null) {
            artwork.setAuctionEndTime(LocalDateTime.parse(auctionEndStr));
        }
        
        // Handle startingBid - can be String or Double
        Object startingBidObj = doc.get("startingBid");
        if (startingBidObj != null) {
            if (startingBidObj instanceof String) {
                artwork.setStartingBid(new BigDecimal((String) startingBidObj));
            } else if (startingBidObj instanceof Double) {
                artwork.setStartingBid(BigDecimal.valueOf((Double) startingBidObj));
            } else if (startingBidObj instanceof Number) {
                artwork.setStartingBid(BigDecimal.valueOf(((Number) startingBidObj).doubleValue()));
            }
        }
        
        // Handle currentBid - can be String or Double
        Object currentBidObj = doc.get("currentBid");
        if (currentBidObj != null) {
            if (currentBidObj instanceof String) {
                artwork.setCurrentBid(new BigDecimal((String) currentBidObj));
            } else if (currentBidObj instanceof Double) {
                artwork.setCurrentBid(BigDecimal.valueOf((Double) currentBidObj));
            } else if (currentBidObj instanceof Number) {
                artwork.setCurrentBid(BigDecimal.valueOf(((Number) currentBidObj).doubleValue()));
            }
        }
        
        artwork.setHighestBidderId(doc.getString("highestBidderId"));
        Long bidCount = doc.getLong("bidCount");
        if (bidCount != null) {
            artwork.setBidCount(bidCount.intValue());
        }
        
        // Auction winner fields
        artwork.setWinnerId(doc.getString("winnerId"));
        artwork.setWinnerName(doc.getString("winnerName"));
        
        // Handle winningBidAmount - can be String or Double
        Object winningBidAmountObj = doc.get("winningBidAmount");
        if (winningBidAmountObj != null) {
            if (winningBidAmountObj instanceof String) {
                artwork.setWinningBidAmount(new BigDecimal((String) winningBidAmountObj));
            } else if (winningBidAmountObj instanceof Double) {
                artwork.setWinningBidAmount(BigDecimal.valueOf((Double) winningBidAmountObj));
            } else if (winningBidAmountObj instanceof Number) {
                artwork.setWinningBidAmount(BigDecimal.valueOf(((Number) winningBidAmountObj).doubleValue()));
            }
        }
        
        String endedAtStr = doc.getString("endedAt");
        if (endedAtStr != null) {
            artwork.setEndedAt(LocalDateTime.parse(endedAtStr));
        }
        
        return artwork;
    }
    
    /**
     * Check if artwork matches search criteria
     */
    private boolean matchesSearch(Artwork artwork, String search) {
        if (search == null || search.trim().isEmpty()) {
            return true;
        }
        
        String searchLower = search.toLowerCase();
        
        return (artwork.getTitle() != null && artwork.getTitle().toLowerCase().contains(searchLower)) ||
               (artwork.getDescription() != null && artwork.getDescription().toLowerCase().contains(searchLower)) ||
               (artwork.getArtistName() != null && artwork.getArtistName().toLowerCase().contains(searchLower)) ||
               (artwork.getTags() != null && artwork.getTags().toLowerCase().contains(searchLower)) ||
               (artwork.getMedium() != null && artwork.getMedium().toLowerCase().contains(searchLower));
    }
    
    /**
     * Create sample artworks for demonstration
     */
    private List<Artwork> createSampleArtworks() {
        List<Artwork> sampleArtworks = new ArrayList<>();
        
        // Sample artwork 1
        Artwork artwork1 = new Artwork();
        artwork1.setArtworkId("sample-1");
        artwork1.setTitle("Sunset Over Kuala Lumpur");
        artwork1.setDescription("A beautiful acrylic painting capturing the golden hour over Malaysia's capital city");
        artwork1.setArtistName("Ahmad Rahman");
        artwork1.setCategory(Artwork.ArtCategory.PAINTING);
        artwork1.setPrice(new BigDecimal("1500"));
        artwork1.setStatus(Artwork.ArtworkStatus.ACTIVE);
        artwork1.setSaleType(Artwork.SaleType.FIXED_PRICE);
        artwork1.setViews(234);
        artwork1.setLikes(45);
        sampleArtworks.add(artwork1);
        
        // Sample artwork 2 (Auction)
        Artwork artwork2 = new Artwork();
        artwork2.setArtworkId("sample-2");
        artwork2.setTitle("Digital Dreams");
        artwork2.setDescription("A vibrant digital artwork exploring the intersection of technology and nature");
        artwork2.setArtistName("Siti Nurhaliza");
        artwork2.setCategory(Artwork.ArtCategory.DIGITAL_ART);
        artwork2.setStartingBid(new BigDecimal("500"));
        artwork2.setCurrentBid(new BigDecimal("750"));
        artwork2.setStatus(Artwork.ArtworkStatus.ACTIVE);
        artwork2.setSaleType(Artwork.SaleType.AUCTION);
        artwork2.setAuctionStartTime(LocalDateTime.now().minusHours(2));
        artwork2.setAuctionEndTime(LocalDateTime.now().plusDays(2));
        artwork2.setBidCount(8);
        artwork2.setViews(189);
        artwork2.setLikes(67);
        sampleArtworks.add(artwork2);
        
        // Sample artwork 3
        Artwork artwork3 = new Artwork();
        artwork3.setArtworkId("sample-3");
        artwork3.setTitle("Traditional Batik Pattern");
        artwork3.setDescription("Hand-painted batik artwork showcasing traditional Malaysian patterns");
        artwork3.setArtistName("Encik Lim");
        artwork3.setCategory(Artwork.ArtCategory.TEXTILE);
        artwork3.setPrice(new BigDecimal("2200"));
        artwork3.setStatus(Artwork.ArtworkStatus.ACTIVE);
        artwork3.setSaleType(Artwork.SaleType.FIXED_PRICE);
        artwork3.setViews(156);
        artwork3.setLikes(32);
        sampleArtworks.add(artwork3);
        
        return sampleArtworks;
    }
    
    /**
     * Get all artworks for admin with pagination and filtering
     */
    public List<Artwork> getAllArtworksForAdmin(int page, int limit, String search, String status) 
            throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .orderBy("createdAt", Query.Direction.DESCENDING);
            
            // Apply status filter
            if (status != null && !status.trim().isEmpty()) {
                query = query.whereEqualTo("status", status);
            }
            
            // Apply search filter (simplified - searches title)
            if (search != null && !search.trim().isEmpty()) {
                query = query.whereGreaterThanOrEqualTo("title", search)
                           .whereLessThanOrEqualTo("title", search + '\uf8ff');
            }
            
            ApiFuture<QuerySnapshot> future = query.offset(page * limit).limit(limit).get();
            List<QueryDocumentSnapshot> documents = future.get().getDocuments();
            
            List<Artwork> artworks = new ArrayList<>();
            for (QueryDocumentSnapshot document : documents) {
                Artwork artwork = mapToArtwork(document);
                artworks.add(artwork);
            }
            
            return artworks;
        } catch (Exception e) {
            logger.error("Error getting artworks for admin: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get total artworks count with filters
     */
    public long getTotalArtworksCount(String search, String status) 
            throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME);
            
            // Apply status filter
            if (status != null && !status.trim().isEmpty()) {
                query = query.whereEqualTo("status", status);
            }
            
            // Apply search filter
            if (search != null && !search.trim().isEmpty()) {
                query = query.whereGreaterThanOrEqualTo("title", search)
                           .whereLessThanOrEqualTo("title", search + '\uf8ff');
            }
            
            ApiFuture<QuerySnapshot> future = query.get();
            return future.get().size();
        } catch (Exception e) {
            logger.error("Error getting artworks count: {}", e.getMessage(), e);
            return 0;
        }
    }
    
    /**
     * Get active auctions count
     */
    public long getActiveAuctionsCount() throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("saleType", "AUCTION")
                .whereEqualTo("status", "ACTIVE");
            
            ApiFuture<QuerySnapshot> future = query.get();
            return future.get().size();
        } catch (Exception e) {
            logger.error("Error getting active auctions count: {}", e.getMessage(), e);
            return 0;
        }
    }
    
    /**
     * Get total platform revenue (placeholder - implement based on transaction system)
     */
    public double getTotalPlatformRevenue() {
        // Placeholder implementation
        // In a real system, this would query actual transaction records
        return 125000.50; // Sample value
    }
    
    /**
     * Get monthly revenue (placeholder - implement based on transaction system)
     */
    public double getMonthlyRevenue() {
        // Placeholder implementation
        // In a real system, this would query transactions for current month
        return 15750.25; // Sample value
    }
    
    /**
     * Update artwork feature status
     */
    public boolean updateArtworkFeatureStatus(String artworkId, boolean isFeatured) 
            throws ExecutionException, InterruptedException {
        try {
            Map<String, Object> updates = new HashMap<>();
            updates.put("isFeatured", isFeatured);
            updates.put("updatedAt", LocalDateTime.now().toString());
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(artworkId)
                .update(updates);
            
            result.get();
            logger.info("Artwork feature status updated: {} -> {}", artworkId, isFeatured);
            return true;
        } catch (Exception e) {
            logger.error("Error updating artwork feature status: {}", e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * Remove artwork (soft delete by changing status)
     */
    public boolean removeArtwork(String artworkId) throws ExecutionException, InterruptedException {
        try {
            Map<String, Object> updates = new HashMap<>();
            updates.put("status", "REMOVED");
            updates.put("updatedAt", LocalDateTime.now().toString());
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(artworkId)
                .update(updates);
            
            result.get();
            logger.info("Artwork removed: {}", artworkId);
            return true;
        } catch (Exception e) {
            logger.error("Error removing artwork: {}", e.getMessage(), e);
            return false;
        }
    }
    
    /**
     * Get count of all bids received on artworks created by an artist
     */
    public long getArtistReceivedBidsCount(String artistId) throws ExecutionException, InterruptedException {
        try {
            logger.info("=== getArtistReceivedBidsCount called for artistId: " + artistId + " ===");
            
            // First, get all artwork IDs created by this artist
            Query artworkQuery = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("artistId", artistId);
            
            QuerySnapshot artworkSnapshot = artworkQuery.get().get();
            
            if (artworkSnapshot.isEmpty()) {
                logger.info("No artworks found for artist " + artistId);
                return 0;
            }
            
            // Count total bids on all artist's artworks
            long totalBidsReceived = 0;
            
            for (QueryDocumentSnapshot artworkDoc : artworkSnapshot.getDocuments()) {
                String artworkId = artworkDoc.getId();
                
                // Count bids for this artwork
                Query bidQuery = firestore.collection("bid_history")
                    .whereEqualTo("auctionId", artworkId);
                
                QuerySnapshot bidSnapshot = bidQuery.get().get();
                long bidsForArtwork = bidSnapshot.size();
                
                logger.info("Artwork " + artworkId + " has " + bidsForArtwork + " bids");
                totalBidsReceived += bidsForArtwork;
            }
            
            logger.info("Total bids received on artist " + artistId + "'s artworks: " + totalBidsReceived);
            return totalBidsReceived;
            
        } catch (Exception e) {
            logger.error("Error getting artist received bids count", e);
            return 0;
        }
    }
}
