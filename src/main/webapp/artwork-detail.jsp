<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.artexchange.model.Artwork" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>

<%
    Artwork artwork = (Artwork) request.getAttribute("artwork");
    if (artwork == null) {
        response.sendRedirect(request.getContextPath() + "/browse.jsp");
        return;
    }
    
    // Create reference to enum for easier comparison
    Artwork.SaleType auctionType = Artwork.SaleType.AUCTION;
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><%=artwork.getTitle()%> - ArtXchange</title>
    
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Font Awesome -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">
    
    <!-- Custom CSS -->
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/image-slider.css">
    
    <style>
        .artwork-detail-image {
            max-height: 600px;
            object-fit: contain;
            width: 100%;
        }
        
        .artist-avatar {
            width: 50px;
            height: 50px;
            object-fit: cover;
        }
        
        .auction-timer {
            font-size: 1.1em;
            font-weight: bold;
        }
        
        .bid-history {
            max-height: 300px;
            overflow-y: auto;
        }
        
        .artwork-stats {
            background: #f8f9fa;
            padding: 1rem;
            border-radius: 0.5rem;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp">
                <i class="fas fa-palette me-2"></i>ArtXchange
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/browse.jsp">Browse</a>
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
                    <li class="nav-item d-none" id="user-menu">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            <img id="userAvatar" src="" alt="User" class="rounded-circle me-2" width="30" height="30">
                            <span id="user-name">User</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile.jsp">Profile</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/messages.jsp">Messages</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#" onclick="logout()">Logout</a></li>
                        </ul>
                    </li>
                    <li class="nav-item" id="login-nav">
                        <a class="nav-link" href="#" onclick="showLoginModal()">Login</a>
                    </li>
                    <li class="nav-item d-none" id="register-nav">
                        <a class="nav-link" href="#" onclick="showRegisterModal()">Register</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Main Content -->
    <div class="container mt-5 pt-4">
        <!-- Breadcrumb -->
        <nav aria-label="breadcrumb" class="mb-4">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/index.jsp">Home</a></li>
                <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/browse.jsp">Browse</a></li>
                <li class="breadcrumb-item active"><%=artwork.getTitle()%></li>
            </ol>
        </nav>

        <div class="row">
            <!-- Artwork Image -->
            <div class="col-md-8">
                <div class="card">
                    <div class="card-body">
                        <!-- Image Slider -->
                        <div id="artworkImageSlider"></div>
                    </div>
                </div>
                
                <!-- Artwork Description -->
                <div class="card mt-4">
                    <div class="card-header">
                        <h5><i class="fas fa-info-circle me-2"></i>Description</h5>
                    </div>
                    <div class="card-body">
                        <p><%=artwork.getDescription()%></p>
                        
                        <!-- Artwork Stats -->
                        <div class="artwork-stats mt-4">
                            <div class="row text-center">
                                <div class="col-4">
                                    <h6 class="text-primary"><%=artwork.getViews()%></h6>
                                    <small class="text-muted">Views</small>
                                </div>
                                <div class="col-4">
                                    <h6 class="text-primary"><%=artwork.getLikes()%></h6>
                                    <small class="text-muted">Likes</small>
                                </div>
                                <div class="col-4">
                                    <h6 class="text-primary"><%=artwork.getCategory()%></h6>
                                    <small class="text-muted">Category</small>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Artwork Details & Actions -->
            <div class="col-md-4">
                <!-- Artwork Info -->
                <div class="card">
                    <div class="card-header">
                        <h5><%=artwork.getTitle()%></h5>
                        <% if (artwork.getStatus() == com.artexchange.model.Artwork.ArtworkStatus.SOLD) { %>
                            <span class="badge bg-danger"><i class="fas fa-times-circle me-1"></i>Sold</span>
                        <% } else if (artwork.getStatus() == com.artexchange.model.Artwork.ArtworkStatus.ACTIVE) { %>
                            <span class="badge bg-success"><i class="fas fa-check-circle me-1"></i>Available</span>
                        <% } else { %>
                            <span class="badge bg-secondary"><i class="fas fa-info-circle me-1"></i><%=artwork.getStatus()%></span>
                        <% } %>
                    </div>
                    <div class="card-body">
                        <!-- Artist Info -->
                        <div class="d-flex align-items-center mb-3">
                            <% if (artwork.getArtistId() != null && !artwork.getArtistId().trim().isEmpty()) { %>
                                <a href="${pageContext.request.contextPath}/profile.jsp?userId=<%=artwork.getArtistId()%>" 
                                   class="text-decoration-none d-flex align-items-center">
                                    <img src="${pageContext.request.contextPath}/assets/images/default-avatar.svg" 
                                         alt="Artist" class="artist-avatar rounded-circle me-3"
                                         id="artistAvatarImg"
                                         onerror="this.src='${pageContext.request.contextPath}/assets/images/default-avatar.svg';">
                                    <div>
                                        <h6 class="mb-0 text-dark">
                                            <%=artwork.getArtistName() != null && !artwork.getArtistName().trim().isEmpty() ? artwork.getArtistName() : "Artist"%>
                                            <i class="fas fa-external-link-alt ms-1" style="font-size: 0.7em;"></i>
                                        </h6>
                                        <small class="text-muted">View Artist Profile</small>
                                    </div>
                                </a>
                            <% } else { %>
                                <img src="${pageContext.request.contextPath}/assets/images/default-avatar.svg" 
                                     alt="Artist" class="artist-avatar rounded-circle me-3">
                                <div>
                                    <h6 class="mb-0"><%=artwork.getArtistName() != null && !artwork.getArtistName().trim().isEmpty() ? artwork.getArtistName() : "Unknown Artist"%></h6>
                                    <small class="text-muted">Professional Artist</small>
                                </div>
                            <% } %>
                        </div>
                        
                        <!-- Price Info -->
                        <div class="mb-4">
                            <% if (artwork.getSaleType() == auctionType) { %>
                                <% if (artwork.getStatus() == com.artexchange.model.Artwork.ArtworkStatus.SOLD && 
                                       artwork.getWinnerId() != null && !artwork.getWinnerId().trim().isEmpty()) { %>
                                    <!-- Auction Ended - Show Winner -->
                                    <div class="alert alert-success">
                                        <h6 class="mb-2"><i class="fas fa-trophy me-2"></i>Auction Ended</h6>
                                        <p class="mb-1"><strong>Winner:</strong> 
                                            <%= artwork.getWinnerName() != null ? artwork.getWinnerName() : "Unknown Bidder" %> 
                                            - RM <%=String.format("%.2f", artwork.getWinningBidAmount() != null ? artwork.getWinningBidAmount().doubleValue() : 0.0)%>
                                        </p>
                                        <% if (artwork.getEndedAt() != null) { %>
                                            <small class="text-muted">
                                                <i class="fas fa-clock me-1"></i>
                                                Ended: <%= artwork.getEndedAt().toString().replace("T", " ") %>
                                            </small>
                                        <% } %>
                                    </div>
                                <% } else { %>
                                    <!-- Active Auction -->
                                    <h4 class="text-primary mb-1">
                                        RM <%=String.format("%.2f", artwork.getCurrentBid() != null ? artwork.getCurrentBid().doubleValue() : artwork.getStartingBid().doubleValue())%>
                                    </h4>
                                    <small class="text-muted">Current Bid</small>
                                    <% if (artwork.getStartingBid() != null) { %>
                                        <br><small class="text-muted">Starting: RM <%=String.format("%.2f", artwork.getStartingBid().doubleValue())%></small>
                                    <% } %>
                                    
                                    <!-- Auction Timer -->
                                    <div class="mt-2">
                                        <small class="text-muted">
                                            <i class="fas fa-clock me-1"></i>
                                            <span class="auction-timer" id="auctionTimer">Calculating...</span>
                                        </small>
                                    </div>
                                <% } %>
                            <% } else { %>
                                <h4 class="text-primary mb-1">RM <%=String.format("%.2f", artwork.getPrice().doubleValue())%></h4>
                                <small class="text-muted">Fixed Price</small>
                            <% } %>
                        </div>
                        
                        <!-- Action Buttons -->
                        <div class="d-grid gap-2">
                            <% if (artwork.getStatus() == com.artexchange.model.Artwork.ArtworkStatus.SOLD) { %>
                                <button class="btn btn-secondary btn-lg" disabled>
                                    <i class="fas fa-ban me-2"></i>Sold Out
                                </button>
                                <div class="alert alert-info mt-2 mb-0">
                                    <small><i class="fas fa-info-circle me-1"></i>This artwork has been sold.</small>
                                </div>
                            <% } else if (artwork.getSaleType() == auctionType) { %>
                                <!-- Place Bid Component Container -->
                                <div id="placeBidContainer-<%=artwork.getArtworkId()%>"></div>
                            <% } else { %>
                                <a class="btn btn-success btn-lg" 
                                   href="${pageContext.request.contextPath}/checkout/<%=artwork.getArtworkId()%>"
                                   onclick="return buyNow(event, '<%=artwork.getArtworkId()%>')">
                                    <i class="fas fa-shopping-cart me-2"></i>Buy Now
                                </a>
                            <% } %>
                            
                            <button class="btn btn-outline-primary" onclick="toggleLike('<%=artwork.getArtworkId()%>')">
                                <i class="far fa-heart me-2"></i>Add to Favorites
                            </button>
                            
                            <button class="btn btn-outline-secondary" onclick="contactArtist('<%=artwork.getArtistId()%>', '<%=artwork.getArtworkId()%>')">
                                <i class="fas fa-envelope me-2"></i>Contact Artist
                            </button>
                        </div>
                        
                        <!-- Shipping Info -->
                        <div class="mt-4 p-3 bg-light rounded">
                            <h6><i class="fas fa-truck me-2"></i>Shipping</h6>
                            <small class="text-muted">
                                <% if (artwork.isShippingAvailable()) { %>
                                    <i class="fas fa-check text-success me-1"></i>Ships worldwide
                                <% } else { %>
                                    <i class="fas fa-times text-danger me-1"></i>Local pickup only
                                <% } %>
                            </small>
                        </div>
                    </div>
                </div>
                
                <!-- Bid History (for auctions) -->
                <% if (artwork.getSaleType() == auctionType) { %>
                    <div class="card mt-4">
                        <div class="card-header">
                            <h6><i class="fas fa-history me-2"></i>Bid History</h6>
                        </div>
                        <div class="card-body">
                            <div class="bid-history" id="bidHistory">
                                <!-- Bid history will be loaded here -->
                                <div class="text-center text-muted">
                                    <i class="fas fa-spinner fa-spin"></i> Loading bid history...
                                </div>
                            </div>
                        </div>
                    </div>
                <% } %>
            </div>
        </div>
    </div>


    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Firebase Authentication -->
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/firebase-config.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/place-bid.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/image-slider.js"></script>
    
    <script>
        // Artwork data from server
        const artworkData = {
            id: '<%=artwork.getArtworkId()%>',
            saleType: '<%=artwork.getSaleType()%>',
            artistId: '<%=artwork.getArtistId() != null ? artwork.getArtistId() : ""%>',
            auctionEndTime: '<%=artwork.getAuctionEndTime() != null ? artwork.getAuctionEndTime() : ""%>'
        };
        const checkoutPageUrl = '${pageContext.request.contextPath}/checkout/';
        
        // PlaceBid component instance
        let placeBidComponent = null;
        
        // Load artist profile picture if artistId is available
        async function loadArtistProfile() {
            if (!artworkData.artistId) return;
            
            try {
                const response = await fetch('/api/users/' + artworkData.artistId, {
                    credentials: 'include',
                    headers: {
                        'Accept': 'application/json'
                    }
                });
                
                if (response.ok) {
                    const result = await response.json();
                    if (result.success && result.data && result.data.user) {
                        const artist = result.data.user;
                        const avatarImg = document.getElementById('artistAvatarImg');
                        if (avatarImg && artist.profileImage) {
                            let avatarUrl = artist.profileImage;
                            // Strip context path if present
                            const contextPath = window.location.pathname.split('/')[1] || '';
                            if (contextPath && avatarUrl.startsWith('/' + contextPath + '/')) {
                                avatarUrl = avatarUrl.substring(contextPath.length + 1);
                            }
                            if (!avatarUrl.startsWith('/')) {
                                avatarUrl = '/' + avatarUrl;
                            }
                            avatarImg.src = avatarUrl;
                            avatarImg.onerror = function() {
                                this.src = '${pageContext.request.contextPath}/assets/images/default-avatar.svg';
                            };
                        }
                    }
                }
            } catch (error) {
                console.log('Could not load artist profile:', error);
            }
        }
        
        // Initialize page
        document.addEventListener('DOMContentLoaded', function() {
            initializeAuth();
            loadBidHistory();
            checkBidButtonVisibility();
            loadArtistProfile(); // Load artist profile picture
            
            // Initialize PlaceBid component for auctions
            if (artworkData.saleType === 'AUCTION') {
                initializePlaceBidComponent();
            }
        });
        
        // Initialize PlaceBid component
        async function initializePlaceBidComponent() {
            try {
                // Fetch auction data
                const response = await fetch('/api/artworks/' + artworkData.id, {
                    credentials: 'include'
                });
                const data = await response.json();
                const artwork = data.artwork || data;
                
                if (artwork) {
                    const container = document.getElementById('placeBidContainer-' + artworkData.id);
                    if (container) {
                        placeBidComponent = new PlaceBid({
                            auctionId: artworkData.id,
                            startingPrice: artwork.startingBid || artwork.price || 0,
                            currentHighestBid: artwork.currentBid || artwork.currentHighestBid || null,
                            minIncrement: artwork.minIncrement || 10.00,
                            auctionStatus: artwork.status || (artwork.auctionEndTime && new Date(artwork.auctionEndTime) > new Date() ? 'ACTIVE' : 'ENDED'),
                            endsAt: artwork.auctionEndTime || artwork.endTime || null,
                            container: container,
                            compact: false,
                            onSuccess: (bidData) => {
                                console.log('Bid placed successfully:', bidData);
                                // Reload bid history
                                loadBidHistory();
                            },
                            onError: (error) => {
                                console.error('Bid error:', error);
                            },
                            onUpdate: (updateData) => {
                                console.log('Auction updated:', updateData);
                                // Reload bid history if needed
                                loadBidHistory();
                            }
                        });
                    }
                }
            } catch (error) {
                console.error('Error initializing PlaceBid component:', error);
            }
        }
        
        // Check if current user is the artist and disable bid button
        function checkBidButtonVisibility() {
            // Wait for auth to initialize
            setTimeout(function() {
                if (artworkData.saleType === 'AUCTION' && currentUser && artworkData.artistId) {
                    if (currentUser.userId === artworkData.artistId) {
                        // User is the artist - disable bid button
                        const bidButton = document.querySelector('button[onclick*="placeBid"]');
                        if (bidButton) {
                            bidButton.disabled = true;
                            bidButton.classList.remove('btn-primary');
                            bidButton.classList.add('btn-secondary');
                            bidButton.innerHTML = '<i class="fas fa-ban me-2"></i>You are the seller — you cannot bid on your own auction';
                            
                            // Add tooltip or message
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
            }, 500); // Wait for auth.js to load currentUser
        }
        
        // Load bid history for auctions
        function loadBidHistory() {
            if (artworkData.saleType === 'AUCTION') {
                fetch('/api/artworks/' + artworkData.id + '/bids')
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            displayBidHistory(data.bids);
                        } else {
                            document.getElementById('bidHistory').innerHTML = '<p class="text-muted">No bids yet</p>';
                        }
                    })
                    .catch(error => {
                        console.error('Error loading bid history:', error);
                        document.getElementById('bidHistory').innerHTML = '<p class="text-muted">Error loading bid history</p>';
                    });
            }
        }
        
        function displayBidHistory(bids) {
            const bidHistory = document.getElementById('bidHistory');
            if (bids.length === 0) {
                bidHistory.innerHTML = '<p class="text-muted">No bids yet</p>';
                return;
            }
            
            bidHistory.innerHTML = bids.map(bid => 
                '<div class="d-flex justify-content-between align-items-center mb-2">' +
                    '<div>' +
                        '<strong>RM ' + bid.amount.toFixed(2) + '</strong>' +
                        '<br><small class="text-muted">' + new Date(bid.timestamp).toLocaleString() + '</small>' +
                    '</div>' +
                    '<small class="text-muted">Bidder #' + bid.bidderId.substring(0, 6) + '</small>' +
                '</div>'
            ).join('');
        }
        
        // Initialize auction timer
        function initializeAuctionTimer(endTime) {
            const timer = document.getElementById('auctionTimer');
            const endDate = new Date(endTime);
            
            function updateTimer() {
                const now = new Date();
                const timeLeft = endDate - now;
                
                if (timeLeft <= 0) {
                    timer.textContent = 'Auction Ended';
                    timer.className = 'auction-timer text-danger';
                    return;
                }
                
                const days = Math.floor(timeLeft / (1000 * 60 * 60 * 24));
                const hours = Math.floor((timeLeft % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                const minutes = Math.floor((timeLeft % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((timeLeft % (1000 * 60)) / 1000);
                
                timer.textContent = days + 'd ' + hours + 'h ' + minutes + 'm ' + seconds + 's';
            }
            
            updateTimer();
            setInterval(updateTimer, 1000);
        }
        
        // Legacy placeBid function - kept for backward compatibility
        // The PlaceBid component handles bid placement now
        function placeBid(artworkId) {
            // This function is kept for compatibility but should not be used
            // The PlaceBid component handles all bid placement
            console.warn('placeBid() is deprecated. Use PlaceBid component instead.');
        }
        
        // Buy now function
        function buyNow(event, artworkId) {
            if (event) {
                event.preventDefault();
            }
            
            // Check if artwork is sold
            const soldBadge = document.querySelector('.badge.bg-danger');
            if (soldBadge && soldBadge.textContent.includes('Sold')) {
                showInfoMessage('This artwork has already been sold.');
                return false;
            }
            
            if (!isLoggedIn()) {
                showInfoMessage('Please login to purchase artwork');
                showLoginModal();
                return false;
            }
            
            window.location.href = checkoutPageUrl + artworkId;
            return false;
        }
        
        // Toggle like function
        function toggleLike(artworkId) {
            if (!isLoggedIn()) {
                showInfoMessage('Please login to like artwork');
                showLoginModal();
                return;
            }
            
            fetch('/api/artworks/' + artworkId + '/like', {
                method: 'POST'
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    // Update like button state
                    console.log('Like toggled successfully');
                } else {
                    console.error('Error toggling like:', data.message);
                }
            })
            .catch(error => {
                console.error('Error toggling like:', error);
            });
        }
        
        // Contact artist function
        function contactArtist(artistId, artworkId) {
            if (!isLoggedIn()) {
                showInfoMessage('Please login to contact the artist');
                showLoginModal();
                return;
            }
            
            // Redirect to messages page with artist and artwork context
            window.location.href = '/messages.jsp?artistId=' + artistId + '&artworkId=' + artworkId;
        }
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

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/firebase-config.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/image-slider.js"></script>
    <script>
        // Initialize image slider
        document.addEventListener('DOMContentLoaded', function() {
            <%
                java.util.List<String> imageUrls = artwork.getImageUrls();
                if (imageUrls == null || imageUrls.isEmpty()) {
                    // Fallback to primary image
                    String primaryUrl = artwork.getPrimaryImageUrl();
                    if (primaryUrl == null || primaryUrl.isEmpty()) {
                        primaryUrl = request.getContextPath() + "/assets/images/placeholder-artwork.jpg";
                    }
                    imageUrls = new java.util.ArrayList<>();
                    imageUrls.add(primaryUrl);
                }
            %>
            
            const images = [
                <% for (int i = 0; i < imageUrls.size(); i++) { %>
                    '<%= imageUrls.get(i) %>'<%= i < imageUrls.size() - 1 ? "," : "" %>
                <% } %>
            ];
            
            if (images.length > 0) {
                new ImageSlider('artworkImageSlider', images, {
                    showThumbnails: true,
                    showArrows: true,
                    showIndicators: true,
                    autoPlay: false
                });
            }
        });
    </script>
</body>
</html>
