<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Browse Artworks - ArtXchange</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/image-slider.css" rel="stylesheet">
    <style>
        .artist-profile-link {
            transition: all 0.2s ease;
        }
        .artist-profile-link:hover {
            text-decoration: underline !important;
        }
        .artist-profile-link .text-primary {
            transition: color 0.2s ease;
        }
        .artist-profile-link:hover .text-primary {
            color: #0056b3 !important;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark sticky-top" style="background: #1a1a1a; border-bottom: 1px solid rgba(255, 255, 255, 0.08);">
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/browse.jsp">Browse Art</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/auctions.jsp">Auctions</a>
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

    <!-- Filters Section -->
    <div class="container my-4">
        <div class="row">
            <div class="col-md-3">
                <div class="card">
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
                                <label class="form-label">Price Range (RM)</label>
                                <div class="row">
                                    <div class="col-6">
                                        <input type="number" class="form-control" id="minPrice" placeholder="Min">
                                    </div>
                                    <div class="col-6">
                                        <input type="number" class="form-control" id="maxPrice" placeholder="Max">
                                    </div>
                                </div>
                            </div>
                            
                            <!-- Listing Type -->
                            <div class="mb-3">
                                <label class="form-label">Listing Type</label>
                                <select class="form-select" id="listingTypeFilter">
                                    <option value="">All Types</option>
                                    <option value="FIXED_PRICE">Fixed Price</option>
                                    <option value="AUCTION">Auction</option>
                                </select>
                            </div>
                            
                            <!-- Availability Status -->
                            <div class="mb-3">
                                <label class="form-label">Availability</label>
                                <select class="form-select" id="statusFilter">
                                    <option value="">All (Available & Sold)</option>
                                    <option value="ACTIVE">Available Only</option>
                                    <option value="SOLD">Sold Only</option>
                                </select>
                            </div>
                            
                            <!-- Sort By -->
                            <div class="mb-3">
                                <label class="form-label">Sort By</label>
                                <select class="form-select" id="sortBy">
                                    <option value="newest">Newest First</option>
                                    <option value="oldest">Oldest First</option>
                                    <option value="price_low">Price: Low to High</option>
                                    <option value="price_high">Price: High to Low</option>
                                    <option value="popular">Most Popular</option>
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
                        <input type="text" class="form-control" id="searchInput" placeholder="Search artworks...">
                        <button class="btn btn-primary" type="button" onclick="searchArtworks()">
                            <i class="fas fa-search"></i>
                        </button>
                    </div>
                </div>
                
                <!-- Loading Spinner -->
                <div id="loadingSpinner" class="text-center my-5" style="display: none;">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2">Loading artworks...</p>
                </div>
                
                <!-- Artworks Grid -->
                <div id="artworksGrid" class="row">
                    <!-- Artworks will be loaded here via JavaScript -->
                </div>
                
                <!-- Pagination -->
                <nav aria-label="Artworks pagination" class="mt-4">
                    <ul class="pagination justify-content-center" id="pagination">
                        <!-- Pagination will be generated by JavaScript -->
                    </ul>
                </nav>
            </div>
        </div>
    </div>

    <!-- Artwork Modal -->
    <div class="modal fade" id="artworkModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="modalArtworkTitle">Artwork Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="modalArtworkContent">
                    <!-- Content will be populated by JavaScript -->
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
    <script src="${pageContext.request.contextPath}/assets/js/place-bid.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/image-slider.js"></script>
    <script>
        let currentPage = 1;
        let totalPages = 1;
        let currentFilters = {};
        let artworksData = []; // Store loaded artworks for reference
        
        // Helper function to get artwork data by ID
        function getCurrentArtworkData(artworkId) {
            return artworksData.find(artwork => 
                (artwork.artworkId || artwork.id) === artworkId
            );
        }
        
        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            initializeAuth();
            loadArtworks();
        });
        
        function loadArtworks(page = 1) {
            console.log('=== loadArtworks called ===');
            console.log('Page:', page);
            console.log('Current filters:', currentFilters);
            
            showLoading(true);
            
            // Build query parameters
            const params = new URLSearchParams({
                page: page,
                limit: 12,
                ...currentFilters
            });
            
            const url = window.location.origin + '/api/artworks?' + params;
            console.log('Request URL:', url);
            console.log('Request params:', Object.fromEntries(params));
            
            fetch(url)
                .then(response => {
                    console.log('Response status:', response.status);
                    return response.json();
                })
                .then(data => {
                    console.log('Response data:', data);
                    if (data.success) {
                        console.log('Number of artworks returned:', data.artworks ? data.artworks.length : 0);
                        if (data.artworks && data.artworks.length > 0) {
                            console.log('First few artworks prices:', 
                                       data.artworks.slice(0, 3).map(a => ({ 
                                           id: a.artworkId, 
                                           title: a.title, 
                                           price: a.price 
                                       })));
                        }
                        artworksData = data.artworks; // Store artworks data for reference
                        displayArtworks(data.artworks);
                        updatePagination(data.currentPage, data.totalPages);
                        currentPage = data.currentPage;
                        totalPages = data.totalPages;
                    } else {
                        console.error('API returned success=false:', data);
                        showError('Failed to load artworks');
                    }
                })
                .catch(error => {
                    console.error('Error loading artworks:', error);
                    showError('Error loading artworks');
                })
                .finally(() => {
                    showLoading(false);
                });
        }
        
        function displayArtworks(artworks) {
            const grid = document.getElementById('artworksGrid');
            
            if (artworks.length === 0) {
                grid.innerHTML = 
                    '<div class="col-12 text-center py-5">' +
                        '<i class="fas fa-paint-brush fa-3x text-muted mb-3"></i>' +
                        '<h4 class="text-muted">No artworks found</h4>' +
                        '<p class="text-muted">Try adjusting your search criteria</p>' +
                    '</div>';
                return;
            }
            
            // Sort artworks: ACTIVE first, then SOLD (within each group, maintain original order)
            artworks.sort((a, b) => {
                const statusA = a.status || '';
                const statusB = b.status || '';
                
                if (statusA === 'ACTIVE' && statusB === 'SOLD') {
                    return -1;
                } else if (statusA === 'SOLD' && statusB === 'ACTIVE') {
                    return 1;
                }
                return 0; // Same status, maintain order
            });
            
            // Apply client-side status filter if specified
            let filteredArtworks = artworks;
            const statusFilter = currentFilters.status;
            if (statusFilter) {
                filteredArtworks = artworks.filter(artwork => {
                    if (statusFilter === 'ACTIVE') {
                        return artwork.status !== 'SOLD';
                    } else if (statusFilter === 'SOLD') {
                        return artwork.status === 'SOLD';
                    }
                    return true;
                });
            }
            
            if (filteredArtworks.length === 0) {
                grid.innerHTML = 
                    '<div class="col-12 text-center py-5">' +
                        '<i class="fas fa-paint-brush fa-3x text-muted mb-3"></i>' +
                        '<h4 class="text-muted">No artworks found</h4>' +
                        '<p class="text-muted">Try adjusting your filters</p>' +
                    '</div>';
                return;
            }
            
            grid.innerHTML = filteredArtworks.map(artwork => {
                // Check if artwork is sold
                const isSold = artwork.status === 'SOLD';
                
                let statusBadge = '';
                if (isSold) {
                    statusBadge = '<div class="sold-badge"><i class="fas fa-check-circle me-1"></i>SOLD</div>';
                } else if (artwork.saleType === 'AUCTION') {
                    statusBadge = '<div class="badge bg-success position-absolute top-0 end-0 m-2"><i class="fas fa-gavel me-1"></i>Auction</div>';
                }
                let featuredBadge = '';
                if (artwork.isFeatured && !isSold) {
                    featuredBadge = '<div class="badge bg-warning position-absolute top-0 start-0 m-2"><i class="fas fa-star me-1"></i>Featured</div>';
                }
                let startingPriceText = '';
                if (!isSold && artwork.saleType === 'AUCTION' && artwork.startingBid !== artwork.currentBid && artwork.startingBid !== undefined && !isNaN(artwork.startingBid)) {
                    startingPriceText = '<small class="text-muted d-block">Starting: RM ' + (parseFloat(artwork.startingBid).toFixed(2)) + '</small>';
                }
                let auctionTimer = '';
                if (!isSold && artwork.saleType === 'AUCTION' && artwork.auctionEndTime) {
                    auctionTimer = '<div class="mt-2"><small class="text-muted"><i class="fas fa-clock me-1"></i><span class="auction-timer" data-end-time="' + artwork.auctionEndTime + '">Calculating...</span></small></div>';
                }
                // Display appropriate price based on sale type
                let displayPrice;
                if (isSold) {
                    // For sold artworks, show final price
                    if (artwork.saleType === 'AUCTION' && artwork.winningBidAmount) {
                        displayPrice = artwork.winningBidAmount;
                    } else {
                        displayPrice = artwork.price || 0;
                    }
                } else if (artwork.saleType === 'AUCTION') {
                    displayPrice = artwork.currentBid || artwork.startingBid || artwork.price || 0;
                } else {
                    displayPrice = artwork.price || 0;
                }
                let price = parseFloat(displayPrice);
                // Add compact bid control for auctions (only if not sold)
                let bidControl = '';
                if (!isSold && artwork.saleType === 'AUCTION') {
                    bidControl = '<div class="mt-2" id="bidControl-' + artwork.artworkId + '" onclick="event.stopPropagation();"></div>';
                }
                
                // Add sold overlay class if sold
                const cardClass = isSold ? 'card artwork-card h-100 sold-overlay' : 'card artwork-card h-100';
                // Allow clicking on sold artworks to view details, but disable interactions
                const onClickHandler = 'onclick="showArtworkModal(\'' + artwork.artworkId + '\')"';
                
                return '<div class="col-md-4 mb-4">' +
                    '<div class="' + cardClass + '" ' + onClickHandler + '>' +
                        '<div class="position-relative">' +
                            '<img src="' + (artwork.primaryImageUrl || artwork.imageUrl || '/assets/images/placeholder-artwork.jpg') + '" ' +
                                 'class="card-img-top artwork-image" alt="' + artwork.title + '">' +
                            statusBadge +
                            featuredBadge +
                        '</div>' +
                        '<div class="card-body">' +
                            '<h5 class="card-title">' + artwork.title + '</h5>' +
                            '<p class="card-text text-muted small">by ' + 
                                (artwork.artistId ? 
                                    '<a href="/profile.jsp?userId=' + artwork.artistId + '" class="text-decoration-none text-muted" onclick="event.stopPropagation();" title="View artist profile">' +
                                    (artwork.artistName || 'Unknown Artist') + 
                                    '</a>' : 
                                    (artwork.artistName || 'Unknown Artist')) + 
                            '</p>' +
                            '<p class="card-text">' + (artwork.description ? artwork.description.substring(0, 100) + (artwork.description.length > 100 ? '...' : '') : '') + '</p>' +
                            '<div class="d-flex justify-content-between align-items-center">' +
                                '<div>' +
                                    (isSold ? 
                                        '<strong class="text-danger">Sold: RM ' + price.toFixed(2) + '</strong>' +
                                        (artwork.saleType === 'AUCTION' && artwork.winnerName ? '<br><small class="text-muted">Won by ' + artwork.winnerName + '</small>' : '') :
                                        (artwork.saleType === 'AUCTION' && artwork.currentBid ?
                                            '<strong class="text-success">Current Bid: RM ' + price.toFixed(2) + '</strong>' :
                                            '<strong class="text-primary">RM ' + price.toFixed(2) + '</strong>')) +
                                    (isSold ? '' : startingPriceText) +
                                '</div>' +
                                '<div class="text-end">' +
                                    '<button class="btn btn-sm btn-outline-primary" ' + (isSold ? 'disabled' : 'onclick="event.stopPropagation(); toggleLike(\'' + artwork.artworkId + '\')"') + '>' +
                                        '<i class="fas fa-heart ' + (artwork.isLiked ? 'text-danger' : '') + '"></i>' +
                                        '<span class="like-count">' + (artwork.likeCount || artwork.likes || 0) + '</span>' +
                                    '</button>' +
                                '</div>' +
                            '</div>' +
                            // Add Buy Now button for fixed price artworks (not sold, not owner)
                            (!isSold && artwork.saleType === 'FIXED_PRICE' && (!currentUser || currentUser.userId !== artwork.artistId) ?
                                '<div class="mt-2">' +
                                    '<button class="btn btn-primary btn-sm w-100" onclick="event.stopPropagation(); buyNow(\'' + artwork.artworkId + '\')">' +
                                        '<i class="fas fa-shopping-cart me-1"></i>Buy Now' +
                                    '</button>' +
                                '</div>' : '') +
                            (isSold ? '' : auctionTimer) +
                            (isSold ? '' : bidControl) +
                        '</div>' +
                    '</div>' +
                '</div>';
            }).join('');
            
            // Initialize auction timers
            initializeAuctionTimers();
            
            // Initialize PlaceBid components for auction artworks
            initializePlaceBidComponents(artworks);
        }
        
        // Store PlaceBid component instances
        const placeBidComponents = new Map();
        
        // Initialize PlaceBid components for auction artworks
        function initializePlaceBidComponents(artworks) {
            artworks.forEach(artwork => {
                if (artwork.saleType === 'AUCTION') {
                    const container = document.getElementById('bidControl-' + artwork.artworkId);
                    if (container) {
                        // Determine auction status - check both end time and status field
                        let auctionStatus = 'ACTIVE';
                        const now = new Date();
                        
                        // Check if status field indicates ended/canceled
                        if (artwork.status === 'ENDED' || artwork.status === 'CANCELED' || artwork.status === 'INACTIVE') {
                            auctionStatus = artwork.status === 'CANCELED' ? 'CANCELED' : 'ENDED';
                        } 
                        // Check if end time has passed
                        else if (artwork.auctionEndTime) {
                            const endTime = new Date(artwork.auctionEndTime);
                            if (endTime <= now) {
                                auctionStatus = 'ENDED';
                            }
                        }
                        
                        // If auction has ended, show "Auction Ended" label instead of Place Bid button
                        if (auctionStatus === 'ENDED' || auctionStatus === 'CANCELED') {
                            container.innerHTML = 
                                '<div class="mt-2">' +
                                    '<button class="btn btn-sm btn-secondary w-100" disabled>' +
                                        '<i class="fas fa-times-circle me-1"></i>' +
                                        (auctionStatus === 'CANCELED' ? 'Auction Canceled' : 'Auction Ended') +
                                    '</button>' +
                                '</div>';
                            return; // Don't create PlaceBid component for ended auctions
                        }
                        
                        const component = new PlaceBid({
                            auctionId: artwork.artworkId,
                            startingPrice: artwork.startingBid || artwork.price || 0,
                            currentHighestBid: artwork.currentBid || artwork.currentHighestBid || null,
                            minIncrement: artwork.minIncrement || 10.00,
                            auctionStatus: auctionStatus,
                            endsAt: artwork.auctionEndTime || artwork.endTime || null,
                            artistId: artwork.artistId || null, // Pass artistId to prevent self-bidding
                            container: container,
                            compact: true,
                            onSuccess: (bidData) => {
                                console.log('Bid placed successfully:', bidData);
                                // Update the displayed current bid in the card
                                const card = container.closest('.artwork-card');
                                if (card) {
                                    const bidDisplay = card.querySelector('.text-success, .text-primary');
                                    if (bidDisplay) {
                                        bidDisplay.textContent = 'Current Bid: RM ' + bidData.bidAmount.toFixed(2);
                                        bidDisplay.classList.remove('text-primary');
                                        bidDisplay.classList.add('text-success');
                                    }
                                }
                            },
                            onError: (error) => {
                                console.error('Bid error:', error);
                            },
                            onUpdate: (updateData) => {
                                console.log('Auction updated:', updateData);
                                // Update the displayed current bid in the card
                                const card = container.closest('.artwork-card');
                                if (card) {
                                    const bidDisplay = card.querySelector('.text-success, .text-primary');
                                    if (bidDisplay) {
                                        bidDisplay.textContent = 'Current Bid: RM ' + updateData.currentHighestBid.toFixed(2);
                                        bidDisplay.classList.remove('text-primary');
                                        bidDisplay.classList.add('text-success');
                                    }
                                }
                                // If auction ended, update the UI
                                if (updateData.auctionStatus === 'ENDED' || updateData.auctionStatus === 'CANCELED') {
                                    container.innerHTML = 
                                        '<div class="mt-2">' +
                                            '<button class="btn btn-sm btn-secondary w-100" disabled>' +
                                                '<i class="fas fa-times-circle me-1"></i>' +
                                                (updateData.auctionStatus === 'CANCELED' ? 'Auction Canceled' : 'Auction Ended') +
                                            '</button>' +
                                        '</div>';
                                    placeBidComponents.delete(artwork.artworkId);
                                }
                            }
                        });
                        
                        placeBidComponents.set(artwork.artworkId, component);
                    }
                }
            });
        }
        
        function initializeAuctionTimers() {
            document.querySelectorAll('.auction-timer').forEach(timer => {
                const endTime = new Date(timer.dataset.endTime);
                updateTimer(timer, endTime);
                
                // Update every second
                setInterval(() => updateTimer(timer, endTime), 1000);
            });
        }
        
        function updateTimer(element, endTime) {
            const now = new Date();
            const timeLeft = endTime - now;
            
            if (timeLeft <= 0) {
                element.textContent = 'Auction ended';
                element.classList.add('text-danger');
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
                    '<a class="page-link" href="#" onclick="loadArtworks(' + (currentPage - 1) + ')">' +
                        '<i class="fas fa-chevron-left"></i>' +
                    '</a>' +
                '</li>';
            
            // Page numbers
            const startPage = Math.max(1, currentPage - 2);
            const endPage = Math.min(totalPages, currentPage + 2);
            
            if (startPage > 1) {
                paginationHTML += '<li class="page-item"><a class="page-link" href="#" onclick="loadArtworks(1)">1</a></li>';
                if (startPage > 2) {
                    paginationHTML += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                }
            }
            
            for (let i = startPage; i <= endPage; i++) {
                paginationHTML +=
                    '<li class="page-item ' + (i === currentPage ? 'active' : '') + '">' +
                        '<a class="page-link" href="#" onclick="loadArtworks(' + i + ')">' + i + '</a>' +
                    '</li>';
            }
            
            if (endPage < totalPages) {
                if (endPage < totalPages - 1) {
                    paginationHTML += '<li class="page-item disabled"><span class="page-link">...</span></li>';
                }
                paginationHTML += '<li class="page-item"><a class="page-link" href="#" onclick="loadArtworks(' + totalPages + ')">' + totalPages + '</a></li>';
            }
            
            // Next button
            paginationHTML += 
                '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
                    '<a class="page-link" href="#" onclick="loadArtworks(' + (currentPage + 1) + ')">' +
                        '<i class="fas fa-chevron-right"></i>' +
                    '</a>' +
                '</li>';
            
            pagination.innerHTML = paginationHTML;
        }
        
        function applyFilters() {
            console.log('=== applyFilters called ===');
            
            currentFilters = {
                category: document.getElementById('categoryFilter').value,
                minPrice: document.getElementById('minPrice').value,
                maxPrice: document.getElementById('maxPrice').value,
                listingType: document.getElementById('listingTypeFilter').value,
                status: document.getElementById('statusFilter').value,
                sortBy: document.getElementById('sortBy').value,
                search: document.getElementById('searchInput').value
            };
            
            console.log('Raw filters:', currentFilters);
            
            // Remove empty filters
            Object.keys(currentFilters).forEach(key => {
                if (!currentFilters[key]) {
                    delete currentFilters[key];
                }
            });
            
            console.log('Cleaned filters:', currentFilters);
            console.log('Calling loadArtworks with filters...');
            
            loadArtworks(1);
        }
        
        function clearFilters() {
            document.getElementById('filterForm').reset();
            document.getElementById('searchInput').value = '';
            currentFilters = {};
            loadArtworks(1);
        }
        
        function searchArtworks() {
            applyFilters();
        }
        
        function showArtworkModal(artworkId) {
            // Fetch artwork details and show modal
            fetch(window.location.origin + '/api/artworks/' + artworkId)
                .then(response => response.json())
                .then(data => {
                    if (data.success && data.artwork) {
                        // Ensure artistId is available (fallback to createdBy if needed)
                        if (!data.artwork.artistId && data.artwork.createdBy) {
                            data.artwork.artistId = data.artwork.createdBy;
                        }
                        displayArtworkModal(data.artwork);
                    } else {
                        console.error('Invalid artwork data:', data);
                    }
                })
                .catch(error => {
                    console.error('Error loading artwork details:', error);
                });
        }
        
        function initializeModalSlider(artwork) {
            if (typeof ImageSlider === 'undefined') {
                console.warn('ImageSlider not loaded');
                return;
            }
            
            let images = [];
            if (artwork.imageUrls && Array.isArray(artwork.imageUrls) && artwork.imageUrls.length > 0) {
                images = artwork.imageUrls;
            } else if (artwork.primaryImageUrl) {
                images = [artwork.primaryImageUrl];
            } else {
                images = ['/assets/images/placeholder-artwork.jpg'];
            }
            
            const sliderContainer = document.getElementById('modalArtworkImageSlider');
            if (sliderContainer) {
                // Destroy existing slider if any
                if (sliderContainer._sliderInstance) {
                    sliderContainer._sliderInstance.destroy();
                }
                
                const slider = new ImageSlider('modalArtworkImageSlider', images, {
                    showThumbnails: images.length > 1,
                    showArrows: images.length > 1,
                    showIndicators: images.length > 1,
                    autoPlay: false
                });
                
                sliderContainer._sliderInstance = slider;
            }
        }
        
        function displayArtworkModal(artwork) {
            document.getElementById('modalArtworkTitle').textContent = artwork.title;
            document.getElementById('modalArtworkContent').innerHTML = generateModalContent(artwork);
            
            // Initialize image slider in modal after DOM is ready
            setTimeout(function() {
                initializeModalSlider(artwork);
            }, 100);
            
            // Initialize timer for modal
            initializeAuctionTimers();
            
            // Show modal with proper instance handling
            const modalElement = document.getElementById('artworkModal');
            const existingModal = bootstrap.Modal.getInstance(modalElement);
            
            if (existingModal) {
                existingModal.dispose();
            }
            
            const newModal = new bootstrap.Modal(modalElement);
            newModal.show();
        }
        
        function toggleLike(artworkId) {
            if (!isLoggedIn()) {
                showError('Please log in to like artworks');
                return;
            }
            
            fetch(window.location.origin + '/api/artworks/' + artworkId + '/like', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update like button in UI
                    updateLikeButton(artworkId, data.liked, data.likeCount);
                }
            })
            .catch(error => {
                console.error('Error toggling like:', error);
            });
        }
        
        function updateLikeButton(artworkId, liked, likeCount) {
            // Find all like buttons for this artwork and update them
            document.querySelectorAll('[onclick*="' + artworkId + '"]').forEach(button => {
                const heartIcon = button.querySelector('.fas.fa-heart');
                const countSpan = button.querySelector('.like-count');
                
                if (heartIcon) {
                    heartIcon.className = 'fas fa-heart ' + (liked ? 'text-danger' : '');
                }
                if (countSpan) {
                    countSpan.textContent = likeCount;
                }
            });
        }
        
        function showLoading(show) {
            document.getElementById('loadingSpinner').style.display = show ? 'block' : 'none';
        }
        
        function showError(message) {
            // You can implement a toast notification system here
            alert(message);
        }
        
        // Buy Now function for fixed price artworks
        function buyNow(artworkId) {
            if (!artworkId) {
                console.warn('buyNow called without artworkId');
                return;
            }
            
            // Check if artwork is sold
            const currentArtwork = getCurrentArtworkData(artworkId);
            if (currentArtwork && currentArtwork.status === 'SOLD') {
                showError('This artwork has already been sold');
                return;
            }
            
            if (!isLoggedIn()) {
                const message = 'Please login to purchase artwork';
                // Try to use showInfoMessage if available, otherwise use alert
                if (typeof showInfoMessage === 'function') {
                    showInfoMessage(message);
                } else {
                    alert(message);
                }
                // Try to show login modal if available
                if (typeof showLoginModal === 'function') {
                    showLoginModal();
                }
                return;
            }
            
            if (currentUser && currentArtwork && currentUser.userId === currentArtwork.artistId) {
                showError('You cannot purchase your own artwork');
                return;
            }
            
            // Check if it's a fixed price artwork
            if (currentArtwork && currentArtwork.saleType !== 'FIXED_PRICE') {
                showError('This artwork is not available for direct purchase');
                return;
            }
            
            window.location.href = window.location.origin + '/checkout/' + artworkId;
        }
        
        function placeBid(artworkId) {
            // Check if user is authenticated
            if (!isLoggedIn()) {
                alert('Please login to place a bid');
                window.location.href = window.location.origin + '/index.jsp';
                return;
            }
            
            // Frontend check: Prevent artist from bidding on their own artwork
            const currentArtwork = getCurrentArtworkData(artworkId);
            if (currentUser && currentArtwork && currentUser.userId === currentArtwork.artistId) {
                alert('You are the seller — you cannot bid on your own auction.');
                return;
            }
            
            // Check if auction has ended
            let isAuctionEnded = false;
            if (currentArtwork.status === 'ENDED' || currentArtwork.status === 'CANCELED' || currentArtwork.status === 'INACTIVE') {
                isAuctionEnded = true;
            } else if (currentArtwork.auctionEndTime) {
                const endTime = new Date(currentArtwork.auctionEndTime);
                if (endTime <= new Date()) {
                    isAuctionEnded = true;
                }
            }
            
            if (isAuctionEnded) {
                alert('This auction has ended. Bidding is no longer available.');
                return;
            }
            
            // Get the current bid or starting bid
            const currentBidValue = currentArtwork.currentBid || currentArtwork.startingBid || currentArtwork.price;
            const currentBid = parseFloat(currentBidValue) || 0;
            const minBidAmount = currentBid + 1; // Minimum increment of 1
            
            console.log('Current artwork:', currentArtwork);
            console.log('Current bid value:', currentBidValue);
            console.log('Current bid (parsed):', currentBid);
            console.log('Min bid amount:', minBidAmount);
            
            const bidAmount = prompt(`Enter your bid amount (minimum: ${minBidAmount} ${currentArtwork.currency || 'MYR'}):`);
            if (bidAmount && !isNaN(bidAmount) && parseFloat(bidAmount) >= minBidAmount) {
                // Get Firebase ID token for authentication
                firebaseAuth.currentUser.getIdToken()
                    .then(idToken => {
                        return fetch(window.location.origin + '/api/artworks/' + artworkId + '/bid', {
                            method: 'POST',
                            headers: {
                                'Content-Type': 'application/json',
                                'Authorization': 'Bearer ' + idToken
                            },
                            body: JSON.stringify({
                                amount: parseFloat(bidAmount)
                            })
                        });
                    })
                    .then(response => {
                        if (!response.ok) {
                            return response.json().then(data => {
                                throw new Error(data.error || data.message || 'Failed to place bid');
                            });
                        }
                        return response.json();
                    })
                    .then(data => {
                        if (data.success) {
                            alert('Bid placed successfully!');
                            // Refresh modal content without creating new modal
                            refreshModalContent(artworkId);
                        } else {
                            alert('Bid failed: ' + (data.error || data.message || 'Unknown error'));
                        }
                    })
                    .catch(error => {
                        console.error('Bid error:', error);
                        if (error.message.includes('Owners cannot bid')) {
                            alert('You are the seller — you cannot bid on your own auction.');
                        } else {
                            alert('Bid failed: ' + error.message);
                        }
                    });
            } else if (bidAmount) {
                alert(`Invalid bid amount. Please enter a valid amount greater than or equal to ${minBidAmount} ${currentArtwork.currency || 'MYR'}.`);
            }
        }
        
        function contactArtist(artistId, artworkId) {
            console.log('contactArtist called with artistId:', artistId, 'type:', typeof artistId);
            console.log('contactArtist called with artworkId:', artworkId, 'type:', typeof artworkId);
            
            // Check if user is authenticated
            if (!isLoggedIn()) {
                alert('Please login to contact the artist');
                window.location.href = '/index.jsp';
                return;
            }
            
            // Check if user is trying to contact themselves
            if (currentUser && currentUser.userId === artistId) {
                alert('You cannot contact yourself');
                return;
            }
            
            // Redirect to messages page with artist and artwork context
            const redirectUrl = '/messages.jsp?artistId=' + artistId + '&artworkId=' + artworkId;
            console.log('Redirecting to:', redirectUrl);
            window.location.href = redirectUrl;
        }
        
        function refreshModalContent(artworkId) {
            // Check if modal is currently open
            const modalElement = document.getElementById('artworkModal');
            const modalInstance = bootstrap.Modal.getInstance(modalElement);
            
            if (modalInstance && modalElement.classList.contains('show')) {
                // Modal is open, refresh the content
                const artwork = getCurrentArtworkData(artworkId);
                if (artwork) {
                    // Update the modal content
                    document.getElementById('modalArtworkTitle').textContent = artwork.title;
                    document.getElementById('modalArtworkContent').innerHTML = generateModalContent(artwork);
                    
                    // Reinitialize image slider
                    setTimeout(function() {
                        initializeModalSlider(artwork);
                    }, 100);
                    
                    // Reinitialize auction timers
                    initializeAuctionTimers();
                }
            }
        }
        
        function generateModalContent(artwork) {
            // Check if artwork is sold
            const isSold = artwork.status === 'SOLD';
            
            // Extract the modal content generation logic
            let auctionTimer = '';
            if (!isSold && artwork.saleType === 'AUCTION' && artwork.auctionEndTime) {
                auctionTimer = '<div class="mt-3"><small class="text-muted"><i class="fas fa-clock me-1"></i>Auction ends: <span class="auction-timer fw-bold" data-end-time="' + artwork.auctionEndTime + '">Calculating...</span></small></div>';
            }
            
            // Check if auction has ended
            let isAuctionEnded = false;
            let auctionEndedLabel = '';
            if (artwork.saleType === 'AUCTION') {
                if (isSold) {
                    isAuctionEnded = true;
                    auctionEndedLabel = 'Sold';
                } else if (artwork.status === 'ENDED' || artwork.status === 'CANCELED' || artwork.status === 'INACTIVE') {
                    isAuctionEnded = true;
                    auctionEndedLabel = artwork.status === 'CANCELED' ? 'Auction Canceled' : 'Auction Ended';
                } else if (artwork.auctionEndTime) {
                    const endTime = new Date(artwork.auctionEndTime);
                    if (endTime <= new Date()) {
                        isAuctionEnded = true;
                        auctionEndedLabel = 'Auction Ended';
                    }
                }
            }
            
            // Price display logic
            let priceDisplay = '';
            if (isSold) {
                // Show sold status and final price
                if (artwork.saleType === 'AUCTION' && artwork.winningBidAmount) {
                    priceDisplay = '<div class="alert alert-danger mb-3"><i class="fas fa-check-circle me-2"></i><strong>SOLD</strong></div>';
                    priceDisplay += '<h4 class="text-danger mb-1">Final Price: ' + (artwork.currency || 'MYR') + ' ' + parseFloat(artwork.winningBidAmount).toFixed(2) + '</h4>';
                    if (artwork.winnerName) {
                        priceDisplay += '<small class="text-muted">Won by: ' + artwork.winnerName + '</small>';
                    }
                } else {
                    priceDisplay = '<div class="alert alert-danger mb-3"><i class="fas fa-check-circle me-2"></i><strong>SOLD</strong></div>';
                    priceDisplay += '<h4 class="text-danger mb-1">Sold Price: ' + (artwork.currency || 'MYR') + ' ' + parseFloat(artwork.price || 0).toFixed(2) + '</h4>';
                }
            } else if (artwork.saleType === 'AUCTION') {
                if (artwork.currentBid && artwork.currentBid > (artwork.startingBid || artwork.price)) {
                    priceDisplay = '<h4 class="text-success mb-1">Current Bid: ' + (artwork.currency || 'MYR') + ' ' + parseFloat(artwork.currentBid).toFixed(2) + '</h4>';
                    priceDisplay += '<small class="text-muted">Starting bid: ' + (artwork.currency || 'MYR') + ' ' + parseFloat(artwork.startingBid || artwork.price).toFixed(2) + '</small>';
                } else {
                    priceDisplay = '<h4 class="text-warning mb-1">Starting Bid: ' + (artwork.currency || 'MYR') + ' ' + parseFloat(artwork.startingBid || artwork.price).toFixed(2) + '</h4>';
                    priceDisplay += '<small class="text-muted">No bids yet</small>';
                }
                if (artwork.bidCount > 0) {
                    priceDisplay += '<div class="mt-2"><small class="text-info"><i class="fas fa-gavel me-1"></i>' + artwork.bidCount + ' bid(s) placed</small></div>';
                }
            } else {
                priceDisplay = '<h4 class="text-primary mb-1">Price: ' + (artwork.currency || 'MYR') + ' ' + parseFloat(artwork.price).toFixed(2) + '</h4>';
            }
            
            // Build action button HTML - disabled for sold artworks
            let actionButton = '';
            if (!isSold && !(currentUser && currentUser.userId === artwork.artistId)) {
                if (artwork.saleType === 'FIXED_PRICE') {
                    actionButton = '<button class="btn btn-primary btn-lg" onclick="buyNow(\'' + (artwork.artworkId || artwork.id) + '\')">' +
                                       '<i class="fas fa-shopping-cart me-2"></i>Buy Now' +
                                   '</button>';
                } else if (artwork.saleType === 'AUCTION') {
                    if (isAuctionEnded) {
                        actionButton = '<button class="btn btn-secondary btn-lg" disabled>' +
                                           '<i class="fas fa-times-circle me-2"></i>' + auctionEndedLabel +
                                       '</button>';
                    } else {
                        actionButton = '<button class="btn btn-warning btn-lg" onclick="placeBid(\'' + (artwork.artworkId || artwork.id) + '\')">' +
                                           '<i class="fas fa-gavel me-2"></i>Place Bid' +
                                       '</button>';
                    }
                }
            } else if (isSold) {
                actionButton = '<button class="btn btn-secondary btn-lg" disabled>' +
                                   '<i class="fas fa-times-circle me-2"></i>Sold - No Longer Available' +
                               '</button>';
            }
            
            // Build contact button HTML - still allow contact even for sold artworks
            let contactButton = '';
            if (!(currentUser && currentUser.userId === artwork.artistId)) {
                contactButton = '<button class="btn btn-outline-primary" onclick="contactArtist(\'' + artwork.artistId + '\', \'' + (artwork.artworkId || artwork.id) + '\')">' +
                                    '<i class="fas fa-envelope me-2"></i>Contact Artist' +
                                '</button>';
            }
            
            // Prepare images array for slider
            let images = [];
            if (artwork.imageUrls && Array.isArray(artwork.imageUrls) && artwork.imageUrls.length > 0) {
                images = artwork.imageUrls;
            } else if (artwork.primaryImageUrl) {
                images = [artwork.primaryImageUrl];
            } else {
                images = ['/assets/images/placeholder-artwork.jpg'];
            }
            
            return '<div class="row">' +
                '<div class="col-md-6">' +
                    '<div id="modalArtworkImageSlider" style="min-height: 400px;"></div>' +
                '</div>' +
                '<div class="col-md-6">' +
                    '<div class="mb-3">' +
                        '<h6 class="mb-1">' +
                            'by ' + 
                            ((artwork.artistId || artwork.createdBy) ? 
                                '<a href="#" class="text-decoration-none artist-profile-link" onclick="viewArtistProfile(\'' + (artwork.artistId || artwork.createdBy) + '\'); return false;" title="View artist profile">' +
                                    '<span class="text-primary">' + (artwork.artistName || 'Unknown Artist') + '</span>' +
                                    ' <i class="fas fa-external-link-alt" style="font-size: 0.7em;"></i>' +
                                '</a>' : 
                                '<span class="text-muted">' + (artwork.artistName || 'Unknown Artist') + '</span>') +
                        '</h6>' +
                        priceDisplay +
                        auctionTimer +
                    '</div>' +
                    '<div class="mb-3">' +
                        '<h6>Description</h6>' +
                        '<p class="text-muted">' + (artwork.description || 'No description available') + '</p>' +
                    '</div>' +
                    '<div class="mb-3">' +
                        '<small class="text-muted d-block"><i class="fas fa-tag me-1"></i>Category: ' + (artwork.category || 'Unknown') + '</small>' +
                        '<small class="text-muted d-block"><i class="fas fa-eye me-1"></i>Views: ' + (artwork.views || 0) + '</small>' +
                        '<small class="text-muted d-block"><i class="fas fa-heart me-1"></i>Likes: ' + (artwork.likes || 0) + '</small>' +
                        (artwork.yearCreated ? '<small class="text-muted d-block"><i class="fas fa-calendar me-1"></i>Year: ' + artwork.yearCreated + '</small>' : '') +
                    '</div>' +
                    '<div class="d-grid gap-2">' +
                        actionButton +
                        contactButton +
                    '</div>' +
                '</div>' +
            '</div>';
        }
        
        function viewArtistProfile(artistId) {
            // Close the modal first
            const modalElement = document.getElementById('artworkModal');
            const modalInstance = bootstrap.Modal.getInstance(modalElement);
            if (modalInstance) {
                modalInstance.hide();
            }
            
            // Navigate to artist profile page after a short delay to allow modal to close smoothly
            setTimeout(function() {
                window.location.href = '/profile.jsp?userId=' + artistId;
            }, 300);
        }
        
        function closeModal() {
            const modalElement = document.getElementById('artworkModal');
            const modalInstance = bootstrap.Modal.getInstance(modalElement);
            
            if (modalInstance) {
                modalInstance.hide();
            }
            
            // Clean up any remaining backdrops
            setTimeout(() => {
                const backdrops = document.querySelectorAll('.modal-backdrop');
                backdrops.forEach(backdrop => backdrop.remove());
                document.body.classList.remove('modal-open');
                document.body.style.removeProperty('overflow');
                document.body.style.removeProperty('padding-right');
            }, 300);
        }
        
        // Add event listener for modal close
        document.addEventListener('DOMContentLoaded', function() {
            const modalElement = document.getElementById('artworkModal');
            modalElement.addEventListener('hidden.bs.modal', function() {
                // Clean up any remaining backdrops
                const backdrops = document.querySelectorAll('.modal-backdrop');
                backdrops.forEach(backdrop => backdrop.remove());
                document.body.classList.remove('modal-open');
                document.body.style.removeProperty('overflow');
                document.body.style.removeProperty('padding-right');
            });
        });
    </script>

    <!-- Login Modal -->
    <div class="modal fade" id="loginModal" tabindex="-1" aria-labelledby="loginModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="loginModalLabel">Login to ArtXchange</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <div id="login-form-container">
                        <form id="login-form">
                            <div class="mb-3">
                                <label for="loginEmail" class="form-label">Email</label>
                                <input type="email" class="form-control" id="loginEmail" required>
                            </div>
                            <div class="mb-3">
                                <label for="loginPassword" class="form-label">Password</label>
                                <input type="password" class="form-control" id="loginPassword" required>
                            </div>
                            <button type="submit" class="btn btn-primary w-100 mb-3">Sign In</button>
                        </form>
                        <div class="text-center">
                            <small class="text-muted">
                                Don't have an account? 
                                <a href="#" onclick="showRegisterModal()">Register here</a>
                            </small>
                        </div>
                    </div>
                    <div id="login-loading" class="text-center d-none">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Signing in...</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Register Modal -->
    <div class="modal fade" id="registerModal" tabindex="-1" aria-labelledby="registerModalLabel" aria-hidden="true">
        <div class="modal-dialog">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title" id="registerModalLabel">Join ArtXchange</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body">
                    <form id="register-form">
                        <div class="mb-3">
                            <label for="registerEmail" class="form-label">Email</label>
                            <input type="email" class="form-control" id="registerEmail" required>
                        </div>
                        <div class="mb-3">
                            <label for="registerPassword" class="form-label">Password</label>
                            <input type="password" class="form-control" id="registerPassword" required>
                            <div class="form-text">Password must be at least 6 characters long</div>
                        </div>
                        <div class="mb-3">
                            <label for="confirmPassword" class="form-label">Confirm Password</label>
                            <input type="password" class="form-control" id="confirmPassword" required>
                        </div>
                        <div class="mb-3">
                            <label for="username" class="form-label">Username</label>
                            <input type="text" class="form-control" id="username" required>
                        </div>
                        <div class="mb-3">
                            <label for="firstName" class="form-label">First Name</label>
                            <input type="text" class="form-control" id="firstName" required>
                        </div>
                        <div class="mb-3">
                            <label for="lastName" class="form-label">Last Name</label>
                            <input type="text" class="form-control" id="lastName" required>
                        </div>
                        <div class="mb-3">
                            <label for="role" class="form-label">I am a</label>
                            <select class="form-select" id="role" required>
                                <option value="">Select your role</option>
                                <option value="BUYER">Art Buyer/Collector</option>
                                <option value="ARTIST">Artist</option>
                            </select>
                        </div>
                        <button type="submit" class="btn btn-primary w-100 mb-3">Create Account</button>
                    </form>
                    
                    <div class="text-center">
                        <small class="text-muted">
                            Already have an account? 
                            <a href="#" onclick="showLoginModal()">Login here</a>
                        </small>
                    </div>
                    
                    <div id="register-loading" class="text-center d-none">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Creating account...</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
