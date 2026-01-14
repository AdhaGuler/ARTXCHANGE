package com.artexchange.model;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

/**
 * Artwork model representing art pieces on the platform
 */
public class Artwork {
    private String artworkId;
    private String title;
    private String description;
    private String artistId;
    private String artistName;
    private List<String> imageUrls;
    private String primaryImageUrl;
    private ArtCategory category;
    private String medium;
    private String dimensions;
    private int yearCreated;
    private BigDecimal price;
    private String currency;
    private ArtworkStatus status;
    private SaleType saleType;
    private boolean isFramed;
    private boolean isOriginal;
    private String tags;
    private int views;
    private int likes;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime soldAt;
    private String location;
    private boolean isShippingAvailable;
    private BigDecimal shippingCost;
    
    // Auction specific fields
    private LocalDateTime auctionStartTime;
    private LocalDateTime auctionEndTime;
    private BigDecimal startingBid;
    private BigDecimal currentBid;
    private String highestBidderId;
    private int bidCount;
    
    // Auction winner fields
    private String winnerId;
    private String winnerName;
    private BigDecimal winningBidAmount;
    private LocalDateTime endedAt;
    
    public enum ArtCategory {
        PAINTING("Painting"),
        SCULPTURE("Sculpture"),
        PHOTOGRAPHY("Photography"),
        DIGITAL_ART("Digital Art"),
        DRAWING("Drawing"),
        MIXED_MEDIA("Mixed Media"),
        TEXTILE("Textile"),
        CERAMICS("Ceramics"),
        PRINTMAKING("Printmaking"),
        INSTALLATION("Installation"),
        OTHER("Other");
        
        private final String displayName;
        
        ArtCategory(String displayName) {
            this.displayName = displayName;
        }
        
        public String getDisplayName() {
            return displayName;
        }
    }
    
    public enum ArtworkStatus {
        DRAFT, ACTIVE, SOLD, INACTIVE, PENDING_APPROVAL, REJECTED
    }
    
    public enum SaleType {
        FIXED_PRICE, AUCTION, NEGOTIABLE
    }
    
    // Constructors
    public Artwork() {
        this.imageUrls = new ArrayList<>();
        this.currency = "MYR";
        this.status = ArtworkStatus.DRAFT;
        this.saleType = SaleType.FIXED_PRICE;
        this.views = 0;
        this.likes = 0;
        this.createdAt = LocalDateTime.now();
        this.updatedAt = LocalDateTime.now();
    }
    
    public Artwork(String title, String description, String artistId, BigDecimal price) {
        this();
        this.title = title;
        this.description = description;
        this.artistId = artistId;
        this.price = price;
    }
    
    // Getters and Setters
    public String getArtworkId() { return artworkId; }
    public void setArtworkId(String artworkId) { this.artworkId = artworkId; }
    
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    
    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public String getArtistId() { return artistId; }
    public void setArtistId(String artistId) { this.artistId = artistId; }
    
    public String getArtistName() { return artistName; }
    public void setArtistName(String artistName) { this.artistName = artistName; }
    
    public List<String> getImageUrls() { return imageUrls; }
    public void setImageUrls(List<String> imageUrls) { this.imageUrls = imageUrls; }
    
    public String getPrimaryImageUrl() { return primaryImageUrl; }
    public void setPrimaryImageUrl(String primaryImageUrl) { this.primaryImageUrl = primaryImageUrl; }
    
    public ArtCategory getCategory() { return category; }
    public void setCategory(ArtCategory category) { this.category = category; }
    
    public String getMedium() { return medium; }
    public void setMedium(String medium) { this.medium = medium; }
    
    public String getDimensions() { return dimensions; }
    public void setDimensions(String dimensions) { this.dimensions = dimensions; }
    
    public int getYearCreated() { return yearCreated; }
    public void setYearCreated(int yearCreated) { this.yearCreated = yearCreated; }
    
    public BigDecimal getPrice() { return price; }
    public void setPrice(BigDecimal price) { this.price = price; }
    
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    
    public ArtworkStatus getStatus() { return status; }
    public void setStatus(ArtworkStatus status) { this.status = status; }
    
    public SaleType getSaleType() { return saleType; }
    public void setSaleType(SaleType saleType) { this.saleType = saleType; }
    
    public boolean isFramed() { return isFramed; }
    public void setFramed(boolean framed) { isFramed = framed; }
    
    public boolean isOriginal() { return isOriginal; }
    public void setOriginal(boolean original) { isOriginal = original; }
    
    public String getTags() { return tags; }
    public void setTags(String tags) { this.tags = tags; }
    
    public int getViews() { return views; }
    public void setViews(int views) { this.views = views; }
    
    public int getLikes() { return likes; }
    public void setLikes(int likes) { this.likes = likes; }
    
    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
    
    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
    
    public LocalDateTime getSoldAt() { return soldAt; }
    public void setSoldAt(LocalDateTime soldAt) { this.soldAt = soldAt; }
    
    public String getLocation() { return location; }
    public void setLocation(String location) { this.location = location; }
    
    public boolean isShippingAvailable() { return isShippingAvailable; }
    public void setShippingAvailable(boolean shippingAvailable) { isShippingAvailable = shippingAvailable; }
    
    public BigDecimal getShippingCost() { return shippingCost; }
    public void setShippingCost(BigDecimal shippingCost) { this.shippingCost = shippingCost; }
    
    // Auction specific getters and setters
    public LocalDateTime getAuctionStartTime() { return auctionStartTime; }
    public void setAuctionStartTime(LocalDateTime auctionStartTime) { this.auctionStartTime = auctionStartTime; }
    
    public LocalDateTime getAuctionEndTime() { return auctionEndTime; }
    public void setAuctionEndTime(LocalDateTime auctionEndTime) { this.auctionEndTime = auctionEndTime; }
    
    public BigDecimal getStartingBid() { return startingBid; }
    public void setStartingBid(BigDecimal startingBid) { this.startingBid = startingBid; }
    
    public BigDecimal getCurrentBid() { return currentBid; }
    public void setCurrentBid(BigDecimal currentBid) { this.currentBid = currentBid; }
    
    public String getHighestBidderId() { return highestBidderId; }
    public void setHighestBidderId(String highestBidderId) { this.highestBidderId = highestBidderId; }
    
    public int getBidCount() { return bidCount; }
    public void setBidCount(int bidCount) { this.bidCount = bidCount; }
    
    // Auction winner getters and setters
    public String getWinnerId() { return winnerId; }
    public void setWinnerId(String winnerId) { this.winnerId = winnerId; }
    
    public String getWinnerName() { return winnerName; }
    public void setWinnerName(String winnerName) { this.winnerName = winnerName; }
    
    public BigDecimal getWinningBidAmount() { return winningBidAmount; }
    public void setWinningBidAmount(BigDecimal winningBidAmount) { this.winningBidAmount = winningBidAmount; }
    
    public LocalDateTime getEndedAt() { return endedAt; }
    public void setEndedAt(LocalDateTime endedAt) { this.endedAt = endedAt; }
    
    // Utility methods
    public boolean isAuction() {
        return saleType == SaleType.AUCTION;
    }
    
    public boolean isAuctionActive() {
        if (!isAuction()) return false;
        LocalDateTime now = LocalDateTime.now();
        return auctionStartTime != null && auctionEndTime != null &&
               now.isAfter(auctionStartTime) && now.isBefore(auctionEndTime);
    }
    
    public boolean isAuctionEnded() {
        if (!isAuction()) return false;
        return auctionEndTime != null && LocalDateTime.now().isAfter(auctionEndTime);
    }
    
    public void incrementViews() {
        this.views++;
        this.updatedAt = LocalDateTime.now();
    }
    
    public void incrementLikes() {
        this.likes++;
        this.updatedAt = LocalDateTime.now();
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Artwork artwork = (Artwork) o;
        return Objects.equals(artworkId, artwork.artworkId);
    }
    
    @Override
    public int hashCode() {
        return Objects.hash(artworkId);
    }
    
    @Override
    public String toString() {
        return "Artwork{" +
                "artworkId='" + artworkId + '\'' +
                ", title='" + title + '\'' +
                ", artistId='" + artistId + '\'' +
                ", price=" + price +
                ", status=" + status +
                ", saleType=" + saleType +
                '}';
    }
}
