package com.artexchange.dao;

import com.artexchange.config.FirebaseConfig;
import com.artexchange.model.Follow;
import com.google.api.core.ApiFuture;
import com.google.cloud.firestore.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.time.ZoneOffset;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ExecutionException;

/**
 * Data Access Object for Follow operations with Firestore
 */
public class FollowDAO {
    private static final Logger logger = LoggerFactory.getLogger(FollowDAO.class);
    private static final String COLLECTION_NAME = "follows";
    private final Firestore firestore;
    
    public FollowDAO() {
        this.firestore = FirebaseConfig.getFirestore();
    }
    
    /**
     * Follow a user
     */
    public String followUser(String followerId, String followingId) throws ExecutionException, InterruptedException {
        try {
            // Check if already following
            if (isFollowing(followerId, followingId)) {
                logger.warn("User {} is already following user {}", followerId, followingId);
                return null;
            }
            
            Follow follow = new Follow(followerId, followingId);
            DocumentReference docRef = firestore.collection(COLLECTION_NAME).document();
            follow.setFollowId(docRef.getId());
            
            Map<String, Object> followData = followToMap(follow);
            
            ApiFuture<WriteResult> result = docRef.set(followData);
            result.get();
            
            logger.info("User {} started following user {}", followerId, followingId);
            return follow.getFollowId();
            
        } catch (Exception e) {
            logger.error("Error following user: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Unfollow a user
     */
    public boolean unfollowUser(String followerId, String followingId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("followerId", followerId)
                .whereEqualTo("followingId", followingId)
                .limit(1);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            if (!documents.isEmpty()) {
                ApiFuture<WriteResult> result = documents.get(0).getReference().delete();
                result.get();
                logger.info("User {} unfollowed user {}", followerId, followingId);
                return true;
            }
            
            return false;
            
        } catch (Exception e) {
            logger.error("Error unfollowing user: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Check if a user is following another user
     */
    public boolean isFollowing(String followerId, String followingId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("followerId", followerId)
                .whereEqualTo("followingId", followingId)
                .limit(1);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            return !documents.isEmpty();
            
        } catch (Exception e) {
            logger.error("Error checking follow status: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get follower count for a user
     */
    public int getFollowerCount(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("followingId", userId);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            return querySnapshot.get().getDocuments().size();
            
        } catch (Exception e) {
            logger.error("Error getting follower count: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get following count for a user
     */
    public int getFollowingCount(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("followerId", userId);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            return querySnapshot.get().getDocuments().size();
            
        } catch (Exception e) {
            logger.error("Error getting following count: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get users that the given user is following
     */
    public List<String> getFollowing(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("followerId", userId);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            List<String> following = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                following.add(doc.getString("followingId"));
            }
            
            return following;
            
        } catch (Exception e) {
            logger.error("Error getting following list: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Get followers of a user
     */
    public List<String> getFollowers(String userId) throws ExecutionException, InterruptedException {
        try {
            Query query = firestore.collection(COLLECTION_NAME)
                .whereEqualTo("followingId", userId);
            
            ApiFuture<QuerySnapshot> querySnapshot = query.get();
            List<QueryDocumentSnapshot> documents = querySnapshot.get().getDocuments();
            
            List<String> followers = new ArrayList<>();
            for (DocumentSnapshot doc : documents) {
                followers.add(doc.getString("followerId"));
            }
            
            return followers;
            
        } catch (Exception e) {
            logger.error("Error getting followers list: {}", e.getMessage(), e);
            throw e;
        }
    }
    
    /**
     * Convert Follow object to Map for Firestore
     */
    private Map<String, Object> followToMap(Follow follow) {
        Map<String, Object> map = new HashMap<>();
        map.put("followId", follow.getFollowId());
        map.put("followerId", follow.getFollowerId());
        map.put("followingId", follow.getFollowingId());
        map.put("createdAt", follow.getCreatedAt() != null ? 
            Date.from(follow.getCreatedAt().toInstant(ZoneOffset.UTC)) : new Date());
        return map;
    }
    
    /**
     * Convert Firestore document to Follow object
     */
    private Follow mapToFollow(DocumentSnapshot doc) {
        Follow follow = new Follow();
        follow.setFollowId(doc.getId());
        follow.setFollowerId(doc.getString("followerId"));
        follow.setFollowingId(doc.getString("followingId"));
        
        Date createdAt = doc.getDate("createdAt");
        if (createdAt != null) {
            follow.setCreatedAt(LocalDateTime.ofInstant(createdAt.toInstant(), ZoneOffset.UTC));
        }
        
        return follow;
    }
}
