# PlaceBid Component Documentation

## Overview

The `PlaceBid` component is a reusable, accessible UI component for placing bids on auction artworks. It provides a consistent bidding experience across both the auction detail page and the browse artwork listings.

## Features

- ✅ Full bid panel for auction detail pages
- ✅ Compact bid controls for artwork listing cards
- ✅ Real-time bid updates via polling (10-second intervals)
- ✅ Comprehensive validation and error handling
- ✅ Accessible design with ARIA labels and keyboard navigation
- ✅ Responsive design (modal for mobile, inline for desktop)
- ✅ Conflict handling (409 status code for outbid scenarios)
- ✅ Automatic UI updates after successful bids

## Usage

### Basic Usage (Full Panel)

```javascript
const placeBid = new PlaceBid({
  auctionId: 'abc123',
  startingPrice: 100.00,
  currentHighestBid: 150.00,
  minIncrement: 10.00,
  auctionStatus: 'ACTIVE',
  endsAt: '2024-12-31T23:59:59',
  container: document.getElementById('bid-container'),
  compact: false,
  onSuccess: (bidData) => {
    console.log('Bid placed:', bidData);
  },
  onError: (error) => {
    console.error('Bid error:', error);
  }
});
```

### Compact Usage (Listing Cards)

```javascript
const placeBid = new PlaceBid({
  auctionId: 'abc123',
  startingPrice: 100.00,
  currentHighestBid: null,
  minIncrement: 10.00,
  auctionStatus: 'ACTIVE',
  endsAt: '2024-12-31T23:59:59',
  container: document.getElementById('bidControl-abc123'),
  compact: true,
  onSuccess: (bidData) => {
    // Update card display
    updateCardBidDisplay(bidData.bidAmount);
  }
});
```

## Props

| Prop | Type | Required | Default | Description |
|------|------|----------|---------|-------------|
| `auctionId` | string | Yes | - | Auction/artwork ID |
| `startingPrice` | number | Yes | - | Starting bid price |
| `currentHighestBid` | number\|null | No | null | Current highest bid (null if no bids) |
| `minIncrement` | number | No | 10.00 | Minimum bid increment |
| `auctionStatus` | string | Yes | - | 'ACTIVE', 'ENDED', or 'CANCELED' |
| `endsAt` | string | No | null | ISO date string for auction end time |
| `container` | HTMLElement | Yes | - | Container element for the component |
| `compact` | boolean | No | false | Use compact UI for listing cards |
| `onSuccess` | function | No | () => {} | Callback when bid is placed successfully |
| `onError` | function | No | () => {} | Callback when bid fails |
| `onUpdate` | function | No | () => {} | Callback when auction data is refreshed |

## Callback Functions

### onSuccess(bidData)

Called when a bid is successfully placed.

**Parameters:**
- `bidData.bidAmount` (number) - The bid amount that was placed
- `bidData.auctionId` (string) - The auction ID
- `bidData.newHighestBid` (number) - The new highest bid

**Example:**
```javascript
onSuccess: (bidData) => {
  console.log(`Bid of RM ${bidData.bidAmount} placed successfully`);
  // Refresh bid history, update UI, etc.
}
```

### onError(error)

Called when a bid fails.

**Parameters:**
- `error` (Error) - Error object with message

**Example:**
```javascript
onError: (error) => {
  console.error('Bid failed:', error.message);
  // Show error notification, etc.
}
```

### onUpdate(updateData)

Called when auction data is refreshed (via polling or manual refresh).

**Parameters:**
- `updateData.currentHighestBid` (number\|null) - Updated current highest bid
- `updateData.auctionStatus` (string) - Updated auction status
- `updateData.minNextBid` (number) - Updated minimum next bid

**Example:**
```javascript
onUpdate: (updateData) => {
  console.log('Auction updated:', updateData);
  // Update displayed bid amounts, etc.
}
```

## API Endpoints

The component uses the following API endpoints:

### Place Bid
- **Primary:** `POST /api/auctions/{auctionId}/bid`
- **Fallback:** `POST /api/artworks/{artworkId}/bid`

**Request Body:**
```json
{
  "amount": 150.00
}
```

**Success Response (200/201):**
```json
{
  "success": true,
  "message": "Bid placed successfully",
  "bidAmount": 150.00,
  "auctionId": "abc123",
  "userId": "user123"
}
```

**Error Responses:**
- `401` - Unauthorized (user not logged in)
- `409` - Conflict (someone placed a higher bid)
- `422` - Validation error (invalid bid amount)
- `500` - Server error

### Get Auction Data
- **Primary:** `GET /api/auctions/{auctionId}`
- **Fallback:** `GET /api/artworks/{artworkId}`

**Response:**
```json
{
  "success": true,
  "auction": {
    "id": "abc123",
    "currentBid": 150.00,
    "startingBid": 100.00,
    "status": "ACTIVE",
    "endTime": "2024-12-31T23:59:59",
    "minIncrement": 10.00
  }
}
```

## Validation

The component enforces the following validations:

1. **Minimum Bid:** Bid must be at least `currentHighestBid + minIncrement` (or `startingPrice` if no bids)
2. **Auction Status:** Bids can only be placed when `auctionStatus === 'ACTIVE'`
3. **User Authentication:** User must be logged in to place bids
4. **Numeric Format:** Bid amount must be a valid number with 2 decimal places

## Real-time Updates

The component automatically polls for auction updates every 10 seconds when:
- The component is in full panel mode (not compact)
- The component is expanded/visible

To manually refresh auction data:
```javascript
placeBid.refreshAuctionData();
```

To start/stop polling:
```javascript
placeBid.startPolling();
placeBid.stopPolling();
```

## WebSocket Integration (Optional)

If your application uses WebSockets for real-time updates, you can integrate them by:

1. Subscribing to auction updates in the `onUpdate` callback
2. Calling `refreshAuctionData()` when WebSocket messages are received

**Example:**
```javascript
// In your WebSocket handler
websocket.on('auction:update', (data) => {
  if (data.auctionId === placeBid.auctionId) {
    placeBid.refreshAuctionData();
  }
});
```

## Accessibility

The component includes:

- ✅ Proper ARIA labels and roles
- ✅ Keyboard navigation support
- ✅ Focus management (modal returns focus to trigger button)
- ✅ Screen reader announcements for errors
- ✅ `aria-live` regions for dynamic content

## Styling

The component uses Bootstrap 5 classes and custom CSS. Key classes:

- `.place-bid-panel` - Full bid panel container
- `.place-bid-compact` - Compact bid control container
- `.bid-updated` - Animation class for bid updates
- `.fade-in` - Animation class for messages

Custom styles are defined in `assets/css/main.css`.

## Responsive Behavior

- **Desktop:** Full panel displays inline; compact view shows button that opens modal
- **Mobile:** Both full and compact views use modal for better UX

## Cleanup

To properly destroy a component instance:

```javascript
placeBid.destroy();
```

This will:
- Stop polling
- Remove modal elements
- Clean up event listeners

## Integration Examples

### Artwork Detail Page

```javascript
// In artwork-detail.jsp
async function initializePlaceBidComponent() {
  const response = await fetch(`/api/artworks/${artworkId}`, {
    credentials: 'include'
  });
  const data = await response.json();
  const artwork = data.artwork || data;
  
  const placeBid = new PlaceBid({
    auctionId: artworkId,
    startingPrice: artwork.startingBid || 0,
    currentHighestBid: artwork.currentBid || null,
    minIncrement: artwork.minIncrement || 10.00,
    auctionStatus: artwork.status || 'ACTIVE',
    endsAt: artwork.auctionEndTime || null,
    container: document.getElementById('placeBidContainer'),
    compact: false,
    onSuccess: (bidData) => {
      loadBidHistory(); // Refresh bid history
    }
  });
}
```

### Browse Listing Cards

```javascript
// In browse.jsp
function initializePlaceBidComponents(artworks) {
  artworks.forEach(artwork => {
    if (artwork.saleType === 'AUCTION') {
      const container = document.getElementById(`bidControl-${artwork.artworkId}`);
      if (container) {
        new PlaceBid({
          auctionId: artwork.artworkId,
          startingPrice: artwork.startingBid || 0,
          currentHighestBid: artwork.currentBid || null,
          minIncrement: artwork.minIncrement || 10.00,
          auctionStatus: determineAuctionStatus(artwork),
          endsAt: artwork.auctionEndTime || null,
          container: container,
          compact: true,
          onSuccess: (bidData) => {
            updateCardBidDisplay(artwork.artworkId, bidData.bidAmount);
          }
        });
      }
    }
  });
}
```

## Testing

### Unit Tests

Test minimum bid calculation:
```javascript
const placeBid = new PlaceBid({
  auctionId: 'test',
  startingPrice: 100,
  currentHighestBid: 150,
  minIncrement: 10,
  auctionStatus: 'ACTIVE',
  container: document.createElement('div'),
  compact: false
});

// Should calculate minNextBid as 160 (150 + 10)
assert(placeBid.minNextBid === 160);
```

### Integration Tests

Test conflict handling:
```javascript
// Simulate race condition
const placeBid = new PlaceBid({...});

// Mock API to return 409 on second call
let callCount = 0;
fetch = jest.fn((url) => {
  callCount++;
  if (callCount === 1) {
    return Promise.resolve({ ok: true, json: () => ({ success: true }) });
  }
  return Promise.resolve({
    status: 409,
    json: () => ({ success: false, message: 'Outbid' })
  });
});

// Place bid
await placeBid.handleSubmit();

// Should show conflict message and refresh data
expect(placeBid.currentHighestBid).toBeGreaterThan(originalBid);
```

## Browser Support

- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Dependencies

- Bootstrap 5.3.0+
- Font Awesome 6.0+
- Modern browser with ES6+ support

## License

Part of the ArtXchange project.

