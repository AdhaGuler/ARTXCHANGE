package com.artexchange.dao;

import com.artexchange.config.FirebaseConfig;
import com.artexchange.model.Review;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Instant;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Data Access Object for Review operations with Firestore
 */
public class ReviewDAO {
    private static final Logger logger = LoggerFactory.getLogger(ReviewDAO.class);
    private static final String COLLECTION_NAME = "reviews";
    private final Firestore firestore;
    
    public ReviewDAO() {
        this.firestore = FirebaseConfig.getFirestore();
    }
    
    /**
     * Save review to Firestore
     */
    public String saveReview(Review review) throws ExecutionException, InterruptedException {
        try {
            // Generate ID if not provided
            if (review.getReviewId() == null || review.getReviewId().isEmpty()) {
                DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
                review.setReviewId(docRef.getId());
            }
            
            Map<String, Object> reviewData = reviewToMap(review);
            
            ApiFuture<WriteResult> result = firestore.collection(COLLECTION_NAME)
                .document(review.getReviewId())
                .set(reviewData);
            
            result.get();
            logger.info("Review saved successfully: {}", review.getReviewId());
            return review.getReviewId();
            
        } catch (Exception e) {
            logger.error("Error saving review: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find reviews by artist ID (seller ID)
     * This is the main query for displaying reviews on artist profile
     * CRITICAL: This queries WHERE artistId == artistId (the viewed artist's ID)
     */
    public List<Review> findByArtistId(String artistId) throws ExecutionException, InterruptedException {
        try {
            logger.info("=== ReviewDAO.findByArtistId() ===");
            logger.info("Querying reviews WHERE artistId = {}", artistId);
            
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("artistId", artistId)
                .orderBy("reviewDate", Query.Direction.DESCENDING);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            logger.info("Found {} reviews for artistId: {}", documents.size(), artistId);
            
            // Debug: Log each review's artistId to verify data
            for (QueryDocumentSnapshot doc : documents) {
                String docArtistId = doc.getString("artistId");
                logger.info("  Review {} - artistId in DB: {}", doc.getId(), docArtistId);
            }
            
            List<Review> reviews = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                try {
                    Review review = mapToReview(doc);
                    if (review != null) {
                        reviews.add(review);
                    }
                } catch (Exception e) {
                    logger.warn("Error mapping review document {}: {}", doc.getId(), e.getMessage());
                }
            }
            
            logger.info("Successfully mapped {} reviews for artistId: {}", reviews.size(), artistId);
            return reviews;
            
        } catch (Exception e) {
            logger.error("Error finding reviews by artistId {}: {}", artistId, e.getMessage(), e);
            // If orderBy fails (e.g., missing index), try without it
            try {
                Query query = firestore.collection(COLLECTION_NAME)
                    .whereEqualTo("artistId", artistId);
                
                ApiFuture<QuerySnapshot> querySnapshot = query.get();
                List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
                
                List<Review> reviews = new ArrayList<>();
                for (DocumentSnapshot doc : documents) {
                    try {
                        Review review = mapToReview(doc);
                        if (review != null) {
                            reviews.add(review);
                        }
                    } catch (Exception e2) {
                        logger.warn("Error mapping review document {}: {}", doc.getId(), e2.getMessage());
                    }
                }
                
                // Sort manually by reviewDate descending
                reviews.sort((a, b) -> {
                    if (a.getReviewDate() == null && b.getReviewDate() == null) return 0;
                    if (a.getReviewDate() == null) return 1;
                    if (b.getReviewDate() == null) return -1;
                    return b.getReviewDate().compareTo(a.getReviewDate());
                });
                
                logger.info("Successfully mapped {} reviews (without orderBy) for artistId: {}", reviews.size(), artistId);
                return reviews;
            } catch (Exception e2) {
                logger.error("Error finding reviews by artistId (fallback): {}", e2.getMessage(), e2);
                throw e2;
            }
        }
    }
    
    /**
     * Find review by ID
     */
    public Review findById(String reviewId) throws ExecutionException, InterruptedException {
        try {
            DocumentReference docRef = firestore.collection(COLLECTION_NAME).document(reviewId);
            ApiFuture<DocumentSnapshot> future = docRef.get();
            DocumentSnapshot document = future.get();
            
            if (document.exists()) {
                return mapToReview(document);
            }
            return null;
            
        } catch (Exception e) {
            logger.error("Error finding review by ID: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Find reviews by artwork ID
     */
    public List<Review> findByArtworkId(String artworkId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("artworkId", artworkId)
                .orderBy("reviewDate", Query.Direction.DESCENDING);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            List<Review> reviews = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                try {
                    Review review = mapToReview(doc);
                    if (review != null) {
                        reviews.add(review);
                    }
                } catch (Exception e) {
                    logger.warn("Error mapping review document {}: {}", doc.getId(), e.getMessage());
                }
            }
            
            return reviews;
            
        } catch (Exception e) {
            logger.error("Error finding reviews by artworkId: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Convert Review object to Map for Firestore
     */
    private Map<String, Object> reviewToMap(Review review) {
        Map<String, Object> map = new HashMap<>();
        if (review.getReviewId() != null) {
            map.put("reviewId", review.getReviewId());
        }
        if (review.getArtworkId() != null) {
            map.put("artworkId", review.getArtworkId());
        }
        if (review.getArtistId() != null) {
            map.put("artistId", review.getArtistId());
        }
        if (review.getBuyerId() != null) {
            map.put("buyerId", review.getBuyerId());
        }
        if (review.getRating() != null) {
            map.put("rating", review.getRating());
        }
        if (review.getReviewText() != null) {
            map.put("reviewText", review.getReviewText());
        }
        if (review.getReviewDate() != null) {
            // Store Instant as Timestamp for Firestore
            // Convert Instant to Date, then to Timestamp
            java.util.Date date = java.util.Date.from(review.getReviewDate());
            map.put("reviewDate", com.google.cloud.Timestamp.of(date));
        }
        map.put("verified", review.isVerified());
        return map;
    }
    
    /**
     * Convert Firestore DocumentSnapshot to Review object
     */
    private Review mapToReview(DocumentSnapshot doc) {
        try {
            Review review = new Review();
            review.setReviewId(doc.getString("reviewId"));
            if (review.getReviewId() == null) {
                review.setReviewId(doc.getId());
            }
            review.setArtworkId(doc.getString("artworkId"));
            review.setArtistId(doc.getString("artistId"));
            review.setBuyerId(doc.getString("buyerId"));
            
            // Handle rating - could be Integer or Long
            Object ratingObj = doc.get("rating");
            if (ratingObj != null) {
                if (ratingObj instanceof Integer) {
                    review.setRating((Integer) ratingObj);
                } else if (ratingObj instanceof Long) {
                    review.setRating(((Long) ratingObj).intValue());
                }
            }
            
            review.setReviewText(doc.getString("reviewText"));
            
            // Handle reviewDate - convert from Firestore Timestamp to Instant
            Object dateObj = doc.get("reviewDate");
            if (dateObj != null) {
                if (dateObj instanceof com.google.cloud.Timestamp) {
                    com.google.cloud.Timestamp timestamp = (com.google.cloud.Timestamp) dateObj;
                    review.setReviewDate(timestamp.toDate().toInstant());
                } else if (dateObj instanceof Instant) {
                    review.setReviewDate((Instant) dateObj);
                }
            }
            
            Boolean verified = doc.getBoolean("verified");
            review.setVerified(verified != null ? verified : true);
            
            return review;
            
        } catch (Exception e) {
            logger.error("Error mapping document to Review: {}", e.getMessage(), e);
            return null;
        }
    }
}

