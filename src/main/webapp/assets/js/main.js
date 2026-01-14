// Main JavaScript functionality for ArtXchange

// Initialize when DOM is loaded
document.addEventListener('DOMContentLoaded', function() {
    initializeApp();
    loadFeaturedArtworks();
});

// Initialize the application
function initializeApp() {
    console.log('ArtXchange platform initialized');
    
    // Initialize tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    const tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
    
    // Initialize popovers
    const popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'));
    const popoverList = popoverTriggerList.map(function (popoverTriggerEl) {
        return new bootstrap.Popover(popoverTriggerEl);
    });
    
    // Add smooth scrolling
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const href = this.getAttribute('href');
            if (href && href !== '#') {
                const target = document.querySelector(href);
                if (target) {
                    target.scrollIntoView({
                        behavior: 'smooth',
                        block: 'start'
                    });
                }
            }
        });
    });
}

// Load featured artworks
async function loadFeaturedArtworks() {
    // Check if featured artworks container exists (only load on pages that have it)
    const container = document.getElementById('featured-artworks');
    console.log('loadFeaturedArtworks called, container found:', !!container);
    if (!container) {
        console.log('No featured-artworks container found, skipping...');
        return; // Skip loading on pages without featured artworks container
    }
    
    try {
        const response = await fetch('/api/artworks/featured');
        
        if (response.ok) {
            const data = await response.json();
            displayFeaturedArtworks(data.artworks || []);
        } else {
            displayFeaturedArtworksPlaceholder();
        }
    } catch (error) {
        console.error('Error loading featured artworks:', error);
        displayFeaturedArtworksPlaceholder();
    }
}

// Display featured artworks
function displayFeaturedArtworks(artworks) {
    const container = document.getElementById('featured-artworks');
    if (!container) return; // Safety check
    
    if (artworks.length === 0) {
        displayFeaturedArtworksPlaceholder();
        return;
    }
    
    let html = '';
    artworks.slice(0, 6).forEach(artwork => {
        html += createArtworkCard(artwork);
    });
    
    container.innerHTML = html;
    
    // Add fade-in animation
    container.querySelectorAll('.card').forEach((card, index) => {
        setTimeout(() => {
            card.classList.add('fade-in-up');
        }, index * 100);
    });
}

// Display placeholder when no artworks
function displayFeaturedArtworksPlaceholder() {
    const container = document.getElementById('featured-artworks');
    if (!container) return; // Safety check
    
    container.innerHTML = `
        <div class="col-12 text-center">
            <div class="card border-0 shadow-sm">
                <div class="card-body p-5">
                    <i class="fas fa-palette fa-3x text-muted mb-3"></i>
                    <h5 class="text-muted">Featured Artworks Coming Soon</h5>
                    <p class="text-muted mb-4">
                        Our platform is growing! Featured artworks will appear here once artists start uploading their amazing creations.
                    </p>
                    <a href="#" class="btn btn-primary" onclick="showRegisterModal()">
                        <i class="fas fa-user-plus me-2"></i>Join as an Artist
                    </a>
                </div>
            </div>
        </div>
    `;
}

// Create artwork card HTML
function createArtworkCard(artwork) {
    const isAuction = artwork.saleType === 'AUCTION';
    const priceDisplay = isAuction ? 
        `Current Bid: ${formatPrice(artwork.currentBid || artwork.startingBid)}` : 
        formatPrice(artwork.price);
    
    return `
        <div class="col-lg-4 col-md-6 mb-4">
            <div class="card artwork-card h-100 border-0 shadow-sm">
                <div class="position-relative">
                    <img src="${artwork.primaryImageUrl || '/assets/images/placeholder-art.jpg'}" 
                         class="card-img-top" alt="${artwork.title}">
                    ${isAuction ? `
                        <div class="position-absolute top-0 end-0 m-2">
                            <span class="badge bg-danger">
                                <i class="fas fa-gavel me-1"></i>Auction
                            </span>
                        </div>
                    ` : ''}
                    <div class="card-img-overlay d-flex flex-column justify-content-end">
                        <div class="artwork-price mb-2">
                            ${priceDisplay}
                        </div>
                    </div>
                </div>
                <div class="card-body">
                    <h6 class="card-title mb-2">${truncateText(artwork.title, 50)}</h6>
                    <p class="card-text text-muted small mb-2">
                        by ${artwork.artistId ? 
                            `<a href="/profile.jsp?userId=${artwork.artistId}" class="text-decoration-none text-muted" title="View artist profile">${artwork.artistName || 'Unknown Artist'}</a>` : 
                            (artwork.artistName || 'Unknown Artist')}
                    </p>
                    <p class="card-text small text-muted">
                        ${truncateText(artwork.description, 80)}
                    </p>
                    ${isAuction && artwork.auctionEndTime ? `
                        <div class="auction-timer small mb-2">
                            <i class="fas fa-clock me-1"></i>
                            <span class="timer-text" data-end-time="${artwork.auctionEndTime}">
                                Loading...
                            </span>
                        </div>
                    ` : ''}
                </div>
                <div class="card-footer bg-transparent border-0">
                    <div class="d-flex justify-content-between align-items-center">
                        <small class="text-muted">
                            <i class="fas fa-eye me-1"></i>${artwork.views || 0} views
                        </small>
                        <div>
                            <button class="btn btn-outline-primary btn-sm me-1" 
                                    onclick="viewArtwork('${artwork.artworkId}')">
                                <i class="fas fa-eye"></i>
                            </button>
                            <button class="btn btn-outline-danger btn-sm" 
                                    onclick="toggleLike('${artwork.artworkId}')">
                                <i class="far fa-heart"></i>
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    `;
}

// Format price
function formatPrice(price) {
    if (!price) return 'Price not set';
    
    const numPrice = typeof price === 'string' ? parseFloat(price) : price;
    return new Intl.NumberFormat('en-MY', {
        style: 'currency',
        currency: 'MYR',
        minimumFractionDigits: 0,
        maximumFractionDigits: 0
    }).format(numPrice);
}

// Truncate text
function truncateText(text, maxLength) {
    if (!text) return '';
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
}

// View artwork details
function viewArtwork(artworkId) {
    if (isLoggedIn()) {
        window.location.href = `/artwork/${artworkId}`;
    } else {
        showInfoMessage('Please login to view artwork details');
        showLoginModal();
    }
}

// Toggle like artwork
async function toggleLike(artworkId) {
    if (!isLoggedIn()) {
        showInfoMessage('Please login to like artworks');
        showLoginModal();
        return;
    }
    
    try {
        const response = await fetch(`/api/artworks/${artworkId}/like`, {
            method: 'POST'
        });
        
        if (response.ok) {
            const data = await response.json();
            showSuccessMessage(data.liked ? 'Artwork liked!' : 'Artwork unliked!');
            
            // Update UI if needed
            const heartIcon = document.querySelector(`button[onclick="toggleLike('${artworkId}')"] i`);
            if (heartIcon) {
                heartIcon.className = data.liked ? 'fas fa-heart' : 'far fa-heart';
            }
        } else {
            showErrorMessage('Failed to update like status');
        }
    } catch (error) {
        console.error('Error toggling like:', error);
        showErrorMessage('Failed to update like status');
    }
}

// Initialize auction timers
function initializeAuctionTimers() {
    const timerElements = document.querySelectorAll('.timer-text[data-end-time]');
    
    timerElements.forEach(element => {
        const endTime = new Date(element.getAttribute('data-end-time'));
        updateTimer(element, endTime);
        
        // Update every second
        setInterval(() => updateTimer(element, endTime), 1000);
    });
}

// Update timer display
function updateTimer(element, endTime) {
    const now = new Date();
    const timeLeft = endTime - now;
    
    if (timeLeft <= 0) {
        element.textContent = 'Auction Ended';
        element.parentElement.classList.remove('auction-timer');
        element.parentElement.classList.add('text-muted');
        return;
    }
    
    const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
    const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
    const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);
    
    let timerText = '';
    if (days > 0) {
        timerText = `${days}d ${hours}h`;
    } else if (hours > 0) {
        timerText = `${hours}h ${minutes}m`;
    } else if (minutes > 0) {
        timerText = `${minutes}m ${seconds}s`;
    } else {
        timerText = `${seconds}s`;
    }
    
    element.textContent = timerText;
}

// Search functionality
function performSearch(query) {
    if (query.trim() === '') {
        showErrorMessage('Please enter a search term');
        return;
    }
    
    window.location.href = `/search?q=${encodeURIComponent(query)}`;
}

// Add search event listener if search form exists
document.addEventListener('DOMContentLoaded', function() {
    const searchForm = document.getElementById('search-form');
    if (searchForm) {
        searchForm.addEventListener('submit', function(e) {
            e.preventDefault();
            const query = document.getElementById('search-input').value;
            performSearch(query);
        });
    }
    
    // Initialize timers after DOM is loaded
    setTimeout(initializeAuctionTimers, 1000);
});

// Navbar scroll effect
window.addEventListener('scroll', function() {
    const navbar = document.querySelector('.navbar');
    if (window.scrollY > 50) {
        navbar.style.background = 'rgba(255, 255, 255, 0.98)';
        navbar.style.boxShadow = '0 2px 8px rgba(0, 0, 0, 0.08)';
    } else {
        navbar.style.background = 'rgba(255, 255, 255, 0.98)';
        navbar.style.boxShadow = '0 1px 0 rgba(0, 0, 0, 0.05)';
    }
});

// Image lazy loading
function initializeLazyLoading() {
    const images = document.querySelectorAll('img[data-src]');
    
    const imageObserver = new IntersectionObserver((entries, observer) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                const img = entry.target;
                img.src = img.dataset.src;
                img.removeAttribute('data-src');
                observer.unobserve(img);
            }
        });
    });
    
    images.forEach(img => imageObserver.observe(img));
}

// Call lazy loading initialization
document.addEventListener('DOMContentLoaded', initializeLazyLoading);

// Utility function to format date
function formatDate(dateString) {
    const date = new Date(dateString);
    return date.toLocaleDateString('en-MY', {
        year: 'numeric',
        month: 'long',
        day: 'numeric'
    });
}

// Utility function to format time
function formatTime(dateString) {
    const date = new Date(dateString);
    return date.toLocaleTimeString('en-MY', {
        hour: '2-digit',
        minute: '2-digit'
    });
}

// Utility function to format datetime
function formatDateTime(dateString) {
    return `${formatDate(dateString)} at ${formatTime(dateString)}`;
}

// Export useful functions for other modules
window.ArtXchange = {
    formatPrice,
    formatDate,
    formatTime,
    formatDateTime,
    truncateText,
    performSearch,
    viewArtwork,
    toggleLike
};
