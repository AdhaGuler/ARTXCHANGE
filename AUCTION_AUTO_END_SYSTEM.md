# Automatic Auction Ending System

## Overview
This document describes the complete automatic auction ending system that processes expired auctions, determines winners, creates purchase records, and sends notifications—all without manual intervention.

---

## System Components

### 1. **AuctionSchedulerListener** (NEW)
**Location:** `src/main/java/com/artexchange/listener/AuctionSchedulerListener.java`

**Purpose:** Starts a background scheduler when the application starts

**Functionality:**
- Runs automatically on application startup (`@WebListener`)
- Schedules `AuctionProcessor.processAllEndedAuctions()` to run every 60 seconds
- Initial delay of 30 seconds to allow app initialization
- Gracefully shuts down when application stops

**Configuration:**
```java
- Check Interval: Every 60 seconds
- Initial Delay: 30 seconds after startup
- Thread Pool Size: 1 dedicated thread
```

---

### 2. **AuctionProcessor**
**Location:** `src/main/java/com/artexchange/util/AuctionProcessor.java`

**Purpose:** Core logic for processing ended auctions

**Key Methods:**

#### `processAllEndedAuctions()`
- Queries all ACTIVE auctions from Firestore
- Filters auctions where `auctionEndTime < currentTime`
- Skips already processed auctions (those with winnerId set)
- Calls `processEndedAuction()` for each expired auction

#### `processEndedAuction(String artworkId)`
Complete auction processing workflow:

1. **Winner Determination:**
   - Queries `bid_history` collection for all bids
   - Finds highest bid by amount
   - Retrieves winner user details (name, ID)
   - Handles "no bids" scenario (sets status to INACTIVE)

2. **Auction Locking:**
   - Uses Firestore transaction for atomic updates
   - Sets artwork status to "SOLD"
   - Records winner information:
     - `winnerId`
     - `winnerName`
     - `winningBidAmount`
     - `endedAt` timestamp
     - `soldAt` timestamp
   - Prevents race conditions and duplicate processing

3. **Purchase Record Creation:**
   - Creates `Purchase` object with:
     - Artwork ID
     - Winner ID (buyer)
     - Artist ID (seller)
     - Winning bid amount
   - Sets status to "COMPLETED"
   - Payment method: "AUCTION_WIN"
   - Generates transaction ID: `AUCTION_{artworkId}_{timestamp}`
   - Saves to Firestore via `PurchaseDAO`

4. **Notification Dispatch:**
   - Calls `NotificationUtil.sendAuctionWinnerNotifications()`
   - Sends to both winner and seller
   - Non-blocking (errors logged but don't stop process)

**Error Handling:**
- Logs all errors
- Continues processing even if notifications fail
- Transaction ensures atomicity of winner updates

---

### 3. **NotificationUtil**
**Location:** `src/main/java/com/artexchange/util/NotificationUtil.java`

**Purpose:** Sends system-generated notifications

#### `sendAuctionWinnerNotifications()`
Sends notifications to two parties:

**To Winner (Buyer):**
```
🎉 Congratulations! You have won the auction for "{artworkTitle}". 
Your winning bid was RM {amount}. Please proceed with payment to 
complete your purchase.
```
- Message Type: `PURCHASE_NOTIFICATION`
- Sender: `SYSTEM`
- Contains artwork link
- Marked as unread

**To Seller (Artist):**
```
🏆 Your auction for "{artworkTitle}" has ended. 
Winner: {winnerName} | Winning Bid: RM {amount}. 
View the auction details in your dashboard.
```
- Message Type: `PURCHASE_NOTIFICATION`
- Sender: `SYSTEM`
- Contains winner information
- Marked as unread

---

### 4. **WebSocket Real-Time Monitoring**
**Location:** `src/main/java/com/artexchange/websocket/AuctionWebSocket.java`

**Purpose:** Real-time auction monitoring when users are viewing auctions

**Functionality:**
- When user opens auction page, starts a 1-second timer
- At each tick:
  - Calculates time remaining
  - If time ≤ 0: calls `AuctionProcessor.processEndedAuction()`
  - Broadcasts time updates to all connected clients
- Provides immediate processing for actively watched auctions

**Complements Scheduler:**
- WebSocket: Instant processing when users are watching
- Scheduler: Catches auctions that end when no one is watching

---

### 5. **Bid Prevention System**

Multiple layers prevent late bids:

#### **AuctionServlet (HTTP Endpoint)**
**Location:** `src/main/java/com/artexchange/servlet/AuctionServlet.java`

Checks before accepting bid:
```java
// Check status
if (auction.getStatus().equals("ENDED") || 
    auction.getStatus().equals("CANCELED") || 
    auction.getStatus().equals("INACTIVE")) {
    return "Auction is not active";
}

// Check end time
if (auction.getEndTime().isBefore(LocalDateTime.now())) {
    return "Auction has ended";
}
```

#### **ArtworkServlet**
**Location:** `src/main/java/com/artexchange/servlet/ArtworkServlet.java`

```java
if (!artwork.isAuctionActive()) {
    return "Auction is not active";
}
```

#### **WebSocket**
**Location:** `src/main/java/com/artexchange/websocket/AuctionWebSocket.java`

```java
if (artwork.getAuctionEndTime().isBefore(LocalDateTime.now())) {
    return "Auction has ended";
}
```

---

## Auction Lifecycle

### 1. **Active Auction**
- Status: `ACTIVE`
- Users can place bids
- Timer counts down
- Real-time updates via WebSocket

### 2. **Time Expires**
- **Trigger:** `auctionEndTime < currentTime`
- **Detected by:** 
  - WebSocket timer (if page is open)
  - Scheduled task (runs every 60 seconds)

### 3. **Processing Begins**
- Lock acquisition via Firestore transaction
- Prevents duplicate processing
- Winner determined from bid_history

### 4. **Auction Ends (With Winner)**
- Status: `SOLD`
- Winner details saved
- Purchase record created
- Notifications sent
- Bidders can no longer place bids

### 5. **Auction Ends (No Bids)**
- Status: `INACTIVE`
- No winner
- No purchase record
- Artwork remains unsold

---

## Data Flow Diagram

```
┌─────────────────────────────────────────┐
│   TRIGGER: Auction Time Expires         │
│   (auctionEndTime < currentTime)        │
└────────────┬────────────────────────────┘
             │
      ┌──────┴──────┐
      │             │
      ▼             ▼
┌──────────┐  ┌─────────────────┐
│ WebSocket│  │ Scheduler       │
│ (1sec)   │  │ (60sec)         │
└─────┬────┘  └────────┬────────┘
      │                │
      └────────┬───────┘
               ▼
    ┌─────────────────────────┐
    │ AuctionProcessor        │
    │ .processEndedAuction()  │
    └────────────┬────────────┘
                 │
        ┌────────┴────────┐
        ▼                 ▼
┌──────────────┐  ┌──────────────┐
│ Query        │  │ Transaction  │
│ bid_history  │  │ Lock Auction │
│ Find Winner  │  │ Update Status│
└──────┬───────┘  └──────┬───────┘
       │                 │
       └────────┬────────┘
                ▼
       ┌─────────────────┐
       │ Create Purchase │
       │ Record          │
       └────────┬────────┘
                ▼
       ┌─────────────────┐
       │ Send            │
       │ Notifications   │
       └─────────────────┘
            │       │
       ┌────┘       └────┐
       ▼                 ▼
  ┌────────┐       ┌─────────┐
  │ Winner │       │ Seller  │
  └────────┘       └─────────┘
```

---

## Security & Race Condition Prevention

### 1. **Firestore Transactions**
- Atomic winner assignment
- Checks if winner already set before updating
- Returns false if already processed
- Prevents duplicate purchase records

### 2. **Idempotency**
- `processEndedAuction()` checks for existing winnerId
- Skips processing if winner already determined
- Safe to call multiple times

### 3. **Bid Prevention**
- Multiple validation layers
- Backend enforcement (not just frontend)
- Checks both status and timestamp

### 4. **Error Tolerance**
- Notification failures don't block processing
- Logged for debugging
- Core auction completion succeeds even if notifications fail

---

## Database Schema

### Artworks Collection
```javascript
{
  artworkId: String,
  saleType: "AUCTION",
  status: "ACTIVE" | "SOLD" | "INACTIVE",
  auctionEndTime: String (ISO LocalDateTime),
  currentBid: BigDecimal,
  startingBid: BigDecimal,
  highestBidderId: String,
  winnerId: String,           // Set when auction ends
  winnerName: String,         // Set when auction ends
  winningBidAmount: String,   // Set when auction ends
  endedAt: String,            // Timestamp when ended
  soldAt: String              // Timestamp when sold
}
```

### Bid History Collection
```javascript
{
  bidId: String,
  auctionId: String,
  bidderId: String,
  bidderName: String,
  bidAmount: Number,
  timestamp: Timestamp,
  previousBid: Number
}
```

### Purchases Collection
```javascript
{
  purchaseId: String,
  artworkId: String,
  buyerId: String,           // Winner ID
  sellerId: String,          // Artist ID
  purchasePrice: BigDecimal, // Winning bid
  status: "COMPLETED",
  paymentMethod: "AUCTION_WIN",
  transactionId: String,
  purchaseDate: LocalDateTime,
  notes: String
}
```

### Messages Collection (Notifications)
```javascript
{
  messageId: String,
  senderId: "SYSTEM",
  receiverId: String,        // Winner or Seller
  artworkId: String,
  content: String,
  messageType: "PURCHASE_NOTIFICATION",
  read: Boolean,
  timestamp: Date
}
```

---

## Monitoring & Logging

### Log Levels

**INFO:**
- Auction processing started
- Winner determined
- Purchase created
- Notifications sent successfully

**WARNING:**
- No bids found
- Auction already processed
- Missing auction end time

**SEVERE:**
- Processing errors
- Notification failures
- Transaction failures

### Key Log Messages
```
=== Starting processAllEndedAuctions ===
Found X active auctions to check
Processing ended auction: {artworkId} (ended at: {time})
Auction {artworkId} updated with winner information in transaction
✓ Purchase record created for auction win: {purchaseId}
✓✓✓ Auction winner notifications successfully sent for artwork: {artworkId}
=== Finished processing ended auctions. Processed: X ===
```

---

## Deployment Checklist

- [x] AuctionSchedulerListener created with @WebListener
- [x] AuctionProcessor.processAllEndedAuctions() implemented
- [x] AuctionProcessor.processEndedAuction() handles all cases
- [x] NotificationUtil sends winner and seller notifications
- [x] WebSocket timer calls processEndedAuction()
- [x] Bid servlets prevent bids on ended auctions
- [x] Transaction prevents race conditions
- [x] Error handling and logging in place
- [x] No manual "End Auction" button

---

## Testing Scenarios

### 1. **Normal Auction End (With Bids)**
- Create auction with short duration (5 minutes)
- Place multiple bids
- Wait for expiration
- Verify: Winner determined, purchase created, notifications sent

### 2. **No Bids Auction**
- Create auction
- Don't place any bids
- Let it expire
- Verify: Status set to INACTIVE, no purchase record

### 3. **Multiple Concurrent Auctions**
- Create 5 auctions ending at same time
- Place bids on all
- Verify: All processed correctly, no duplicates

### 4. **Late Bid Attempt**
- Let auction expire
- Try to place bid via API
- Verify: Rejected with "Auction has ended"

### 5. **Scheduler Catchup**
- Stop application
- Let auction expire while app is down
- Restart application
- Verify: Scheduler processes expired auction within 90 seconds

---

## Future Enhancements

### Possible Improvements:
1. **Email Notifications:** Send email in addition to in-app notifications
2. **Auction Extensions:** "Going once, going twice" - extend if bid in last minute
3. **Reserve Price:** Don't sell if reserve price not met
4. **Automatic Refunds:** Refund outbid users automatically
5. **Analytics Dashboard:** Track auction success rates
6. **Webhook Integration:** Notify external systems of auction results

---

## Troubleshooting

### Issue: Auction not ending automatically
**Check:**
1. Is AuctionSchedulerListener loading? (Check logs for "AuctionScheduler Initializing")
2. Is auctionEndTime properly formatted? (Must be ISO LocalDateTime)
3. Is auction status ACTIVE?
4. Check scheduler logs for errors

### Issue: Winner notifications not received
**Check:**
1. NotificationUtil logs for errors
2. Message collection in Firestore
3. receiverId matches actual user ID
4. Message type set correctly

### Issue: Multiple purchase records created
**Check:**
1. Transaction logs - should show "already has winner"
2. Firestore winnerId field
3. Check for duplicate processEndedAuction calls

---

## Summary

The automatic auction ending system provides a robust, scalable solution for managing auction lifecycles:

✅ **Automatic Processing:** No manual intervention required
✅ **Dual Detection:** WebSocket + Scheduler ensure no auction is missed  
✅ **Race Condition Safe:** Firestore transactions prevent duplicates
✅ **Notification System:** Both winners and sellers notified automatically
✅ **Bid Prevention:** Multiple layers stop late bids
✅ **Error Tolerant:** Continues working even if notifications fail
✅ **Observable:** Comprehensive logging for monitoring
✅ **Scalable:** Handles multiple concurrent auctions

The system is production-ready and requires no manual auction management from administrators.

