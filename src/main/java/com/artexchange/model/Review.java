package com.artexchange.model;

import java.time.Instant;

/**
 * Review model representing buyer reviews for artworks
 * Uses Instant instead of LocalDateTime for Java 17 compatibility
 */
public class Review {
    private String reviewId;
    private String artworkId;
    private String artistId; // sellerId - the artist being reviewed
    private String buyerId; // the buyer who wrote the review
    private Integer rating; // 1-5 stars
    private String reviewText;
    private Instant reviewDate; // Changed from LocalDateTime to Instant for Java 17 compatibility
    private boolean verified; // whether the buyer is verified
    
    // Constructors
    public Review() {
        // reviewDate will be set explicitly when creating review
        this.verified = true; // All reviews from purchases are verified
    }
    
    public Review(String artworkId, String artistId, String buyerId, Integer rating, String reviewText) {
        this();
        this.artworkId = artworkId;
        this.artistId = artistId;
        this.buyerId = buyerId;
        this.rating = rating;
        this.reviewText = reviewText;
    }
    
    // Getters and Setters
    public String getReviewId() {
        return reviewId;
    }
    
    public void setReviewId(String reviewId) {
        this.reviewId = reviewId;
    }
    
    public String getArtworkId() {
        return artworkId;
    }
    
    public void setArtworkId(String artworkId) {
        this.artworkId = artworkId;
    }
    
    public String getArtistId() {
        return artistId;
    }
    
    public void setArtistId(String artistId) {
        this.artistId = artistId;
    }
    
    public String getBuyerId() {
        return buyerId;
    }
    
    public void setBuyerId(String buyerId) {
        this.buyerId = buyerId;
    }
    
    public Integer getRating() {
        return rating;
    }
    
    public void setRating(Integer rating) {
        this.rating = rating;
    }
    
    public String getReviewText() {
        return reviewText;
    }
    
    public void setReviewText(String reviewText) {
        this.reviewText = reviewText;
    }
    
    public Instant getReviewDate() {
        return reviewDate;
    }
    
    public void setReviewDate(Instant reviewDate) {
        this.reviewDate = reviewDate;
    }
    
    public boolean isVerified() {
        return verified;
    }
    
    public void setVerified(boolean verified) {
        this.verified = verified;
    }
    
    @Override
    public String toString() {
        return "Review{" +
                "reviewId='" + reviewId + '\'' +
                ", artworkId='" + artworkId + '\'' +
                ", artistId='" + artistId + '\'' +
                ", buyerId='" + buyerId + '\'' +
                ", rating=" + rating +
                ", reviewDate=" + reviewDate +
                '}';
    }
}

