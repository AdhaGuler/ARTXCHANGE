package com.artexchange.model;

import java.time.LocalDateTime;

/**
 * Follow model representing follow relationships between users
 */
public class Follow {
    private String followId;
    private String followerId;
    private String followingId;
    private LocalDateTime createdAt;
    
    // Constructors
    public Follow() {}
    
    public Follow(String followerId, String followingId) {
        this.followerId = followerId;
        this.followingId = followingId;
        this.createdAt = LocalDateTime.now();
    }
    
    // Getters and Setters
    public String getFollowId() { return followId; }
    public void setFollowId(String followId) { this.followId = followId; }
    
    public String getFollowerId() { return followerId; }
    public void setFollowerId(String followerId) { this.followerId = followerId; }
    
    public String getFollowingId() { return followingId; }
    public void setFollowingId(String followingId) { this.followingId = followingId; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Follow follow = (Follow) o;
        return followId != null && followId.equals(follow.followId);
    }
    
    @Override
    public int hashCode() {
        return followId != null ? followId.hashCode() : 0;
    }
    
    @Override
    public String toString() {
        return "Follow{" +
                "followId='" + followId + '\'' +
                ", followerId='" + followerId + '\'' +
                ", followingId='" + followingId + '\'' +
                ", createdAt=" + createdAt +
                '}';
    }
}
