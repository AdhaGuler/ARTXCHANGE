/**
 * PlaceBid Component - Reusable bid placement UI
 * 
 * Usage:
 *   const placeBid = new PlaceBid({
 *     auctionId: 'abc123',
 *     startingPrice: 100.00,
 *     currentHighestBid: 150.00,
 *     minIncrement: 10.00,
 *     auctionStatus: 'ACTIVE',
 *     endsAt: '2024-12-31T23:59:59',
 *     container: document.getElementById('bid-container'),
 *     compact: false,
 *     onSuccess: (bidData) => { console.log('Bid placed:', bidData); },
 *     onError: (error) => { console.error('Bid error:', error); }
 *   });
 * 
 * Props:
 *   - auctionId: string (required) - Auction/artwork ID
 *   - startingPrice: number (required) - Starting bid price
 *   - currentHighestBid: number|null - Current highest bid (null if no bids)
 *   - minIncrement: number (default: 10.00) - Minimum bid increment
 *   - auctionStatus: string (required) - 'ACTIVE', 'ENDED', 'CANCELED'
 *   - endsAt: string (optional) - ISO date string for auction end time
 *   - container: HTMLElement (required) - Container element for the component
 *   - compact: boolean (default: false) - Use compact UI for listing cards
 *   - onSuccess: function - Callback when bid is placed successfully
 *   - onError: function - Callback when bid fails
 *   - onUpdate: function - Callback when auction data is refreshed
 */

class PlaceBid {
  constructor(options) {
    this.auctionId = options.auctionId;
    this.startingPrice = parseFloat(options.startingPrice) || 0;
    this.currentHighestBid = options.currentHighestBid !== null && options.currentHighestBid !== undefined 
      ? parseFloat(options.currentHighestBid) : null;
    this.minIncrement = parseFloat(options.minIncrement) || 10.00;
    this.auctionStatus = options.auctionStatus || 'ACTIVE';
    this.endsAt = options.endsAt || null;
    this.artistId = options.artistId || null; // Owner/artist ID to prevent self-bidding
    this.container = options.container;
    this.compact = options.compact || false;
    this.onSuccess = options.onSuccess || (() => {});
    this.onError = options.onError || (() => {});
    this.onUpdate = options.onUpdate || (() => {});
    
    // Internal state
    this.bidAmount = null;
    this.isSubmitting = false;
    this.pollInterval = null;
    this.modal = null;
    this.originalTriggerButton = null;
    
    // Calculate minimum next bid
    this.minNextBid = this.calculateMinNextBid();
    
    // Initialize component
    this.render();
    
    // Start polling if component is active
    if (!this.compact || this.isExpanded) {
      this.startPolling();
    }
  }
  
  /**
   * Calculate minimum next bid
   */
  calculateMinNextBid() {
    if (this.currentHighestBid !== null) {
      return this.currentHighestBid + this.minIncrement;
    }
    return this.startingPrice;
  }
  
  /**
   * Render the component
   */
  render() {
    if (this.compact) {
      this.renderCompact();
    } else {
      this.renderFull();
    }
  }
  
  /**
   * Render full bid panel (for auction detail page)
   */
  renderFull() {
    const isActive = this.auctionStatus === 'ACTIVE';
    const isEnded = this.auctionStatus === 'ENDED' || this.auctionStatus === 'CANCELED';
    
    this.container.innerHTML = `
      <div class="place-bid-panel" role="region" aria-label="Place Bid">
        <!-- Current Bid Display -->
        <div class="mb-3">
          <div class="d-flex justify-content-between align-items-center mb-2">
            <span class="text-muted">Current Highest Bid:</span>
            <strong class="text-primary fs-5" id="currentBidDisplay-${this.auctionId}">
              RM ${this.formatCurrency(this.currentHighestBid || this.startingPrice)}
            </strong>
          </div>
          <div class="d-flex justify-content-between align-items-center">
            <span class="text-muted">Minimum Next Bid:</span>
            <strong class="text-success" id="minBidDisplay-${this.auctionId}">
              RM ${this.formatCurrency(this.minNextBid)}
            </strong>
          </div>
        </div>
        
        <!-- Countdown Timer -->
        ${this.endsAt ? `
          <div class="mb-3">
            <small class="text-muted">
              <i class="fas fa-clock me-1"></i>
              <span id="countdown-${this.auctionId}">Calculating...</span>
            </small>
          </div>
        ` : ''}
        
        <!-- Bid Input Form -->
        <form id="bidForm-${this.auctionId}" class="mb-3" onsubmit="return false;">
          <div class="mb-3">
            <label for="bidAmount-${this.auctionId}" class="form-label">
              Your Bid Amount (RM)
            </label>
            <div class="input-group">
              <span class="input-group-text">RM</span>
              <input 
                type="number" 
                class="form-control" 
                id="bidAmount-${this.auctionId}"
                step="0.01"
                min="${this.minNextBid}"
                value="${this.minNextBid.toFixed(2)}"
                ${!isActive ? 'disabled' : ''}
                aria-describedby="bidHelp-${this.auctionId} bidError-${this.auctionId}"
                aria-required="true"
                aria-invalid="false"
              >
            </div>
            <div id="bidHelp-${this.auctionId}" class="form-text">
              Minimum bid: RM ${this.formatCurrency(this.minNextBid)}
            </div>
            <div 
              id="bidError-${this.auctionId}" 
              class="invalid-feedback" 
              role="alert" 
              aria-live="assertive"
              style="display: none;"
            ></div>
          </div>
          
          <!-- Status Messages -->
          ${isEnded ? `
            <div class="alert alert-warning" role="alert">
              <i class="fas fa-exclamation-triangle me-2"></i>
              Auction ${this.auctionStatus === 'ENDED' ? 'ended' : 'canceled'} — bidding is closed.
            </div>
          ` : ''}
          
          <!-- Submit Button -->
          <button 
            type="submit" 
            class="btn btn-primary w-100" 
            id="placeBidBtn-${this.auctionId}"
            ${!isActive || this.isSubmitting ? 'disabled' : ''}
            aria-label="Place bid"
          >
            ${this.isSubmitting ? `
              <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
              Placing Bid...
            ` : `
              <i class="fas fa-gavel me-2"></i>Place Bid
            `}
          </button>
        </form>
        
        <!-- Success/Error Messages -->
        <div id="bidMessage-${this.auctionId}" role="alert" aria-live="polite" style="display: none;"></div>
      </div>
    `;
    
    // Attach event listeners
    this.attachEventListeners();
    
    // Initialize countdown timer if needed
    if (this.endsAt) {
      this.initializeCountdown();
    }
  }
  
  /**
   * Render compact bid control (for listing cards)
   */
  renderCompact() {
    const isActive = this.auctionStatus === 'ACTIVE';
    const currentBid = this.currentHighestBid || this.startingPrice;
    
    this.container.innerHTML = `
      <div class="place-bid-compact" role="region" aria-label="Bid Control">
        <div class="d-flex justify-content-between align-items-center mb-2">
          <small class="text-muted">Current Bid:</small>
          <strong class="text-primary" id="compactCurrentBid-${this.auctionId}">
            RM ${this.formatCurrency(currentBid)}
          </strong>
        </div>
        <button 
          class="btn btn-sm btn-primary w-100" 
          id="compactBidBtn-${this.auctionId}"
          ${!isActive ? 'disabled' : ''}
          aria-label="Place bid on this auction"
          data-bs-toggle="modal"
          data-bs-target="#bidModal-${this.auctionId}"
        >
          <i class="fas fa-gavel me-1"></i>Place Bid
        </button>
      </div>
    `;
    
    // Create modal for compact view
    this.createCompactModal();
    
    // Attach event listeners
    this.attachCompactEventListeners();
  }
  
  /**
   * Create modal for compact bid flow
   */
  createCompactModal() {
    // Remove existing modal if any
    const existingModal = document.getElementById(`bidModal-${this.auctionId}`);
    if (existingModal) {
      existingModal.remove();
    }
    
    const modalHTML = `
      <div class="modal fade" id="bidModal-${this.auctionId}" tabindex="-1" aria-labelledby="bidModalLabel-${this.auctionId}" aria-hidden="true">
        <div class="modal-dialog modal-dialog-centered">
          <div class="modal-content">
            <div class="modal-header">
              <h5 class="modal-title" id="bidModalLabel-${this.auctionId}">
                <i class="fas fa-gavel me-2"></i>Place Bid
              </h5>
              <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
              <div class="mb-3">
                <div class="d-flex justify-content-between align-items-center mb-2">
                  <span class="text-muted">Current Highest Bid:</span>
                  <strong class="text-primary" id="modalCurrentBid-${this.auctionId}">
                    RM ${this.formatCurrency(this.currentHighestBid || this.startingPrice)}
                  </strong>
                </div>
                <div class="d-flex justify-content-between align-items-center">
                  <span class="text-muted">Minimum Next Bid:</span>
                  <strong class="text-success" id="modalMinBid-${this.auctionId}">
                    RM ${this.formatCurrency(this.minNextBid)}
                  </strong>
                </div>
              </div>
              
              ${this.endsAt ? `
                <div class="mb-3">
                  <small class="text-muted">
                    <i class="fas fa-clock me-1"></i>
                    <span id="modalCountdown-${this.auctionId}">Calculating...</span>
                  </small>
                </div>
              ` : ''}
              
              <form id="modalBidForm-${this.auctionId}" onsubmit="return false;">
                <div class="mb-3">
                  <label for="modalBidAmount-${this.auctionId}" class="form-label">
                    Your Bid Amount (RM)
                  </label>
                  <div class="input-group">
                    <span class="input-group-text">RM</span>
                    <input 
                      type="number" 
                      class="form-control" 
                      id="modalBidAmount-${this.auctionId}"
                      step="0.01"
                      min="${this.minNextBid}"
                      value="${this.minNextBid.toFixed(2)}"
                      ${this.auctionStatus !== 'ACTIVE' ? 'disabled' : ''}
                      aria-describedby="modalBidHelp-${this.auctionId} modalBidError-${this.auctionId}"
                      aria-required="true"
                      aria-invalid="false"
                    >
                  </div>
                  <div id="modalBidHelp-${this.auctionId}" class="form-text">
                    Minimum bid: RM ${this.formatCurrency(this.minNextBid)}
                  </div>
                  <div 
                    id="modalBidError-${this.auctionId}" 
                    class="invalid-feedback" 
                    role="alert" 
                    aria-live="assertive"
                    style="display: none;"
                  ></div>
                </div>
                
                ${this.auctionStatus !== 'ACTIVE' ? `
                  <div class="alert alert-warning" role="alert">
                    <i class="fas fa-exclamation-triangle me-2"></i>
                    Auction ${this.auctionStatus === 'ENDED' ? 'ended' : 'canceled'} — bidding is closed.
                  </div>
                ` : ''}
                
                <div id="modalBidMessage-${this.auctionId}" role="alert" aria-live="polite" style="display: none;"></div>
                
                <div class="d-grid gap-2">
                  <button 
                    type="submit" 
                    class="btn btn-primary" 
                    id="modalPlaceBidBtn-${this.auctionId}"
                    ${this.auctionStatus !== 'ACTIVE' || this.isSubmitting ? 'disabled' : ''}
                  >
                    ${this.isSubmitting ? `
                      <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
                      Placing Bid...
                    ` : `
                      <i class="fas fa-gavel me-2"></i>Place Bid
                    `}
                  </button>
                  <button 
                    type="button" 
                    class="btn btn-secondary" 
                    data-bs-dismiss="modal"
                  >
                    Cancel
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    `;
    
    document.body.insertAdjacentHTML('beforeend', modalHTML);
    
    // Initialize modal
    this.modal = new bootstrap.Modal(document.getElementById(`bidModal-${this.auctionId}`));
    
    // Attach modal event listeners
    this.attachModalEventListeners();
    
    // Initialize countdown in modal if needed
    if (this.endsAt) {
      this.initializeModalCountdown();
    }
  }
  
  /**
   * Attach event listeners for full view
   */
  attachEventListeners() {
    const form = document.getElementById(`bidForm-${this.auctionId}`);
    const input = document.getElementById(`bidAmount-${this.auctionId}`);
    const submitBtn = document.getElementById(`placeBidBtn-${this.auctionId}`);
    
    if (form) {
      form.addEventListener('submit', (e) => {
        e.preventDefault();
        this.handleSubmit();
      });
    }
    
    if (input) {
      input.addEventListener('input', () => {
        this.validateInput(input);
      });
      
      input.addEventListener('blur', () => {
        this.formatInput(input);
      });
    }
  }
  
  /**
   * Attach event listeners for compact view
   */
  attachCompactEventListeners() {
    const btn = document.getElementById(`compactBidBtn-${this.auctionId}`);
    if (btn) {
      this.originalTriggerButton = btn;
      btn.addEventListener('click', (e) => {
        e.stopPropagation(); // Prevent card click
        // Modal will open via data-bs-toggle
        this.refreshAuctionData();
      });
    }
  }
  
  /**
   * Attach event listeners for modal
   */
  attachModalEventListeners() {
    const form = document.getElementById(`modalBidForm-${this.auctionId}`);
    const input = document.getElementById(`modalBidAmount-${this.auctionId}`);
    const modalElement = document.getElementById(`bidModal-${this.auctionId}`);
    
    // Check ownership when modal opens (optional - backend will also validate)
    if (modalElement) {
      modalElement.addEventListener('show.bs.modal', () => {
        // Clear any previous errors
        const errorDiv = document.getElementById(`modalBidError-${this.auctionId}`);
        if (errorDiv) {
          errorDiv.style.display = 'none';
          errorDiv.textContent = '';
          errorDiv.classList.remove('d-block');
        }
        
        // Get currentUserId for owner check (optional)
        let currentUserId = null;
        if (typeof currentUser !== 'undefined' && currentUser) {
          currentUserId = currentUser.userId || currentUser.id || null;
        }
        
        // Check if user is the owner (frontend check - backend will also validate)
        if (this.artistId && currentUserId && currentUserId === this.artistId) {
          // Disable form and show message
          if (form) form.style.display = 'none';
          if (errorDiv) {
            errorDiv.textContent = 'You cannot bid on your own artwork.';
            errorDiv.style.display = 'block';
            errorDiv.classList.add('d-block');
          }
        } else {
          // Enable form - let backend handle authentication
          if (form) form.style.display = '';
          if (errorDiv) {
            errorDiv.style.display = 'none';
            errorDiv.textContent = '';
          }
          if (form) {
            const submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn && this.auctionStatus === 'ACTIVE') submitBtn.disabled = false;
          }
        }
      });
    }
    
    if (form) {
      form.addEventListener('submit', (e) => {
        e.preventDefault();
        this.handleSubmit(true);
      });
    }
    
    if (input) {
      input.addEventListener('input', () => {
        this.validateInput(input, true);
      });
      
      input.addEventListener('blur', () => {
        this.formatInput(input, true);
      });
    }
    
    // Handle modal close - return focus to trigger button
    if (modalElement) {
      modalElement.addEventListener('hidden.bs.modal', () => {
        if (this.originalTriggerButton) {
          this.originalTriggerButton.focus();
        }
      });
    }
  }
  
  /**
   * Validate bid input
   */
  validateInput(input, isModal = false) {
    const value = parseFloat(input.value);
    const errorElement = document.getElementById(
      isModal ? `modalBidError-${this.auctionId}` : `bidError-${this.auctionId}`
    );
    const submitBtn = document.getElementById(
      isModal ? `modalPlaceBidBtn-${this.auctionId}` : `placeBidBtn-${this.auctionId}`
    );
    
    if (isNaN(value) || value < this.minNextBid) {
      input.setAttribute('aria-invalid', 'true');
      input.classList.add('is-invalid');
      if (errorElement) {
        errorElement.textContent = `Your bid must be at least RM ${this.formatCurrency(this.minNextBid)}`;
        errorElement.style.display = 'block';
      }
      if (submitBtn) {
        submitBtn.disabled = true;
      }
      return false;
    } else {
      input.setAttribute('aria-invalid', 'false');
      input.classList.remove('is-invalid');
      if (errorElement) {
        errorElement.style.display = 'none';
      }
      if (submitBtn && this.auctionStatus === 'ACTIVE' && !this.isSubmitting) {
        submitBtn.disabled = false;
      }
      return true;
    }
  }
  
  /**
   * Format input value to 2 decimal places
   */
  formatInput(input, isModal = false) {
    const value = parseFloat(input.value);
    if (!isNaN(value)) {
      input.value = value.toFixed(2);
      this.validateInput(input, isModal);
    }
  }
  
  /**
   * Handle form submission
   */
  async handleSubmit(isModal = false) {
    // Get userId for owner check (optional - backend will also validate)
    let currentUserId = null;
    if (typeof currentUser !== 'undefined' && currentUser) {
      currentUserId = currentUser.userId || currentUser.id || null;
    }
    
    // Frontend owner check (optional - backend will also validate)
    if (this.artistId && currentUserId && currentUserId === this.artistId) {
      this.showError('You cannot bid on your own artwork.', isModal);
      return;
    }
    
    // Note: We don't check authentication here - let the backend handle it
    // If user is not authenticated, backend will return 401 and we'll handle it below
    
    const input = document.getElementById(
      isModal ? `modalBidAmount-${this.auctionId}` : `bidAmount-${this.auctionId}`
    );
    
    if (!input) {
      console.error('PlaceBid: Input element not found', {
        isModal,
        modalId: `modalBidAmount-${this.auctionId}`,
        normalId: `bidAmount-${this.auctionId}`
      });
      this.showError('Bid input field not found. Please refresh the page.', isModal);
      return;
    }
    
    if (!this.validateInput(input, isModal)) {
      return;
    }
    
    const bidAmount = parseFloat(input.value);
    
    // Validate bid amount
    if (isNaN(bidAmount) || bidAmount <= 0) {
      this.showError('Please enter a valid bid amount.', isModal);
      return;
    }
    
    if (bidAmount < this.minNextBid) {
      this.showError(`Your bid must be at least RM ${this.formatCurrency(this.minNextBid)}.`, isModal);
      return;
    }
    
    // Check auction status
    if (this.auctionStatus !== 'ACTIVE') {
      this.showError(
        `Auction ${this.auctionStatus === 'ENDED' ? 'ended' : 'canceled'} — bidding is closed.`,
        isModal
      );
      return;
    }
    
    this.isSubmitting = true;
    this.updateSubmitButton(true, isModal);
    
    try {
      // Try /api/auctions/{auctionId}/bid first, fallback to /api/artworks/{artworkId}/bid
      let response;
      try {
        response = await fetch(`/api/auctions/${this.auctionId}/bid`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          credentials: 'include',
          body: JSON.stringify({ amount: bidAmount })
        });
      } catch (e) {
        // Fallback to artwork endpoint
        response = await fetch(`/api/artworks/${this.auctionId}/bid`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          credentials: 'include',
          body: JSON.stringify({ amount: bidAmount })
        });
      }
      
      const data = await response.json();
      
      if (response.ok && (response.status === 200 || response.status === 201)) {
        // Success
        this.showSuccess('Bid placed successfully!', isModal);
        this.currentHighestBid = bidAmount;
        this.minNextBid = this.calculateMinNextBid();
        this.updateUI();
        
        // Call success callback
        this.onSuccess({
          bidAmount,
          auctionId: this.auctionId,
          newHighestBid: bidAmount
        });
        
        // Refresh auction data
        await this.refreshAuctionData();
        
        // Close modal if in compact view
        if (isModal && this.modal) {
          setTimeout(() => {
            this.modal.hide();
          }, 1500);
        }
      } else if (response.status === 409) {
        // Conflict - someone else placed a higher bid
        await this.refreshAuctionData();
        this.showError(
          `Someone placed a higher bid just now. Minimum next bid is RM ${this.formatCurrency(this.minNextBid)}.`,
          isModal
        );
        this.onError(new Error('Bid conflict - outbid'));
      } else if (response.status === 422) {
        // Validation error
        this.showError(data.message || data.error || 'Invalid bid amount.', isModal);
        this.onError(new Error(data.message || 'Validation error'));
      } else if (response.status === 401) {
        // Unauthorized
        this.showError('You must sign in to place a bid.', isModal);
        if (typeof showLoginModal === 'function') {
          showLoginModal();
        }
        this.onError(new Error('Unauthorized'));
      } else {
        // Other error
        this.showError(
          data.message || data.error || 'Unable to place bid. Try again.',
          isModal
        );
        this.onError(new Error(data.message || 'Unknown error'));
      }
    } catch (error) {
      console.error('Error placing bid:', error);
      this.showError('Unable to place bid. Try again.', isModal);
      this.onError(error);
    } finally {
      this.isSubmitting = false;
      this.updateSubmitButton(false, isModal);
    }
  }
  
  /**
   * Update submit button state
   */
  updateSubmitButton(isSubmitting, isModal = false) {
    const btn = document.getElementById(
      isModal ? `modalPlaceBidBtn-${this.auctionId}` : `placeBidBtn-${this.auctionId}`
    );
    if (btn) {
      btn.disabled = isSubmitting || this.auctionStatus !== 'ACTIVE';
      if (isSubmitting) {
        btn.innerHTML = `
          <span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>
          Placing Bid...
        `;
      } else {
        btn.innerHTML = `
          <i class="fas fa-gavel me-2"></i>Place Bid
        `;
      }
    }
  }
  
  /**
   * Show success message
   */
  showSuccess(message, isModal = false) {
    const messageEl = document.getElementById(
      isModal ? `modalBidMessage-${this.auctionId}` : `bidMessage-${this.auctionId}`
    );
    if (messageEl) {
      messageEl.className = 'alert alert-success';
      messageEl.textContent = message;
      messageEl.style.display = 'block';
      
      // Add animation
      messageEl.classList.add('fade-in');
      
      // Auto-hide after 3 seconds
      setTimeout(() => {
        messageEl.style.display = 'none';
      }, 3000);
    }
  }
  
  /**
   * Show error message
   */
  showError(message, isModal = false) {
    const messageEl = document.getElementById(
      isModal ? `modalBidMessage-${this.auctionId}` : `bidMessage-${this.auctionId}`
    );
    if (messageEl) {
      messageEl.className = 'alert alert-danger';
      messageEl.textContent = message;
      messageEl.style.display = 'block';
    }
  }
  
  /**
   * Update UI with new bid data
   */
  updateUI() {
    // Update current bid display
    const currentBidEl = document.getElementById(`currentBidDisplay-${this.auctionId}`);
    if (currentBidEl) {
      currentBidEl.textContent = `RM ${this.formatCurrency(this.currentHighestBid || this.startingPrice)}`;
      // Add highlight animation
      currentBidEl.classList.add('bid-updated');
      setTimeout(() => {
        currentBidEl.classList.remove('bid-updated');
      }, 1000);
    }
    
    // Update compact current bid
    const compactBidEl = document.getElementById(`compactCurrentBid-${this.auctionId}`);
    if (compactBidEl) {
      compactBidEl.textContent = `RM ${this.formatCurrency(this.currentHighestBid || this.startingPrice)}`;
    }
    
    // Update modal current bid
    const modalBidEl = document.getElementById(`modalCurrentBid-${this.auctionId}`);
    if (modalBidEl) {
      modalBidEl.textContent = `RM ${this.formatCurrency(this.currentHighestBid || this.startingPrice)}`;
    }
    
    // Update minimum bid displays
    const minBidEl = document.getElementById(`minBidDisplay-${this.auctionId}`);
    if (minBidEl) {
      minBidEl.textContent = `RM ${this.formatCurrency(this.minNextBid)}`;
    }
    
    const modalMinBidEl = document.getElementById(`modalMinBid-${this.auctionId}`);
    if (modalMinBidEl) {
      modalMinBidEl.textContent = `RM ${this.formatCurrency(this.minNextBid)}`;
    }
    
    // Update input min values
    const input = document.getElementById(`bidAmount-${this.auctionId}`);
    if (input) {
      input.min = this.minNextBid;
      if (parseFloat(input.value) < this.minNextBid) {
        input.value = this.minNextBid.toFixed(2);
      }
      this.validateInput(input, false);
    }
    
    const modalInput = document.getElementById(`modalBidAmount-${this.auctionId}`);
    if (modalInput) {
      modalInput.min = this.minNextBid;
      if (parseFloat(modalInput.value) < this.minNextBid) {
        modalInput.value = this.minNextBid.toFixed(2);
      }
      this.validateInput(modalInput, true);
    }
  }
  
  /**
   * Refresh auction data from API
   */
  async refreshAuctionData() {
    try {
      // Try auctions endpoint first
      let response;
      try {
        response = await fetch(`/api/auctions/${this.auctionId}`, {
          credentials: 'include'
        });
      } catch (e) {
        // Fallback to artwork endpoint
        response = await fetch(`/api/artworks/${this.auctionId}`, {
          credentials: 'include'
        });
      }
      
      if (response.ok) {
        const data = await response.json();
        const auction = data.auction || data.artwork || data;
        
        if (auction) {
          // Update internal state
          this.currentHighestBid = auction.currentBid || auction.currentHighestBid || null;
          this.auctionStatus = auction.status || auction.auctionStatus || this.auctionStatus;
          this.endsAt = auction.endTime || auction.endsAt || auction.auctionEndTime || this.endsAt;
          
          // Update minIncrement if provided
          if (auction.minIncrement !== undefined && auction.minIncrement !== null) {
            this.minIncrement = parseFloat(auction.minIncrement);
          }
          
          // Recalculate min next bid
          this.minNextBid = this.calculateMinNextBid();
          
          // Update UI
          this.updateUI();
          
          // Call update callback
          this.onUpdate({
            currentHighestBid: this.currentHighestBid,
            auctionStatus: this.auctionStatus,
            minNextBid: this.minNextBid
          });
        }
      }
    } catch (error) {
      console.error('Error refreshing auction data:', error);
    }
  }
  
  /**
   * Start polling for auction updates
   */
  startPolling() {
    // Clear existing interval
    this.stopPolling();
    
    // Poll every 10 seconds
    this.pollInterval = setInterval(() => {
      this.refreshAuctionData();
    }, 10000);
  }
  
  /**
   * Stop polling
   */
  stopPolling() {
    if (this.pollInterval) {
      clearInterval(this.pollInterval);
      this.pollInterval = null;
    }
  }
  
  /**
   * Initialize countdown timer
   */
  initializeCountdown() {
    if (!this.endsAt) return;
    
    const timerEl = document.getElementById(`countdown-${this.auctionId}`);
    if (!timerEl) return;
    
    const updateTimer = () => {
      const now = new Date();
      const endDate = new Date(this.endsAt);
      const timeLeft = endDate - now;
      
      if (timeLeft <= 0) {
        timerEl.textContent = 'Auction ended';
        timerEl.classList.add('text-danger');
        this.auctionStatus = 'ENDED';
        this.updateUI();
        this.stopPolling();
        return;
      }
      
      const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
      const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);
      
      if (days > 0) {
        timerEl.textContent = `${days}d ${hours}h ${minutes}m`;
      } else if (hours > 0) {
        timerEl.textContent = `${hours}h ${minutes}m ${seconds}s`;
      } else {
        timerEl.textContent = `${minutes}m ${seconds}s`;
      }
    };
    
    updateTimer();
    setInterval(updateTimer, 1000);
  }
  
  /**
   * Initialize countdown timer in modal
   */
  initializeModalCountdown() {
    if (!this.endsAt) return;
    
    const timerEl = document.getElementById(`modalCountdown-${this.auctionId}`);
    if (!timerEl) return;
    
    const updateTimer = () => {
      const now = new Date();
      const endDate = new Date(this.endsAt);
      const timeLeft = endDate - now;
      
      if (timeLeft <= 0) {
        timerEl.textContent = 'Auction ended';
        timerEl.classList.add('text-danger');
        return;
      }
      
      const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
      const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
      const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
      const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);
      
      if (days > 0) {
        timerEl.textContent = `${days}d ${hours}h ${minutes}m`;
      } else if (hours > 0) {
        timerEl.textContent = `${hours}h ${minutes}m ${seconds}s`;
      } else {
        timerEl.textContent = `${minutes}m ${seconds}s`;
      }
    };
    
    updateTimer();
    setInterval(updateTimer, 1000);
  }
  
  /**
   * Format currency
   */
  formatCurrency(amount) {
    if (amount === null || amount === undefined) return '0.00';
    return parseFloat(amount).toFixed(2);
  }
  
  /**
   * Destroy component and cleanup
   */
  destroy() {
    this.stopPolling();
    if (this.modal) {
      this.modal.dispose();
    }
    const modalEl = document.getElementById(`bidModal-${this.auctionId}`);
    if (modalEl) {
      modalEl.remove();
    }
  }
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
  module.exports = PlaceBid;
}

