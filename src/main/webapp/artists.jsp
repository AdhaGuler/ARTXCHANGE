<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Featured Artists - ArtXchange</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
    <style>
        /* Black & White Minimalist Theme */
        .artist-card {
            transition: box-shadow 0.2s ease, border-color 0.2s ease;
            border: 1px solid #f0f0f0;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            background: #ffffff;
        }
        .artist-card:hover {
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            border-color: #e0e0e0;
        }
        .artist-avatar {
            width: 120px;
            height: 120px;
            object-fit: cover;
            border: 2px solid #f0f0f0;
            box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
        }
        .portfolio-thumbnail {
            width: 80px;
            height: 80px;
            object-fit: cover;
            border-radius: 0;
            border: 1px solid #f0f0f0;
        }
        .stats-badge {
            background: #f8f9fa;
            color: #1a1a1a;
            border: 1px solid #e0e0e0;
            border-radius: 0;
            padding: 4px 12px;
            font-size: 0.8rem;
            margin: 2px;
            font-weight: 500;
        }
        .featured-banner {
            background: #ffffff;
            color: #1a1a1a;
            text-align: center;
            padding: 60px 0 40px;
            margin-bottom: 0;
            border-bottom: 1px solid #e0e0e0;
        }
        .featured-banner h1 {
            color: #1a1a1a;
            font-weight: 300;
            letter-spacing: -0.02em;
        }
        .featured-banner .lead {
            color: #666;
            font-weight: 400;
        }
        .featured-banner i {
            color: #1a1a1a;
        }
        .search-section {
            background-color: #ffffff;
            padding: 30px 0;
            margin-bottom: 40px;
            border-bottom: 1px solid #f0f0f0;
        }
        .search-section .card {
            border: 1px solid #e0e0e0;
            border-radius: 0;
            box-shadow: none;
        }
        .search-section .input-group-text {
            background: #ffffff;
            border: 1px solid #e0e0e0;
            border-right: none;
            color: #666;
        }
        .search-section .form-control,
        .search-section .form-select {
            border: 1px solid #e0e0e0;
            border-radius: 0;
            color: #1a1a1a;
        }
        .search-section .form-control:focus,
        .search-section .form-select:focus {
            border-color: #1a1a1a;
            box-shadow: 0 0 0 2px rgba(26, 26, 26, 0.1);
            outline: none;
        }
        .search-section .form-control::placeholder {
            color: #999;
        }
        .verified-badge {
            color: #666 !important;
        }
        .btn-outline-primary-custom {
            border: 1px solid #1a1a1a;
            color: #1a1a1a;
            background: transparent;
            border-radius: 0;
            padding: 8px 16px;
            font-weight: 500;
            transition: background-color 0.2s ease, color 0.2s ease, border-color 0.2s ease;
        }
        .btn-outline-primary-custom:hover {
            background: #1a1a1a;
            color: #ffffff;
            border-color: #1a1a1a;
        }
        .btn-primary-custom {
            background: #1a1a1a;
            color: #ffffff;
            border: 1px solid #1a1a1a;
            border-radius: 0;
            padding: 8px 16px;
            font-weight: 500;
            transition: background-color 0.2s ease, border-color 0.2s ease;
        }
        .btn-primary-custom:hover {
            background: #333;
            border-color: #333;
            color: #ffffff;
        }
        .card-footer {
            background: #ffffff;
            border-top: 1px solid #f0f0f0;
        }
        .spinner-border {
            border-color: #e0e0e0;
            border-top-color: #1a1a1a;
        }
        .pagination .page-link {
            color: #1a1a1a;
            border: 1px solid #e0e0e0;
            border-radius: 0;
            padding: 8px 16px;
            transition: background-color 0.2s ease, border-color 0.2s ease, color 0.2s ease;
        }
        .pagination .page-link:hover {
            background: #f8f9fa;
            border-color: #1a1a1a;
            color: #1a1a1a;
        }
        .pagination .page-item.active .page-link {
            background: #1a1a1a;
            border-color: #1a1a1a;
            color: #ffffff;
        }
        .pagination .page-item.disabled .page-link {
            color: #999;
            background: #f8f9fa;
            border-color: #e0e0e0;
            cursor: not-allowed;
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
                        <a class="nav-link active" href="${pageContext.request.contextPath}/artists.jsp">Artists</a>
                    </li>
                </ul>
                
                <ul class="navbar-nav">
                    <li class="nav-item dropdown d-none" id="user-menu">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            <img id="userAvatar" src="" alt="User" class="rounded-circle me-2" width="30" height="30">
                            <span id="user-name">User</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile.jsp"><i class="fas fa-user me-2"></i>My Profile</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/dashboard.jsp"><i class="fas fa-tachometer-alt me-2"></i>Artist Dashboard</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/messages.jsp"><i class="fas fa-envelope me-2"></i>Messages</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#" onclick="logout()"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                        </ul>
                    </li>
                    <li class="nav-item" id="auth-buttons">
                        <a class="nav-link" href="#" onclick="showLoginModal()">Login</a>
                        <a class="nav-link" href="#" onclick="showRegisterModal()">Register</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Featured Artists Banner -->
    <div class="featured-banner">
        <div class="container">
            <h1 class="display-4 fw-light mb-3">
                <i class="fas fa-users me-3"></i>Featured Artists Directory
            </h1>
            <p class="lead">Discover talented artists and their incredible portfolios</p>
            <div class="mt-4">
                <button class="btn btn-outline-primary-custom btn-lg me-3" onclick="window.location.href='${pageContext.request.contextPath}/dashboard.jsp'">
                    <i class="fas fa-palette me-2"></i>Artist Dashboard
                </button>
                <button class="btn btn-primary-custom btn-lg" onclick="window.location.href='${pageContext.request.contextPath}/browse.jsp'">
                    <i class="fas fa-images me-2"></i>Browse Artworks
                </button>
            </div>
        </div>
    </div>

    <!-- Search and Filter Section -->
    <div class="search-section">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-md-8">
                    <div class="card">
                        <div class="card-body">
                            <div class="row align-items-center">
                                <div class="col-md-6">
                                    <div class="input-group">
                                        <span class="input-group-text">
                                            <i class="fas fa-search"></i>
                                        </span>
                                        <input type="text" class="form-control" id="searchInput" 
                                               placeholder="Search artists by name or style...">
                                    </div>
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select" id="specialtyFilter">
                                        <option value="">All Specialties</option>
                                        <option value="PAINTING">Painting</option>
                                        <option value="SCULPTURE">Sculpture</option>
                                        <option value="PHOTOGRAPHY">Photography</option>
                                        <option value="DIGITAL_ART">Digital Art</option>
                                        <option value="MIXED_MEDIA">Mixed Media</option>
                                    </select>
                                </div>
                                <div class="col-md-3">
                                    <select class="form-select" id="sortBy">
                                        <option value="featured">Featured</option>
                                        <option value="name">Name A-Z</option>
                                        <option value="newest">Newest</option>
                                        <option value="popular">Most Popular</option>
                                    </select>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Artists Grid -->
    <div class="container mb-5">
        <div class="row" id="artistsGrid">
            <!-- Artists will be loaded here -->
        </div>
        
        <!-- Loading Spinner -->
        <div class="text-center my-5" id="loadingSpinner">
            <div class="spinner-border" role="status">
                <span class="visually-hidden">Loading artists...</span>
            </div>
        </div>
        
        <!-- No Results Message -->
        <div class="text-center my-5 d-none" id="noResults">
            <i class="fas fa-search text-muted" style="font-size: 4rem;"></i>
            <h3 class="text-muted mt-3">No artists found</h3>
            <p class="text-muted">Try adjusting your search criteria</p>
        </div>
    </div>

    <!-- Pagination -->
    <div class="container mb-5">
        <nav aria-label="Artists pagination">
            <ul class="pagination justify-content-center" id="pagination">
                <!-- Pagination will be generated here -->
            </ul>
        </nav>
    </div>

    <!-- Artist Profile Modal -->
    <div class="modal fade" id="artistModal" tabindex="-1">
        <div class="modal-dialog modal-lg">
            <div class="modal-content">
                <div class="modal-header">
                    <h5 class="modal-title">Artist Profile</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>
                <div class="modal-body" id="artistModalBody">
                    <!-- Artist details will be loaded here -->
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-outline-primary-custom" data-bs-dismiss="modal">Close</button>
                    <button type="button" class="btn btn-primary-custom" id="viewPortfolioBtn">View Full Portfolio</button>
                </div>
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
    
    <script>
        let currentPage = 1;
        let totalPages = 1;
        let isLoading = false;
        
        // Store real artists data from API
        let allArtists = [];

        document.addEventListener('DOMContentLoaded', function() {
            initializeAuth();
            loadArtists();
            setupEventListeners();
        });

        function setupEventListeners() {
            // Search input - debounced to prevent excessive filtering
            const searchInput = document.getElementById('searchInput');
            if (searchInput) {
                // Single input listener with debounce (300ms delay)
                searchInput.addEventListener('input', debounce(filterArtists, 300));
            }
            
            // Filter dropdowns
            const specialtyFilter = document.getElementById('specialtyFilter');
            if (specialtyFilter) {
                specialtyFilter.addEventListener('change', filterArtists);
            }
            
            const sortBy = document.getElementById('sortBy');
            if (sortBy) {
                sortBy.addEventListener('change', filterArtists);
            }
            
            // Listen for authentication state changes
            if (typeof firebase !== 'undefined' && firebase.auth) {
                firebase.auth().onAuthStateChanged(function(user) {
                    console.log('Auth state changed:', user ? 'logged in' : 'logged out');
                });
            }
        }

        function debounce(func, wait) {
            let timeout;
            return function executedFunction(...args) {
                const later = function() {
                    clearTimeout(timeout);
                    func(...args);
                };
                clearTimeout(timeout);
                timeout = setTimeout(later, wait);
            };
        }

        /**
         * Load artists from backend API
         * Fetches real artist data from database only
         */
        function loadArtists() {
            if (isLoading) return;
            
            isLoading = true;
            showLoadingSpinner();
            
            // Fetch real artists from backend API
            fetch('/api/artists')
                .then(response => {
                    if (!response.ok) {
                        throw new Error('Failed to fetch artists: ' + response.status);
                    }
                    return response.json();
                })
                .then(data => {
                    if (data.success && data.artists) {
                        // Store real artists data
                        allArtists = data.artists;
                        
                        // Apply filters and display
                        const filteredArtists = filterAndSortArtists();
                        displayArtists(filteredArtists);
                        updatePagination(filteredArtists.length);
                    } else {
                        allArtists = [];
                        displayArtists([]);
                        updatePagination(0);
                    }
                })
                .catch(error => {
                    allArtists = [];
                    displayArtists([]);
                    updatePagination(0);
                })
                .finally(() => {
                    hideLoadingSpinner();
                    isLoading = false;
                });
        }

        /**
         * Filter and sort artists from real data
         * Works with artists fetched from backend API
         * Optimized for performance - no console logs in render loop
         */
        function filterAndSortArtists() {
            // Start with all real artists from database
            let filtered = [...allArtists];
            
            // Apply search filter - case-insensitive partial match
            const searchInput = document.getElementById('searchInput');
            const searchTerm = searchInput ? searchInput.value.trim().toLowerCase() : '';
            
            if (searchTerm) {
                filtered = filtered.filter(artist => {
                    const nameMatch = artist.name && artist.name.toLowerCase().includes(searchTerm);
                    const usernameMatch = artist.username && artist.username.toLowerCase().includes(searchTerm);
                    const bioMatch = artist.bio && artist.bio.toLowerCase().includes(searchTerm);
                    const locationMatch = artist.location && artist.location.toLowerCase().includes(searchTerm);
                    
                    return nameMatch || usernameMatch || bioMatch || locationMatch;
                });
            }
            
            // Apply specialty filter (if implemented in backend)
            const specialtyFilter = document.getElementById('specialtyFilter');
            const specialty = specialtyFilter ? specialtyFilter.value : '';
            if (specialty) {
                filtered = filtered.filter(artist => artist.specialty === specialty);
            }
            
            // Apply sorting
            const sortBySelect = document.getElementById('sortBy');
            const sortBy = sortBySelect ? sortBySelect.value : 'featured';
            switch (sortBy) {
                case 'name':
                    filtered.sort((a, b) => {
                        const nameA = (a.name || '').toLowerCase();
                        const nameB = (b.name || '').toLowerCase();
                        return nameA.localeCompare(nameB);
                    });
                    break;
                case 'newest':
                    filtered.sort((a, b) => {
                        const dateA = a.joinDate ? new Date(a.joinDate) : new Date(0);
                        const dateB = b.joinDate ? new Date(b.joinDate) : new Date(0);
                        return dateB - dateA;
                    });
                    break;
                case 'popular':
                    filtered.sort((a, b) => {
                        const followersA = a.followersCount || 0;
                        const followersB = b.followersCount || 0;
                        return followersB - followersA;
                    });
                    break;
                case 'featured':
                default:
                    filtered.sort((a, b) => {
                        const ratingA = a.rating || 0;
                        const ratingB = b.rating || 0;
                        return ratingB - ratingA;
                    });
                    break;
            }
            
            return filtered;
        }

        /**
         * Display artists or show empty state
         * Optimized rendering using DocumentFragment for better performance
         */
        function displayArtists(artists) {
            const grid = document.getElementById('artistsGrid');
            const noResults = document.getElementById('noResults');
            
            if (artists.length === 0) {
                grid.innerHTML = '';
                
                // Check if this is initial load (no search/filter) or filtered result
                const searchInput = document.getElementById('searchInput');
                const hasSearchTerm = searchInput && searchInput.value.trim().length > 0;
                const specialtyFilter = document.getElementById('specialtyFilter');
                const hasFilter = specialtyFilter && specialtyFilter.value;
                
                if (hasSearchTerm || hasFilter) {
                    // Show "no results" message for filtered search
                    noResults.querySelector('h3').textContent = 'No artists found';
                    noResults.querySelector('p').textContent = 'Try adjusting your search criteria';
                } else {
                    // Show empty state for no artists in database
                    noResults.querySelector('h3').textContent = 'No artists available yet';
                    noResults.querySelector('p').textContent = 'Be the first to register as an artist.';
                }
                
                noResults.classList.remove('d-none');
                return;
            }
            
            noResults.classList.add('d-none');
            
            // Use DocumentFragment for efficient DOM updates
            const fragment = document.createDocumentFragment();
            const tempDiv = document.createElement('div');
            tempDiv.innerHTML = artists.map(artist => createArtistCard(artist)).join('');
            
            // Move all children to fragment
            while (tempDiv.firstChild) {
                fragment.appendChild(tempDiv.firstChild);
            }
            
            // Single DOM update
            grid.innerHTML = '';
            grid.appendChild(fragment);
        }

        /**
         * Create artist card HTML from real artist data
         */
        function createArtistCard(artist) {
            const verifiedBadge = artist.verified ? '<i class="fas fa-check-circle verified-badge ms-1"></i>' : '';
            const avatarUrl = artist.avatar || '${pageContext.request.contextPath}/assets/images/default-avatar.png';
            const artistName = artist.name || artist.username || 'Unknown Artist';
            const artistBio = artist.bio || 'No bio available.';
            const artistLocation = artist.location || 'Location not specified';
            const artworksCount = artist.artworksCount || 0;
            const followersCount = artist.followersCount || 0;
            const rating = artist.rating || 0;
            const artistId = artist.id || artist.userId;
            
            // Portfolio thumbnails with lazy loading
            let portfolioThumbnails = '';
            if (artist.portfolio && artist.portfolio.length > 0) {
                portfolioThumbnails = artist.portfolio.slice(0, 3).map(img => 
                    '<img src="' + img + '" alt="Portfolio" class="portfolio-thumbnail me-1" loading="lazy">'
                ).join('');
            }
            
            return '<div class="col-lg-4 col-md-6 mb-4">' +
                '<div class="card artist-card h-100">' +
                    '<div class="card-body text-center">' +
                        '<img src="' + avatarUrl + '" alt="' + artistName + '" class="rounded-circle artist-avatar mb-3" loading="lazy" onerror="this.src=\'${pageContext.request.contextPath}/assets/images/default-avatar.png\'">' +
                        '<h5 class="card-title" style="color: #1a1a1a;">' + artistName + verifiedBadge + '</h5>' +
                        '<p class="text-muted mb-2">Artist</p>' +
                        '<p class="text-muted small mb-3">' +
                            '<i class="fas fa-map-marker-alt me-1"></i>' + artistLocation +
                        '</p>' +
                        '<p class="card-text text-muted small mb-3">' + artistBio + '</p>' +
                        '<div class="mb-3">' +
                            '<span class="stats-badge">' +
                                '<i class="fas fa-images me-1"></i>' + artworksCount + ' works' +
                            '</span>' +
                            '<span class="stats-badge">' +
                                '<i class="fas fa-users me-1"></i>' + followersCount + ' followers' +
                            '</span>' +
                            (rating > 0 ? '<span class="stats-badge">' +
                                '<i class="fas fa-star me-1"></i>' + rating.toFixed(1) +
                            '</span>' : '') +
                        '</div>' +
                        (portfolioThumbnails ? '<div class="mb-3">' + portfolioThumbnails + '</div>' : '') +
                    '</div>' +
                    '<div class="card-footer bg-transparent">' +
                        '<button class="btn btn-outline-primary-custom btn-sm me-2" onclick="viewArtistProfile(\'' + artistId + '\')">' +
                            '<i class="fas fa-user me-1"></i>View Profile' +
                        '</button>' +
                        '<button class="btn btn-primary-custom btn-sm" onclick="window.location.href=\'${pageContext.request.contextPath}/profile.jsp?userId=' + artistId + '\'">' +
                            '<i class="fas fa-images me-1"></i>Portfolio' +
                        '</button>' +
                    '</div>' +
                '</div>' +
            '</div>';
        }

        /**
         * Get specialty label (kept for compatibility, but specialty may not be in API response)
         */
        function getSpecialtyLabel(specialty) {
            if (!specialty) return 'Artist';
            const labels = {
                'PAINTING': 'Painter',
                'SCULPTURE': 'Sculptor',
                'PHOTOGRAPHY': 'Photographer',
                'DIGITAL_ART': 'Digital Artist',
                'MIXED_MEDIA': 'Mixed Media Artist'
            };
            return labels[specialty] || specialty;
        }

        /**
         * View artist profile modal
         * Uses real artist data from API
         */
        function viewArtistProfile(artistId) {
            const artist = allArtists.find(a => (a.id === artistId || a.userId === artistId));
            if (!artist) {
                return;
            }
            
            const modalBody = document.getElementById('artistModalBody');
            const verifiedBadge = artist.verified ? '<i class="fas fa-check-circle verified-badge ms-2"></i>' : '';
            const avatarUrl = artist.avatar || '${pageContext.request.contextPath}/assets/images/default-avatar.png';
            const artistName = artist.name || artist.username || 'Unknown Artist';
            const artistBio = artist.bio || 'No bio available.';
            const artistLocation = artist.location || 'Location not specified';
            const artworksCount = artist.artworksCount || 0;
            const followersCount = artist.followersCount || 0;
            const rating = artist.rating || 0;
            const joinDate = artist.joinDate || '';
            
            // Portfolio images with lazy loading
            let portfolioHtml = '';
            if (artist.portfolio && artist.portfolio.length > 0) {
                portfolioHtml = artist.portfolio.map(img => 
                    '<img src="' + img + '" alt="Portfolio" style="width: 80px; height: 80px; object-fit: cover; border: 1px solid #f0f0f0;" loading="lazy">'
                ).join('');
            } else {
                portfolioHtml = '<p class="text-muted small">No portfolio images available</p>';
            }
            
            modalBody.innerHTML = 
                '<div class="row">' +
                    '<div class="col-md-4 text-center">' +
                        '<img src="' + avatarUrl + '" alt="' + artistName + '" class="rounded-circle" style="width: 150px; height: 150px; object-fit: cover; border: 2px solid #f0f0f0;" loading="lazy" onerror="this.src=\'${pageContext.request.contextPath}/assets/images/default-avatar.png\'">' +
                        '<h4 class="mt-3" style="color: #1a1a1a;">' + artistName + verifiedBadge + '</h4>' +
                        '<p class="text-muted">Artist</p>' +
                        '<p class="text-muted small">' +
                            '<i class="fas fa-map-marker-alt me-1"></i>' + artistLocation +
                        '</p>' +
                        (joinDate ? '<p class="text-muted small">' +
                            'Member since ' + formatDate(joinDate) +
                        '</p>' : '') +
                    '</div>' +
                    '<div class="col-md-8">' +
                        '<h5 style="color: #1a1a1a;">About</h5>' +
                        '<p style="color: #666;">' + artistBio + '</p>' +
                        '<div class="row mt-4">' +
                            '<div class="col-4 text-center">' +
                                '<h6 style="color: #1a1a1a;">' + artworksCount + '</h6>' +
                                '<small class="text-muted">Artworks</small>' +
                            '</div>' +
                            '<div class="col-4 text-center">' +
                                '<h6 style="color: #1a1a1a;">' + followersCount + '</h6>' +
                                '<small class="text-muted">Followers</small>' +
                            '</div>' +
                            (rating > 0 ? '<div class="col-4 text-center">' +
                                '<h6 style="color: #1a1a1a;">' + rating.toFixed(1) + '</h6>' +
                                '<small class="text-muted">Rating</small>' +
                            '</div>' : '<div class="col-4 text-center"></div>') +
                        '</div>' +
                        '<h5 class="mt-4" style="color: #1a1a1a;">Recent Works</h5>' +
                        '<div class="d-flex flex-wrap gap-2">' +
                            portfolioHtml +
                        '</div>' +
                    '</div>' +
                '</div>';
            
            // Set up portfolio button
            document.getElementById('viewPortfolioBtn').onclick = function() {
                viewArtistPortfolio(artistId);
            };
            
            new bootstrap.Modal(document.getElementById('artistModal')).show();
        }

        /**
         * View artist portfolio - redirects to profile page
         */
        function viewArtistPortfolio(artistId) {
            const modal = bootstrap.Modal.getInstance(document.getElementById('artistModal'));
            if (modal) modal.hide();
            
            // Redirect to artist's profile page
            window.location.href = '${pageContext.request.contextPath}/profile.jsp?userId=' + artistId;
        }

        function formatDate(dateString) {
            const date = new Date(dateString);
            return date.toLocaleDateString('en-US', { 
                year: 'numeric', 
                month: 'long' 
            });
        }

        function filterArtists() {
            currentPage = 1;
            
            // Directly filter and display without loading delay
            // This ensures real-time search results
            const filteredArtists = filterAndSortArtists();
            displayArtists(filteredArtists);
            updatePagination(filteredArtists.length);
        }

        function updatePagination(totalItems) {
            const itemsPerPage = 6;
            totalPages = Math.ceil(totalItems / itemsPerPage);
            
            const pagination = document.getElementById('pagination');
            if (totalPages <= 1) {
                pagination.innerHTML = '';
                return;
            }
            
            let paginationHtml = '';
            
            // Previous button
            paginationHtml += '<li class="page-item ' + (currentPage === 1 ? 'disabled' : '') + '">' +
                '<a class="page-link" href="#" onclick="changePage(' + (currentPage - 1) + ')">Previous</a>' +
            '</li>';
            
            // Page numbers
            for (let i = 1; i <= totalPages; i++) {
                paginationHtml += '<li class="page-item ' + (i === currentPage ? 'active' : '') + '">' +
                    '<a class="page-link" href="#" onclick="changePage(' + i + ')">' + i + '</a>' +
                '</li>';
            }
            
            // Next button
            paginationHtml += '<li class="page-item ' + (currentPage === totalPages ? 'disabled' : '') + '">' +
                '<a class="page-link" href="#" onclick="changePage(' + (currentPage + 1) + ')">Next</a>' +
            '</li>';
            
            pagination.innerHTML = paginationHtml;
        }

        function changePage(page) {
            if (page < 1 || page > totalPages || page === currentPage) return;
            currentPage = page;
            loadArtists();
        }

        function showLoadingSpinner() {
            document.getElementById('loadingSpinner').style.display = 'block';
        }

        function hideLoadingSpinner() {
            document.getElementById('loadingSpinner').style.display = 'none';
        }

        // Authentication functions are handled by auth.js
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
                            <button type="submit" class="btn btn-primary-custom w-100 mb-3">Sign In</button>
                        </form>
                        <div class="text-center">
                            <small class="text-muted">
                                Don't have an account? 
                                <a href="#" onclick="showRegisterModal()">Register here</a>
                            </small>
                        </div>
                    </div>
                    <div id="login-loading" class="text-center d-none">
                        <div class="spinner-border" role="status">
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
                        <button type="submit" class="btn btn-primary-custom w-100 mb-3">Create Account</button>
                    </form>
                    
                    <div class="text-center">
                        <small class="text-muted">
                            Already have an account? 
                            <a href="#" onclick="showLoginModal()">Login here</a>
                        </small>
                    </div>
                    
                    <div id="register-loading" class="text-center d-none">
                        <div class="spinner-border" role="status">
                            <span class="visually-hidden">Creating account...</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>
