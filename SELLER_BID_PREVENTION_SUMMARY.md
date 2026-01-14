# Seller Bid Prevention - Implementation Summary

## Overview
Implemented end-to-end enforcement to prevent auction creators (sellers) from placing bids on their own auctions. This includes both backend security enforcement and frontend UX improvements.

## Changes Made

### 1. Backend Changes

#### `src/main/java/com/artexchange/servlet/ArtworkServlet.java`

**Added ownership check in `handlePlaceBid()` method (after line 413):**
```java
// SECURITY: Prevent auction owner from bidding on their own auction
if (artwork.getArtistId() != null && artwork.getArtistId().equals(currentUserId)) {
    logger.warn("Auction owner attempted to bid on their own auction. User ID: " + currentUserId + ", Artwork ID: " + artworkId);
    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
    sendErrorResponse(response, "Owners cannot bid on their own auctions.");
    return;
}
```

**Security Features:**
- Uses session-based authentication (`SessionUtil.getCurrentUserId()`)
- Compares authenticated user ID with artwork's `artistId`
- Returns HTTP 403 Forbidden with clear error message
- Logs the attempt for security monitoring

#### `src/main/java/com/artexchange/servlet/AuctionServlet.java`

**Added ownership check in `handlePlaceBid()` method (after line 249):**
```java
// SECURITY: Prevent auction owner from bidding on their own auction
Auction auction = auctionDAO.getAuctionById(auctionId);
if (auction != null && auction.getArtistId() != null && auction.getArtistId().equals(authenticatedUser.getUserId())) {
    logger.warning("Auction owner attempted to bid on their own auction. User ID: " + authenticatedUser.getUserId() + ", Auction ID: " + auctionId);
    response.setStatus(HttpServletResponse.SC_FORBIDDEN);
    response.getWriter().write("{\"success\": false, \"error\": \"Owners cannot bid on their own auctions.\"}");
    return;
}
```

**Security Features:**
- Uses authenticated user from session or Firebase token
- Fetches auction to get `artistId`
- Returns HTTP 403 Forbidden with JSON error
- Logs the attempt

### 2. Frontend Changes

#### `src/main/webapp/artwork-detail.jsp`

**Added:**
1. `artistId` to `artworkData` object:
```javascript
const artworkData = {
    id: '<%=artwork.getArtworkId()%>',
    saleType: '<%=artwork.getSaleType()%>',
    artistId: '<%=artwork.getArtistId() != null ? artwork.getArtistId() : ""%>',
    auctionEndTime: '<%=artwork.getAuctionEndTime() != null ? artwork.getAuctionEndTime() : ""%>'
};
```

2. `checkBidButtonVisibility()` function to disable bid button for sellers:
```javascript
function checkBidButtonVisibility() {
    setTimeout(function() {
        if (artworkData.saleType === 'AUCTION' && currentUser && artworkData.artistId) {
            if (currentUser.userId === artworkData.artistId) {
                const bidButton = document.querySelector('button[onclick*="placeBid"]');
                if (bidButton) {
                    bidButton.disabled = true;
                    bidButton.classList.remove('btn-primary');
                    bidButton.classList.add('btn-secondary');
                    bidButton.innerHTML = '<i class="fas fa-ban me-2"></i>You are the seller — you cannot bid on your own auction';
                    
                    const bidSection = bidButton.closest('.d-grid');
                    if (bidSection) {
                        const message = document.createElement('small');
                        message.className = 'text-muted mt-2 d-block';
                        message.textContent = 'As the seller, you cannot place bids on your own auction.';
                        bidSection.appendChild(message);
                    }
                }
            }
        }
    }, 500);
}
```

3. Updated `placeBid()` function with frontend check and better error handling:
```javascript
function placeBid(artworkId) {
    // ... existing auth check ...
    
    // Frontend check: Prevent artist from bidding on their own auction
    if (currentUser && artworkData.artistId && currentUser.userId === artworkData.artistId) {
        alert('You are the seller — you cannot bid on your own auction.');
        return;
    }
    
    // ... rest of function with improved error handling for 403 ...
}
```

#### `src/main/webapp/browse.jsp`

**Updated:**
1. Error message in `placeBid()` function:
```javascript
if (currentUser && currentArtwork && currentUser.userId === currentArtwork.artistId) {
    alert('You are the seller — you cannot bid on your own auction.');
    return;
}
```

2. Improved error handling in fetch response:
```javascript
.then(response => {
    if (!response.ok) {
        return response.json().then(data => {
            throw new Error(data.error || data.message || 'Failed to place bid');
        });
    }
    return response.json();
})
.catch(error => {
    if (error.message.includes('Owners cannot bid')) {
        alert('You are the seller — you cannot bid on your own auction.');
    } else {
        alert('Bid failed: ' + error.message);
    }
});
```

**Note:** `browse.jsp` already hides the bid button for artists (line 721), so no additional UI changes needed.

#### `src/main/webapp/auctions.jsp`

**Updated error handling in `submitBid()` function:**
```javascript
.catch(error => {
    console.error('Error placing bid:', error);
    if (error.message.includes('Owners cannot bid')) {
        errorElement.textContent = 'You are the seller — you cannot bid on your own auction.';
    } else {
        errorElement.textContent = error.message || 'An error occurred. Please try again later.';
    }
    errorElement.classList.remove('d-none');
});
```

## API Endpoints

### POST /api/artworks/{artworkId}/bid
**Request:**
```json
{
  "amount": 150.00
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bid placed successfully",
  "currentBid": 150.00,
  "bidCount": 5
}
```

**Error Response - Owner Attempts Bid (403):**
```json
{
  "success": false,
  "error": "Owners cannot bid on their own auctions."
}
```

### POST /api/auctions/{auctionId}/bid
**Request:**
```json
{
  "amount": 150.00,
  "idToken": "firebase_token_here"
}
```

**Success Response (200):**
```json
{
  "success": true,
  "message": "Bid placed successfully",
  "bidAmount": 150.00,
  "auctionId": "abc123",
  "userId": "user42"
}
```

**Error Response - Owner Attempts Bid (403):**
```json
{
  "success": false,
  "error": "Owners cannot bid on their own auctions."
}
```

## Test Cases

### Test A: Seller Tries to Bid (Backend)
**Setup:**
1. Create auction as user "artist1" (artworkId: "art123")
2. Authenticate as "artist1"
3. POST to `/api/artworks/art123/bid` with `{"amount": 200.00}`

**Expected Result:**
- HTTP Status: 403 Forbidden
- Response: `{"success": false, "error": "Owners cannot bid on their own auctions."}`
- Log entry: "Auction owner attempted to bid on their own auction. User ID: artist1, Artwork ID: art123"

### Test B: Different Buyer Bids (Backend)
**Setup:**
1. Create auction as user "artist1" (artworkId: "art123")
2. Authenticate as "buyer1" (different user)
3. POST to `/api/artworks/art123/bid` with `{"amount": 200.00}`

**Expected Result:**
- HTTP Status: 200 OK (or 201 Created)
- Response: `{"success": true, "message": "Bid placed successfully", ...}`
- Bid is saved to database

### Test C: UI Test - Seller Views Own Auction
**Setup:**
1. Login as "artist1"
2. Navigate to artwork detail page for own auction
3. Observe bid button

**Expected Result:**
- Bid button is disabled
- Button text: "You are the seller — you cannot bid on your own auction"
- Message below button: "As the seller, you cannot place bids on your own auction."
- Button has `btn-secondary` class (grayed out)

### Test D: UI Test - Buyer Views Auction
**Setup:**
1. Login as "buyer1"
2. Navigate to artwork detail page for auction created by "artist1"
3. Observe bid button

**Expected Result:**
- Bid button is enabled
- Button text: "Place Bid"
- Button has `btn-primary` class
- Clicking button opens bid prompt

## Security Notes

1. **Backend Enforcement is Mandatory:** Frontend checks are for UX only. Backend always validates ownership.
2. **Session-Based Auth:** Uses `SessionUtil.getCurrentUserId()` - never trusts client-supplied user IDs.
3. **Logging:** All ownership violation attempts are logged for security monitoring.
4. **Error Messages:** Clear, user-friendly error messages without exposing system internals.

## Files Modified

1. `src/main/java/com/artexchange/servlet/ArtworkServlet.java` - Added ownership check
2. `src/main/java/com/artexchange/servlet/AuctionServlet.java` - Added ownership check
3. `src/main/webapp/artwork-detail.jsp` - Added UI disable logic and error handling
4. `src/main/webapp/browse.jsp` - Updated error handling
5. `src/main/webapp/auctions.jsp` - Updated error handling

## Database Assumptions

- Artwork table has `artistId` column (already exists)
- Auction table/model has `artistId` field (already exists)
- No database constraints needed - logic enforced in application layer

## How to Test Locally

1. **Start the application:**
   ```bash
   mvn clean install
   mvn tomcat7:run
   ```

2. **Test as Seller:**
   - Login as an artist
   - Create an auction artwork
   - Try to place a bid on your own auction
   - Verify: Button is disabled, backend returns 403

3. **Test as Buyer:**
   - Login as a different user (buyer)
   - Navigate to the auction created above
   - Place a bid
   - Verify: Bid is accepted, backend returns 200

4. **Check Logs:**
   - Look for warning messages when seller attempts to bid
   - Verify user ID and artwork ID are logged

## Example Test Logs

### Successful Bid (Buyer)
```
INFO: Authenticated user for bid: buyer@example.com (ID: buyer1)
INFO: Parsed bid amount: 200.0
INFO: Bid placed successfully for auction art123 by user buyer1 with amount 200.0
```

### Rejected Bid (Seller)
```
WARN: Auction owner attempted to bid on their own auction. User ID: artist1, Artwork ID: art123
```

## Next Steps

1. Consider adding unit tests for the ownership check
2. Add integration tests for the bid endpoints
3. Monitor logs for repeated violation attempts (potential abuse)
4. Consider rate limiting on bid endpoints
















