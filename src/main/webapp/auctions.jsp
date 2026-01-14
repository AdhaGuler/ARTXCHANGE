<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Auctions - ArtXchange</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-primary sticky-top">
        <div class="container">
            <a class="navbar-brand fw-bold" href="${pageContext.request.contextPath}/">
                <i class="fas fa-palette me-2"></i>ArtXchange
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/">Home</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/browse.jsp">Browse Art</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link active" href="${pageContext.request.contextPath}/auctions.jsp">Auctions</a>
                    </li>
                    <li class="nav-item" id="biddings-nav" style="display: none;">
                        <a class="nav-link" href="${pageContext.request.contextPath}/biddings.jsp">
                            <i class="fas fa-gavel me-1"></i>Biddings
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/artists.jsp">Artists</a>
                    </li>
                </ul>
                
                <ul class="navbar-nav">
                    <li class="nav-item" id="auth-buttons">
                        <a class="nav-link" href="#" onclick="showLoginModal()">Login</a>
                        <a class="nav-link" href="#" onclick="showRegisterModal()">Register</a>
                    </li>
                    <li class="nav-item dropdown d-none" id="user-menu">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="fas fa-user-circle me-1"></i>
                            <span id="user-name">User</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile.jsp">My Profile</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/messages.jsp">Messages</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#" onclick="logout()">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Auctions Hero Section -->
    <div class="bg-light py-5 mb-4">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-lg-8">
                    <h1 class="mb-3"><i class="fas fa-gavel me-2"></i>Live Art Auctions</h1>
                    <p class="lead mb-4">Discover unique artworks and place your bids in our ongoing auctions. New auctions are added regularly.</p>
                </div>
                <div class="col-lg-4">
                    <div class="card shadow-sm">
                        <div class="card-body">
                            <h5 class="card-title">Current Auction Stats</h5>
                            <ul class="list-group list-group-flush">
                                <li class="list-group-item d-flex justify-content-between">
                                    <span><i class="fas fa-clock me-2"></i>Live Auctions</span>
                                    <span id="liveAuctionsCount" class="fw-bold">--</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span><i class="fas fa-calendar-alt me-2"></i>Ending Soon</span>
                                    <span id="endingSoonCount" class="fw-bold">--</span>
                                </li>
                                <li class="list-group-item d-flex justify-content-between">
                                    <span><i class="fas fa-star me-2"></i>Featured</span>
                                    <span id="featuredCount" class="fw-bold">--</span>
                                </li>
                            </ul>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="container my-4">
        <div class="row">
            <div class="col-md-3">
                <div class="card mb-4">
                    <div class="card-header">
                        <h5 class="mb-0"><i class="fas fa-filter me-2"></i>Filters</h5>
                    </div>
                    <div class="card-body">
                        <form id="filterForm">
                            <!-- Category Filter -->
                            <div class="mb-3">
                                <label class="form-label">Category</label>
                                <select class="form-select" id="categoryFilter">
                                    <option value="">All Categories</option>
                                    <option value="PAINTING">Painting</option>
                                    <option value="SCULPTURE">Sculpture</option>
                                    <option value="PHOTOGRAPHY">Photography</option>
                                    <option value="DIGITAL_ART">Digital Art</option>
                                    <option value="MIXED_MEDIA">Mixed Media</option>
                                    <option value="OTHER">Other</option>
                                </select>
                            </div>
                            
                            <!-- Price Range -->
                            <div class="mb-3">
                                <label class="form-label">Current Bid Range (RM)</label>
                                <div class="row">
                                    <div class="col-6">
                                        <input type="number" class="form-control" id="minPrice" placeholder="Min">
                                    </div>
                                    <div class="col-6">
                                        <input type="number" class="form-control" id="maxPrice" placeholder="Max">
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Auction Status -->
                            <div class="mb-3">
                                <label class="form-label">Status</label>
                                <select class="form-select" id="auctionStatus">
                                    <option value="">All Auctions</option>
                                    <option value="ending_soon">Ending Soon (24h)</option>
                                    <option value="newly_listed">Newly Listed</option>
                                    <option value="featured">Featured</option>
                                </select>
                            </div>
                            
                            <!-- Availability Status -->
                            <div class="mb-3">
                                <label class="form-label">Availability</label>
                                <select class="form-select" id="availabilityFilter">
                                    <option value="">All (Available & Sold)</option>
                                    <option value="ACTIVE">Available Only</option>
                                    <option value="SOLD">Sold Only</option>
                                </select>
                            </div>
                            
                            <!-- Sort By -->
                            <div class="mb-3">
                                <label class="form-label">Sort By</label>
                                <select class="form-select" id="sortBy">
                                    <option value="ending_soon">Ending Soon</option>
                                    <option value="most_bids">Most Bids</option>
                                    <option value="price_low">Current Bid: Low to High</option>
                                    <option value="price_high">Current Bid: High to Low</option>
                                    <option value="newly_listed">Newly Listed</option>
                                </select>
                            </div>
                            
                            <button type="button" class="btn btn-primary w-100" onclick="applyFilters()">
                                Apply Filters
                            </button>
                            <button type="button" class="btn btn-outline-secondary w-100 mt-2" onclick="clearFilters()">
                                Clear Filters
                            </button>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-md-9">
                <!-- Search Bar -->
                <div class="mb-4">
                    <div class="input-group">
                        <input type="text" class="form-control" id="searchInput" placeholder="Search auctions...">
                        <button class="btn btn-primary" type="button" onclick="searchAuctions()">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
                
                <!-- Loading Spinner -->
                <div id="loadingSpinner" class="text-center my-5" style="display: none;">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Loading auctions...</p>
                </div>
                
                <!-- All Auctions Section -->
                <h3 class="mb-4"><i class="fas fa-gavel me-2"></i>All Auctions</h3>
                <div class="row" id="auctionsGrid">
                    <!-- Auctions will be loaded here via JavaScript -->
                </div>
                
                <!-- Pagination -->
                <nav aria-label="Auctions pagination" class="mt-4">
                    <ul class="pagination justify-content-center" id="pagination">
                        <!-- Pagination will be generated by JavaScript -->
                    </ul>
                </nav>
            </div>
        </div>
    </div>

    <!-- Auction Modal -->
    <div class="modal fade" id="auctionModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalAuctionTitle">Auction Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="modalAuctionContent">
                    <!-- Content will be populated by JavaScript -->
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bid Modal -->
    <div class="modal fade" id="bidModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Place a Bid</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="bidForm">
                        <input type="hidden" id="bidArtworkId">
                        <div class="mb-3">
                            <label for="currentBid" class="form-label">Current Highest Bid</label>
                            <div class="input-group">
                                <span class="input-group-text">RM</span>
                                <input type="text" class="form-control" id="currentBid" disabled>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label for="bidAmount" class="form-label">Your Bid Amount</label>
                            <div class="input-group">
                                <span class="input-group-text">RM</span>
                                <input type="number" step="0.01" class="form-control" id="bidAmount" required>
                            </div>
                            <div class="form-text">Minimum bid increment: RM 5.00</div>
                        </div>
                        <div class="mb-3 form-check">
                            <input type="checkbox" class="form-check-input" id="confirmBid" required>
                            <label class="form-check-label" for="confirmBid">I confirm my bid is final and I agree to the <a href="#">Terms and Conditions</a>.</label>
                        </div>
                        <div id="bidError" class="alert alert-danger d-none"></div>
                        <button type="submit" class="btn btn-warning w-100">
                            <i class="fas fa-gavel me-2"></i>Place Bid
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/firebase-config.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
    <script>
        let currentPage = 1;
        let totalPages = 1;
        let currentFilters = {};
        
        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            initializeAuth();
            loadAuctionStats();
            loadAuctions();
        });
        
        function loadAuctionStats() {
            fetch('/api/auctions/stats')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Network response was not ok');
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.success) {
                        document.getElementById('liveAuctionsCount').textContent = data.liveCount || 0;
                        document.getElementById('endingSoonCount').textContent = data.endingSoonCount || 0;
                        document.getElementById('featuredCount').textContent = data.featuredCount || 0;
                    }
                })
                .catch(error => {
                    console.error('Error loading auction stats:', error);
                });
        }
        
        function loadAuctions(page = 1) {
            showLoading(true);
            
            // Build query parameters
            const params = new URLSearchParams({
                page: page,
                limit: 9,
                ...currentFilters
            });
            
            fetch('/api/auctions?' + params)
                .then(response => response.json())
                .then(data => {
                    console.log('Auctions API response:', data);
                    if (data.success) {
                        const auctions = data.auctions || [];
                        console.log('Received auctions before sorting:', auctions.map(a => ({ title: a.title, status: a.status })));
                        displayAuctions(auctions);
                        updatePagination(data.page || 1, data.totalPages || 1);
                        currentPage = data.page || 1;
                        totalPages = data.totalPages || 1;
                    } else {
                        console.error('Failed to load auctions:', data.message);
                        showError('Failed to load auctions');
                    }
                })
                .catch(error => {
                    console.error('Error loading auctions:', error);
                    showError('Error loading auctions');
                })
                .finally(() => {
                    showLoading(false);
                });
        }
        
        function displayAuctions(auctions) {
            console.log('Displaying auctions:', auctions);
            const grid = document.getElementById('auctionsGrid');
            
            if (auctions.length === 0) {
                grid.innerHTML = 
                    '<div class="col-12 text-center py-5">' +
                        '<i class="fas fa-gavel fa-3x text-muted mb-3"></i>' +
                        '<h4 class="text-muted">No auctions available</h4>' +
                        '<p class="text-muted">Auctions will be added soon. Check back later for exciting bidding opportunities!</p>' +
                        '<a href="/browse.jsp" class="btn btn-outline-primary mt-3">' +
                            '<i class="fas fa-paint-brush me-2"></i>Browse Available Artworks' +
                        '</a>' +
                    '</div>';
                return;
            }
            
            // Sort auctions: ACTIVE first, then SOLD (available first, then sold)
            auctions.sort((a, b) => {
                const statusA = (a.status || '').toUpperCase();
                const statusB = (b.status || '').toUpperCase();
                
                // ACTIVE/available auctions come first
                if (statusA === 'ACTIVE' && statusB === 'SOLD') {
                    return -1; // ACTIVE comes before SOLD
                } else if (statusA === 'SOLD' && statusB === 'ACTIVE') {
                    return 1; // SOLD comes after ACTIVE
                }
                // If same status, maintain original order (or sort by endTime for ACTIVE)
                if (statusA === 'ACTIVE' && statusB === 'ACTIVE') {
                    // For active auctions, sort by endTime (ending soon first)
                    const endTimeA = a.endTime || a.auctionEndTime;
                    const endTimeB = b.endTime || b.auctionEndTime;
                    if (endTimeA && endTimeB) {
                        return new Date(endTimeA) - new Date(endTimeB);
                    }
                }
                return 0; // Same status, maintain order
            });
            
            console.log('Sorted auctions - Available first, then Sold:', auctions.map(a => ({ title: a.title, status: a.status })));
            
            // Apply client-side availability filter if specified
            let filteredAuctions = auctions;
            const availabilityFilter = currentFilters.availability;
            if (availabilityFilter) {
                filteredAuctions = auctions.filter(auction => {
                    const status = auction.status || '';
                    if (availabilityFilter === 'ACTIVE') {
                        return status !== 'SOLD';
                    } else if (availabilityFilter === 'SOLD') {
                        return status === 'SOLD';
                    }
                    return true;
                });
            }
            
            if (filteredAuctions.length === 0) {
                grid.innerHTML = 
                    '<div class="col-12 text-center py-5">' +
                        '<i class="fas fa-gavel fa-3x text-muted mb-3"></i>' +
                        '<h4 class="text-muted">No auctions found</h4>' +
                        '<p class="text-muted">Try adjusting your filters</p>' +
                    '</div>';
                return;
            }
            
            grid.innerHTML = filteredAuctions.map(auction => {
                return createAuctionCard(auction, false);
            }).join('');
            
            // Initialize auction timers
            initializeAuctionTimers();
        }
        
        function createAuctionCard(auction, isFeatured) {
            // Check if auction is sold
            const isSold = auction.status === 'SOLD';
            
            let urgencyBadge = '';
            let soldBadge = '';
            
            // Handle end time - use the actual endTime from the data
            const endTime = auction.endTime ? new Date(auction.endTime) : 
                           auction.auctionEndTime ? new Date(auction.auctionEndTime) : 
                           new Date(Date.now() + 7 * 24 * 60 * 60 * 1000); // fallback to 7 days from now
                           
            const now = new Date();
            const timeLeft = endTime - now;
            const hoursLeft = timeLeft / (1000 * 60 * 60);
            const daysLeft = Math.floor(hoursLeft / 24);
            
            console.log('Auction:', auction.title, 'End time:', auction.endTime, 'Hours left:', hoursLeft, 'Days left:', daysLeft, 'Status:', auction.status);
            
            // Check if auction has ended - check both status field and end time
            let isAuctionEnded = false;
            if (isSold) {
                isAuctionEnded = true;
                soldBadge = '<div class="sold-badge"><i class="fas fa-check-circle me-1"></i>SOLD</div>';
            } else if (auction.status === 'ENDED' || auction.status === 'CANCELED' || auction.status === 'INACTIVE') {
                isAuctionEnded = true;
            } else if (timeLeft <= 0) {
                isAuctionEnded = true;
            }
            
            if (isSold) {
                // Sold badge takes priority
                soldBadge = '<div class="sold-badge"><i class="fas fa-check-circle me-1"></i>SOLD</div>';
            } else if (isAuctionEnded) {
                urgencyBadge = '<div class="badge bg-dark position-absolute top-0 end-0 m-2"><i class="fas fa-times me-1"></i>Ended</div>';
            } else if (hoursLeft < 6) {
                urgencyBadge = '<div class="badge bg-danger position-absolute top-0 end-0 m-2"><i class="fas fa-fire-alt me-1"></i>Ending Soon</div>';
            } else if (hoursLeft < 24) {
                urgencyBadge = '<div class="badge bg-warning position-absolute top-0 end-0 m-2"><i class="fas fa-clock me-1"></i>< 24h Left</div>';
            } else if (daysLeft < 3) {
                urgencyBadge = '<div class="badge bg-info position-absolute top-0 end-0 m-2"><i class="fas fa-clock me-1"></i>' + daysLeft + ' Days Left</div>';
            }
            
            const featuredBadge = isFeatured && !isSold ? '<div class="badge bg-primary position-absolute top-0 start-0 m-2"><i class="fas fa-star me-1"></i>Featured</div>' : '';
            
            const colClass = isFeatured ? 'col-md-4 mb-4' : 'col-md-4 mb-4';
            
            // Use actual field names from our Firebase data
            const imageUrl = auction.primaryImageUrl || '/assets/images/placeholder-artwork.svg';
            
            // For sold auctions, show winning bid amount; otherwise show current bid
            let displayPrice = 0;
            if (isSold && auction.winningBidAmount) {
                displayPrice = auction.winningBidAmount;
            } else {
                displayPrice = auction.currentBid || auction.startingBid || auction.price || 0;
            }
            
            const bidCount = auction.bidCount || 0;
            const artistName = auction.artistName || 'Unknown Artist';
            
            // Card class with sold overlay
            const cardClass = isSold ? 'card auction-card h-100 sold-overlay' : 'card auction-card h-100';
            
            // Determine button HTML based on auction status
            let bidButton = '';
            if (isSold) {
                bidButton = '<button class="btn btn-secondary btn-sm w-100" disabled>' +
                               '<i class="fas fa-check-circle me-2"></i>Sold - No Longer Available' +
                           '</button>';
            } else if (isAuctionEnded) {
                bidButton = '<button class="btn btn-secondary btn-sm w-100" disabled>' +
                               '<i class="fas fa-times-circle me-2"></i>' +
                               (auction.status === 'CANCELED' ? 'Auction Canceled' : 'Auction Ended') +
                           '</button>';
            } else {
                bidButton = '<button class="btn btn-warning btn-sm w-100" onclick="event.stopPropagation(); openBidModal(\'' + auction.id + '\', ' + displayPrice + ')">' +
                               '<i class="fas fa-gavel me-2"></i>Place Bid' +
                           '</button>';
            }
            
            // Price label - "Final Price" for sold, "Current Bid" for active
            const priceLabel = isSold ? 'Final Price:' : 'Current Bid:';
            const priceClass = isSold ? 'text-danger' : 'text-primary';
            
            // Timer display - only show for non-sold auctions
            let timerDisplay = '';
            if (!isSold) {
                timerDisplay = '<div class="mt-3">' +
                                   '<small class="text-muted"><i class="fas fa-clock me-1"></i>Ends in: </small>' +
                                   '<span class="auction-timer fw-bold text-danger" data-end-time="' + endTime.toISOString() + '" data-auction-id="' + auction.id + '">Loading...</span>' +
                               '</div>';
            } else if (auction.winnerName) {
                timerDisplay = '<div class="mt-3">' +
                                   '<small class="text-muted"><i class="fas fa-trophy me-1"></i>Won by: ' + auction.winnerName + '</small>' +
                               '</div>';
            }
            
            return '<div class="' + colClass + '">' +
                       '<div class="' + cardClass + '" onclick="showAuctionModal(\'' + auction.id + '\')">' +
                           '<div class="position-relative">' +
                               '<img src="' + imageUrl + '" ' +
                                    'class="card-img-top auction-image" alt="' + (auction.title || 'Untitled') + '">' +
                               soldBadge +
                               urgencyBadge +
                               featuredBadge +
                           '</div>' +
                           '<div class="card-body">' +
                               '<h5 class="card-title">' + (auction.title || 'Untitled') + '</h5>' +
                               '<p class="card-text text-muted small">by ' + artistName + '</p>' +
                               '<div class="d-flex justify-content-between mb-2">' +
                                   '<div>' +
                                       '<strong>' + priceLabel + '</strong>' +
                                   '</div>' +
                                   '<div class="' + priceClass + ' fw-bold">RM ' + displayPrice.toFixed(2) + '</div>' +
                               '</div>' +
                               '<div class="d-flex justify-content-between mb-2">' +
                                   '<div>' +
                                       '<strong>Bids:</strong>' +
                                   '</div>' +
                                   '<div>' + bidCount + '</div>' +
                               '</div>' +
                               timerDisplay +
                           '</div>' +
                           '<div class="card-footer bg-transparent">' +
                               bidButton +
                           '</div>' +
                       '</div>' +
                   '</div>';
        }
        
        function initializeAuctionTimers() {
            document.querySelectorAll('.auction-timer').forEach(timer => {
                const endTime = new Date(timer.dataset.endTime);
                console.log('Initializing timer for end time:', timer.dataset.endTime, 'Parsed as:', endTime);
                updateTimer(timer, endTime);
                
                // Update every second
                setInterval(() => updateTimer(timer, endTime), 1000);
            });
        }
        
        function updateTimer(element, endTime) {
            const now = new Date();
            const timeLeft = endTime - now;
            
            console.log('Timer update - Now:', now, 'End time:', endTime, 'Time left (ms):', timeLeft);
            
            if (timeLeft <= 0) {
                element.textContent = 'Auction ended';
                element.classList.add('text-danger');
                
                // Update the Place Bid button to "Auction Ended" if it exists
                const auctionId = element.dataset.auctionId;
                if (auctionId) {
                    const card = element.closest('.card');
                    if (card) {
                        const bidButton = card.querySelector('.card-footer button');
                        if (bidButton && !bidButton.disabled) {
                            bidButton.className = 'btn btn-secondary btn-sm w-100';
                            bidButton.disabled = true;
                            bidButton.innerHTML = '<i class="fas fa-times-circle me-2"></i>Auction Ended';
                        }
                    }
                }
                return;
            }
            
            const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
            const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
            const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
            const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);
            
            if (days > 0) {
                element.textContent = days + 'd ' + hours + 'h ' + minutes + 'm';
            } else if (hours > 0) {
                element.textContent = hours + 'h ' + minutes + 'm ' + seconds + 's';
            } else {
                element.textContent = minutes + 'm ' + seconds + 's';
            }
        }
        
        function updatePagination(currentPage, totalPages) {
            const pagination = document.getElementById('pagination');
            
            if (totalPages <= 1) {
                pagination.innerHTML = '';
                return;
            }
            
            let paginationHTML = '';
            
            // Previous button
            const prevDisabled = currentPage === 1 ? 'disabled' : '';
            paginationHTML += 
                '<li class="page-item ' + prevDisabled + '">' +
                    '<a class="page-link" href="#" onclick="loadAuctions(' + (currentPage - 1) + ')">' +
                        '<i class="fas fa-chevron-left"></i>' +
                    '</a>' +
                '</li>';
            
            // Page numbers
            const startPage = Math.max(1, currentPage - 2);
            const endPage = Math.min(totalPages, currentPage + 2);
            
            if (startPage > 1) {
                paginationHTML += '<li class="page-item"><a class="page-link" href="#" onclick="loadAuctions(1)">1</a></li>';
                if (startPage > 2) {
                    paginationHTML += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                }
            }
            
            for (let i = startPage; i <= endPage; i++) {
                paginationHTML +=
                    '<li class="page-item ' + (i === currentPage ? 'active' : '') + '">' +
                        '<a class="page-link" href="#" onclick="loadAuctions(' + i + ')">' + i + '</a>' +
                    '</li>';
            }
            
            if (endPage < totalPages) {
                if (endPage < totalPages - 1) {
                    paginationHTML += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                }
                paginationHTML += '<li class="page-item"><a class="page-link" href="#" onclick="loadAuctions(' + totalPages + ')">' + totalPages + '</a></li>';
            }
            
            // Next button
            paginationHTML += 
                '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
                    '<a class="page-link" href="#" onclick="loadAuctions(' + (currentPage + 1) + ')">' +
                        '<i class="fas fa-chevron-right"></i>' +
                    '</a>' +
                '</li>';
            
            pagination.innerHTML = paginationHTML;
        }
        
        function applyFilters() {
            currentFilters = {
                category: document.getElementById('categoryFilter').value,
                minPrice: document.getElementById('minPrice').value,
                maxPrice: document.getElementById('maxPrice').value,
                status: document.getElementById('auctionStatus').value,
                availability: document.getElementById('availabilityFilter').value,
                sortBy: document.getElementById('sortBy').value,
                search: document.getElementById('searchInput').value
            };
            
            // Remove empty filters
            Object.keys(currentFilters).forEach(key => {
                if (!currentFilters[key]) {
                    delete currentFilters[key];
                }
            });
            
            loadAuctions(1);
        }
        
        function clearFilters() {
            document.getElementById('filterForm').reset();
            document.getElementById('searchInput').value = '';
            currentFilters = {};
            loadAuctions(1);
        }
        
        function searchAuctions() {
            applyFilters();
        }
        
        function showAuctionModal(auctionId) {
            // Fetch auction details and show modal
            fetch('/api/auctions/' + auctionId)
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        displayAuctionModal(data.auction);
                    }
                })
                .catch(error => {
                    console.error('Error loading auction details:', error);
                });
        }
        
        function displayAuctionModal(auction) {
            document.getElementById('modalAuctionTitle').textContent = auction.title;
            
            // Check if auction has ended
            let isAuctionEnded = false;
            let auctionEndedLabel = '';
            const endTime = auction.endTime ? new Date(auction.endTime) : 
                           auction.auctionEndTime ? new Date(auction.auctionEndTime) : null;
            
            if (auction.status === 'ENDED' || auction.status === 'CANCELED' || auction.status === 'INACTIVE') {
                isAuctionEnded = true;
                auctionEndedLabel = auction.status === 'CANCELED' ? 'Auction Canceled' : 'Auction Ended';
            } else if (endTime && endTime <= new Date()) {
                isAuctionEnded = true;
                auctionEndedLabel = 'Auction Ended';
            }
            
            // Check if auction is sold
            const isSold = auction.status === 'SOLD';
            
            // Build action button HTML
            let actionButton = '';
            if (isSold) {
                actionButton = '<button class="btn btn-secondary btn-lg" disabled>' +
                                  '<i class="fas fa-check-circle me-2"></i>Sold - No Longer Available' +
                              '</button>';
            } else if (isAuctionEnded) {
                actionButton = '<button class="btn btn-secondary btn-lg" disabled>' +
                                  '<i class="fas fa-times-circle me-2"></i>' + auctionEndedLabel +
                              '</button>';
            } else {
                actionButton = '<button class="btn btn-warning btn-lg" onclick="openBidModal(\'' + auction.id + '\', ' + auction.currentBid + ')">' +
                                  '<i class="fas fa-gavel me-2"></i>Place Bid' +
                              '</button>';
            }
            
            // Price display - show final price for sold auctions
            let priceDisplay = '';
            if (isSold && auction.winningBidAmount) {
                priceDisplay = '<div class="mb-3">' +
                                  '<div class="alert alert-danger mb-2"><i class="fas fa-check-circle me-2"></i><strong>SOLD</strong></div>' +
                                  '<strong>Final Price:</strong> ' +
                                  '<span class="text-danger fs-4">RM ' + auction.winningBidAmount.toFixed(2) + '</span>' +
                                  (auction.winnerName ? '<div class="small text-muted mt-1"><i class="fas fa-trophy me-1"></i>Won by: ' + auction.winnerName + '</div>' : '') +
                              '</div>';
            } else {
                priceDisplay = '<div class="mb-3">' +
                                  '<strong>Current Bid:</strong> ' +
                                  '<span class="text-primary fs-4">RM ' + auction.currentBid.toFixed(2) + '</span>' +
                                  '<div class="small text-muted">Starting price: RM ' + auction.startingPrice.toFixed(2) + '</div>' +
                              '</div>';
            }
            
            const modalContent = document.getElementById('modalAuctionContent');
            modalContent.innerHTML = 
                '<div class="row">' +
                    '<div class="col-md-6">' +
                        '<img src="' + (auction.imageUrl || '/assets/images/placeholder-artwork.jpg') + '" ' +
                             'class="img-fluid rounded" alt="' + auction.title + '">' +
                    '</div>' +
                    '<div class="col-md-6">' +
                        '<h4>' + auction.title + '</h4>' +
                        '<p class="text-muted">by ' + (auction.artistName || 'Unknown Artist') + '</p>' +
                        '<p>' + auction.description + '</p>' +
                        
                        '<div class="mb-3">' +
                            '<strong>Category:</strong> ' + auction.category +
                        '</div>' +
                        
                        priceDisplay +
                        
                        '<div class="mb-3">' +
                            '<strong>Total Bids:</strong> ' + auction.bidCount +
                        '</div>' +
                        
                        '<div class="mb-3">' +
                            '<strong>Auction ends:</strong>' +
                            '<div class="text-danger">' +
                                '<span class="auction-timer" data-end-time="' + (endTime ? endTime.toISOString() : auction.auctionEndTime) + '">' +
                                    'Calculating...' +
                                '</span>' +
                            '</div>' +
                        '</div>' +
                        
                        '<div class="d-grid gap-2">' +
                            actionButton +
                            
                            '<button class="btn btn-outline-primary" onclick="contactArtist(\'' + auction.artistId + '\', \'' + auction.id + '\')">' +
                                '<i class="fas fa-envelope me-2"></i>Contact Artist' +
                            '</button>' +
                        '</div>' +
                    '</div>' +
                '</div>' +
                
                '<hr class="my-4">' +
                
                '<div class="row">' +
                    '<div class="col-md-12">' +
                        '<h5 class="mb-3">Recent Bids</h5>' +
                        (auction.recentBids && auction.recentBids.length > 0 ? renderBidHistory(auction.recentBids) : 
                            '<p class="text-muted">No bids have been placed yet. Be the first to bid!</p>') +
                    '</div>' +
                '</div>';
            
            // Initialize timer for modal
            initializeAuctionTimers();
            
            // Show modal
            new bootstrap.Modal(document.getElementById('auctionModal')).show();
        }
        
        function renderBidHistory(bids) {
            return '<div class="table-responsive">' +
                       '<table class="table table-striped">' +
                           '<thead>' +
                               '<tr>' +
                                   '<th>Bidder</th>' +
                                   '<th>Amount</th>' +
                                   '<th>Time</th>' +
                               '</tr>' +
                           '</thead>' +
                           '<tbody>' +
                               bids.map(bid => {
                                   return '<tr>' +
                                              '<td>' + bid.bidderName + '</td>' +
                                              '<td class="text-primary">RM ' + bid.amount.toFixed(2) + '</td>' +
                                              '<td>' + formatDate(bid.timestamp) + '</td>' +
                                           '</tr>';
                               }).join('') +
                           '</tbody>' +
                       '</table>' +
                   '</div>';
        }
        
        function formatDate(timestamp) {
            const date = new Date(timestamp);
            return date.toLocaleDateString() + ' ' + date.toLocaleTimeString();
        }
        
        function openBidModal(auctionId, currentBid) {
            // First check if user is logged in
            if (!firebase.auth().currentUser) {
                showError('Please log in to place a bid');
                return;
            }
            
            // Check if auction has ended by fetching current auction data
            fetch('/api/auctions/' + auctionId)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.auction) {
                        const auction = data.auction;
                        
                        // Check if auction has ended
                        let isAuctionEnded = false;
                        if (auction.status === 'ENDED' || auction.status === 'CANCELED' || auction.status === 'INACTIVE') {
                            isAuctionEnded = true;
                        } else if (auction.endTime || auction.auctionEndTime) {
                            const endTime = auction.endTime ? new Date(auction.endTime) : new Date(auction.auctionEndTime);
                            if (endTime <= new Date()) {
                                isAuctionEnded = true;
                            }
                        }
                        
                        if (isAuctionEnded) {
                            showError('This auction has ended. Bidding is no longer available.');
                            return;
                        }
                        
                        // Auction is active, proceed with opening bid modal
                        // Set values in bid modal
                        document.getElementById('bidArtworkId').value = auctionId;
                        document.getElementById('currentBid').value = currentBid.toFixed(2);
                        document.getElementById('bidAmount').min = currentBid + 5; // Minimum bid increment
                        document.getElementById('bidAmount').value = (currentBid + 5).toFixed(2); // Default to minimum bid
                        
                        // Reset form state
                        document.getElementById('bidError').classList.add('d-none');
                        document.getElementById('confirmBid').checked = false;
                        
                        // Show the modal
                        new bootstrap.Modal(document.getElementById('bidModal')).show();
                        
                        // Handle form submission
                        document.getElementById('bidForm').onsubmit = function(e) {
                            e.preventDefault();
                            submitBid();
                        };
                    } else {
                        showError('Could not load auction information');
                    }
                })
                .catch(error => {
                    console.error('Error checking auction status:', error);
                    showError('Error checking auction status');
                });
        }
        
        function submitBid() {
            const auctionId = document.getElementById('bidArtworkId').value;
            const currentBid = parseFloat(document.getElementById('currentBid').value);
            const bidAmount = parseFloat(document.getElementById('bidAmount').value);
            const errorElement = document.getElementById('bidError');
            
            // Validate bid amount
            if (bidAmount <= currentBid) {
                errorElement.textContent = 'Your bid must be higher than the current bid.';
                errorElement.classList.remove('d-none');
                return;
            }
            
            if (bidAmount < currentBid + 5) {
                errorElement.textContent = 'Your bid must be at least RM 5.00 more than the current bid.';
                errorElement.classList.remove('d-none');
                return;
            }
            
            // Send bid to server
            async function sendBidRequest() {
                try {
                    // Get Firebase ID token for authentication
                    const user = firebase.auth().currentUser;
                    if (!user) {
                        throw new Error('User not authenticated');
                    }
                    
                    const idToken = await user.getIdToken();
                    console.log('Sending bid request with token:', idToken.substring(0, 20) + '...');
                    console.log('Bid amount:', bidAmount);
                    console.log('Auction ID:', auctionId);
                    
                    const response = await fetch('/api/auctions/' + auctionId + '/bid', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'Authorization': 'Bearer ' + idToken
                        },
                        body: JSON.stringify({
                            amount: bidAmount,
                            idToken: idToken
                        })
                    });
                    
                    console.log('Raw fetch response:', response);
                    return response;
                } catch (error) {
                    console.error('Error sending bid request:', error);
                    throw error;
                }
            }
            
            sendBidRequest()
            .then(response => {
                console.log('Bid response status:', response.status);
                console.log('Bid response headers:', response.headers);
                console.log('Bid response type:', response.type);
                console.log('Bid response ok:', response.ok);
                
                // Check if response is actually JSON
                const contentType = response.headers.get('content-type');
                console.log('Response content-type:', contentType);
                
                if (!response.ok) {
                    console.error('Response not ok, status:', response.status);
                    // Try to parse as JSON first
                    if (contentType && contentType.includes('application/json')) {
                        return response.json().then(data => {
                            throw new Error(data.error || data.message || `HTTP ${response.status}`);
                        });
                    } else {
                        return response.text().then(text => {
                            console.error('Error response body:', text);
                            throw new Error(`HTTP ${response.status}: ${text}`);
                        });
                    }
                }
                
                if (contentType && contentType.includes('application/json')) {
                    return response.json();
                } else {
                    return response.text().then(text => {
                        console.error('Expected JSON but got:', text);
                        throw new Error('Server returned non-JSON response');
                    });
                }
            })
            .then(data => {
                console.log('Bid response data:', data);
                
                if (data.success) {
                    // Close the bid modal
                    bootstrap.Modal.getInstance(document.getElementById('bidModal')).hide();
                    
                    // Show success message
                    alert('Your bid was placed successfully!');
                    
                    // Refresh the auctions to show updated bid
                    loadAuctions(currentPage);
                } else {
                    errorElement.textContent = data.error || data.message || 'Failed to place bid. Please try again.';
                    errorElement.classList.remove('d-none');
                }
            })
            .catch(error => {
                console.error('Error placing bid:', error);
                if (error.message.includes('Owners cannot bid')) {
                    errorElement.textContent = 'You are the seller — you cannot bid on your own auction.';
                } else {
                    errorElement.textContent = error.message || 'An error occurred. Please try again later.';
                }
                errorElement.classList.remove('d-none');
            });
        }
        
        function contactArtist(artistId, auctionId) {
            if (!firebase.auth().currentUser) {
                showError('Please log in to contact the artist');
                return;
            }
            
            // Redirect to messages page with artist ID and auction ID
            window.location.href = '/messages.jsp?artistId=' + artistId + '&auctionId=' + auctionId;
        }
        
        function showLoading(show) {
            document.getElementById('loadingSpinner').style.display = show ? 'block' : 'none';
        }
        
        function showError(message) {
            // You can implement a toast notification system here
            alert(message);
        }
        
        // Allow Enter key to trigger search
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                searchAuctions();
            }
        });
    </script>

    <!-- Login Modal -->
    <div class="modal fade" id="loginModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Login to ArtXchange</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="loginForm">
                        <div class="mb-3">
                            <label for="loginEmail" class="form-label">Email</label>
                            <input type="email" class="form-control" id="loginEmail" required>
                        </div>
                        <div class="mb-3">
                            <label for="loginPassword" class="form-label">Password</label>
                            <input type="password" class="form-control" id="loginPassword" required>
                        </div>
                        <div id="loginError" class="alert alert-danger d-none"></div>
                        <button type="submit" class="btn btn-primary w-100">Login</button>
                    </form>
                </div>
                <div class="modal-footer">
                    <p class="mb-0">Don't have an account? <a href="#" onclick="showRegisterModal()">Register here</a></p>
                </div>
            </div>
        </div>
    </div>

    <!-- Register Modal -->
    <div class="modal fade" id="registerModal" tabindex="-1">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Join ArtXchange</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body">
                    <form id="registerForm">
                        <div class="mb-3">
                            <label for="registerEmail" class="form-label">Email</label>
                            <input type="email" class="form-control" id="registerEmail" required>
                        </div>
                        <div class="mb-3">
                            <label for="registerPassword" class="form-label">Password</label>
                            <input type="password" class="form-control" id="registerPassword" required minlength="6">
                        </div>
                        <div class="mb-3">
                            <label for="registerName" class="form-label">Full Name</label>
                            <input type="text" class="form-control" id="registerName" required>
                        </div>
                        <div class="mb-3">
                            <div class="form-check">
                                <input class="form-check-input" type="checkbox" id="registerAsArtist">
                                <label class="form-check-label" for="registerAsArtist">
                                    Register as an Artist
                                </label>
                            </div>
                        </div>
                        <div id="registerError" class="alert alert-danger d-none"></div>
                        <button type="submit" class="btn btn-primary w-100">Register</button>
                    </form>
                </div>
                <div class="modal-footer">
                    <p class="mb-0">Already have an account? <a href="#" onclick="showLoginModal()">Login here</a></p>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
