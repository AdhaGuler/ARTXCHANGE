<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/fmt" prefix="fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User Profile - ArtXchange</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="${pageContext.request.contextPath}/assets/css/main.css" rel="stylesheet">
    <style>
        .profile-header {
            background: #f5f5f5;
            color: #1a1a1a;
            padding: 80px 0 60px;
            position: relative;
            overflow: hidden;
        }
        
        .profile-avatar {
            width: 300px;
            height: 300px;
            border-radius: 50%;
            border: 4px solid rgba(26, 26, 26, 0.08);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);
            object-fit: cover;
            background: #ffffff;
        }
        
        .profile-info {
            position: relative;
            z-index: 2;
        }
        
        #statsContainer {
            display: flex !important;
            flex-direction: row !important;
            flex-wrap: nowrap !important;
            justify-content: center !important;
            align-items: center !important;
            gap: 20px;
            width: 100%;
            margin: 0 !important;
            padding: 0 !important;
        }
        
        #statsContainer > div {
            flex: 0 0 auto;
            margin: 0 !important;
            padding: 0 !important;
        }
        
        .stats-card {
            background: white;
            border-radius: 15px;
            padding: 30px;
            text-align: center;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
            aspect-ratio: 1 / 1;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            width: 160px;
            max-width: 160px;
            margin: 0 !important;
            position: static !important;
        }
        
        @media (max-width: 992px) {
            #statsContainer {
                flex-wrap: wrap !important;
            }
        }
        
        @media (max-width: 576px) {
            #statsContainer {
                gap: 15px;
            }
            .stats-card {
                max-width: 140px;
                padding: 20px;
            }
        }
        
        @media (max-width: 400px) {
            #statsContainer {
                flex-direction: column !important;
            }
            .stats-card {
                max-width: 200px;
            }
        }
        
        .stats-card:hover {
            transform: translateY(-5px);
        }
        
        .stats-number {
            font-size: 2.5rem;
            font-weight: 300;
            color: #1a1a1a;
            margin-bottom: 10px;
            letter-spacing: -0.02em;
        }
        
        .social-links a {
            display: inline-block;
            width: 45px;
            height: 45px;
            line-height: 45px;
            text-align: center;
            background: rgba(26, 26, 26, 0.1);
            color: #1a1a1a;
            border-radius: 50%;
            margin: 0 5px;
            transition: all 0.3s ease;
        }
        
        .social-links a:hover {
            background: #1a1a1a;
            color: #ffffff;
            transform: translateY(-3px);
        }
        
        .artwork-grid .card {
            border: none;
            border-radius: 15px;
            overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
            transition: all 0.3s ease;
            margin-bottom: 30px;
        }
        
        .artwork-grid .card:hover {
            transform: translateY(-8px);
            box-shadow: 0 8px 30px rgba(0,0,0,0.15);
        }
        
        .artwork-grid .card-img-top {
            height: 250px;
            object-fit: cover;
        }
        
        .badge-role {
            font-size: 0.9rem;
            padding: 8px 16px;
            border-radius: 20px;
        }
        
        .contact-btn {
            background: linear-gradient(135deg, #00b894 0%, #00cec9 100%);
            border: none;
            border-radius: 25px;
            padding: 12px 30px;
            color: white;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .contact-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(0,184,148,0.3);
            color: white;
        }
        
        .follow-btn {
            background: linear-gradient(135deg, #fd79a8 0%, #fdcb6e 100%);
            border: none;
            border-radius: 25px;
            padding: 12px 30px;
            color: white;
            font-weight: 600;
            transition: all 0.3s ease;
        }
        
        .follow-btn:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(253,121,168,0.3);
            color: white;
        }
        
        .bio-section {
            background: #f8f9fa;
            border-radius: 15px;
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .section-title {
            font-size: 1.8rem;
            font-weight: 700;
            color: #2d3436;
            margin-bottom: 30px;
            position: relative;
        }
        
        .section-title::after {
            content: '';
            position: absolute;
            bottom: -10px;
            left: 0;
            width: 50px;
            height: 2px;
            background: #1a1a1a;
            border-radius: 0;
        }
        
        .artwork-filter {
            margin-bottom: 30px;
        }
        
        .filter-btn {
            background: transparent;
            border: 1px solid #e0e0e0;
            color: #666;
            border-radius: 0;
            padding: 8px 20px;
            margin: 5px;
            transition: all 0.3s ease;
            font-weight: 400;
        }
        
        .filter-btn.active,
        .filter-btn:hover {
            background: #1a1a1a;
            color: white;
            border-color: #1a1a1a;
        }
        
        .loading-state {
            text-align: center;
            padding: 50px;
            color: #6c757d;
        }
        
        .empty-state {
            text-align: center;
            padding: 60px 20px;
            color: #6c757d;
        }
        
        .empty-state i {
            font-size: 4rem;
            margin-bottom: 20px;
            opacity: 0.5;
        }
        
        /* Sold artwork overlay - match Dashboard */
        .card.sold-overlay {
            cursor: not-allowed;
            position: relative;
        }
        
        .card.sold-overlay::before {
            content: '';
            position: absolute;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.4);
            z-index: 1;
            pointer-events: none;
            border-radius: 15px;
        }
        
        .card.sold-overlay:hover {
            transform: none;
            border-color: #f0f0f0;
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        
        .card.sold-overlay .card-img-top {
            filter: grayscale(50%) brightness(0.7);
            opacity: 0.8;
        }
        
        .card.sold-overlay .card-body {
            position: relative;
            z-index: 2;
        }
        
        /* Sold badge styling - match Dashboard */
        .sold-badge {
            position: absolute;
            top: 12px;
            right: 12px;
            background: #dc3545;
            color: white;
            padding: 6px 12px;
            border-radius: 4px;
            font-size: 0.75rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            z-index: 3;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.2);
        }
        
        /* Purchase card styling - match Dashboard */
        .purchase-card {
            transition: all 0.3s ease;
        }
        
        .purchase-card:hover {
            box-shadow: 0 8px 30px rgba(0,0,0,0.15);
            transform: translateY(-2px);
        }

        /* ============================================
           REVIEWS SECTION STYLES - MINIMALIST BLACK & WHITE
           ============================================ */
        
        /* Tab Navigation */
        .nav-tabs .nav-link {
            transition: all 0.3s ease;
        }
        
        .nav-tabs .nav-link:hover {
            color: #1a1a1a !important;
            border-bottom-color: #1a1a1a !important;
        }
        
        .nav-tabs .nav-link.active {
            color: #1a1a1a !important;
            background: transparent !important;
            border-color: transparent !important;
            border-bottom-color: #1a1a1a !important;
        }

        /* Reviews Summary */
        .reviews-summary {
            padding: 20px 0;
        }

        .star-rating-large {
            display: flex;
            gap: 4px;
            align-items: center;
        }

        .star-rating-large .star {
            font-size: 1.5rem;
            color: #1a1a1a;
        }

        .star-rating-large .star.empty {
            color: #e0e0e0;
        }

        .rating-value {
            line-height: 1.2;
        }

        /* Filter Bar */
        .reviews-filter-bar {
            background: #fafafa;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 20px;
        }

        .reviews-filter-bar .form-label {
            font-size: 0.75rem;
            margin-bottom: 6px;
        }

        .reviews-filter-bar .form-select,
        .reviews-filter-bar .btn {
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            color: #1a1a1a;
            background: #ffffff;
        }

        .reviews-filter-bar .form-select:focus {
            border-color: #1a1a1a;
            box-shadow: 0 0 0 2px rgba(26, 26, 26, 0.1);
            outline: none;
        }

        .reviews-filter-bar .btn:hover {
            background: #1a1a1a;
            color: #ffffff;
            border-color: #1a1a1a;
        }

        /* Review Cards */
        .review-card {
            background: #ffffff;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            padding: 24px;
            margin-bottom: 20px;
            transition: all 0.3s ease;
        }

        .review-card:hover {
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.08);
            border-color: #d0d0d0;
        }

        .review-header {
            display: flex;
            justify-content: space-between;
            align-items: flex-start;
            margin-bottom: 16px;
        }

        .review-rating {
            display: flex;
            gap: 2px;
            align-items: center;
        }

        .review-rating .star {
            font-size: 1rem;
            color: #1a1a1a;
        }

        .review-rating .star.empty {
            color: #e0e0e0;
        }

        .review-date {
            font-size: 0.875rem;
            color: #666;
        }

        .review-text {
            color: #1a1a1a;
            line-height: 1.6;
            margin-bottom: 16px;
            font-size: 0.95rem;
        }

        .review-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding-top: 16px;
            border-top: 1px solid #f0f0f0;
        }

        .review-artwork {
            font-size: 0.875rem;
            color: #666;
        }

        .review-artwork a {
            color: #1a1a1a;
            text-decoration: none;
            font-weight: 500;
        }

        .review-artwork a:hover {
            text-decoration: underline;
        }

        .verified-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 0.75rem;
            color: #666;
            background: #f5f5f5;
            padding: 4px 8px;
            border-radius: 4px;
            border: 1px solid #e0e0e0;
        }

        .verified-badge i {
            color: #1a1a1a;
        }
    </style>
</head>
<body>
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark sticky-top" style="background: #1a1a1a; border-bottom: 1px solid #f0f0f0;">
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
                        <a class="nav-link" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/messages.jsp">Messages</a>
                    </li>
                    <li class="nav-item" id="biddings-nav" style="display: none;">
                        <a class="nav-link" href="${pageContext.request.contextPath}/biddings.jsp">
                            <i class="fas fa-gavel me-1"></i>Biddings
                        </a>
                    </li>
                </ul>
                
                <ul class="navbar-nav">
                    <li class="nav-item" id="auth-buttons">
                        <a class="nav-link" href="#" onclick="showLoginModal()">Login</a>
                        <a class="nav-link" href="#" onclick="showRegisterModal()">Register</a>
                    </li>
                    <li class="nav-item dropdown d-none" id="user-menu">
                        <a class="nav-link dropdown-toggle" href="#" id="userDropdown" role="button" data-bs-toggle="dropdown">
                            <img id="userAvatar" src="" alt="User" class="rounded-circle me-2" width="30" height="30">
                            <span id="userName">Loading...</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="#" onclick="showProfile()"><i class="fas fa-user me-2"></i>Profile</a></li>
                            <li><a class="dropdown-item" href="#" onclick="logout()"><i class="fas fa-sign-out-alt me-2"></i>Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Profile Header -->
    <div class="profile-header">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-4 text-center">
                    <div class="profile-info">
                        <img id="userAvatar" src="${pageContext.request.contextPath}/assets/images/default-avatar.svg" 
                             alt="Profile" class="profile-avatar mb-3"
                             style="object-fit: cover;"
                             onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/assets/images/default-avatar.svg';">
                        <div class="social-links" id="socialLinks">
                            <!-- Social links will be populated dynamically -->
                        </div>
                    </div>
                </div>
                <div class="col-md-8">
                    <div class="profile-info">
                        <div class="d-flex align-items-center mb-3">
                            <h1 id="userName" class="mb-0 me-3" style="color: #1a1a1a;">Loading...</h1>
                            <span id="userUsername" class="me-3" style="color: #666;">@loading</span>
                            <span id="userRole" class="badge badge-role bg-dark text-white">User</span>
                            <span id="verifiedBadge" class="badge bg-success ms-2" style="display: none;">
                                <i class="fas fa-check-circle"></i> Verified
                            </span>
                        </div>
                        <p id="userBio" class="lead mb-4" style="color: #1a1a1a; display: block;">Loading profile information...</p>
                        <div class="d-flex gap-3 mb-3" style="color: #666;">
                            <div>
                                <i class="fas fa-map-marker-alt me-2"></i>
                                <span id="userLocation">Location not specified</span>
                            </div>
                            <div>
                                <i class="fas fa-calendar-alt me-2"></i>
                                <span>Joined <span id="userJoinDate">Recently</span></span>
                            </div>
                        </div>
                        <div class="d-flex gap-3" id="profileActions">
                            <button id="editBtn" class="btn btn-primary" style="display: none; background: #1a1a1a; border: 1px solid #1a1a1a; color: white; border-radius: 0; padding: 12px 32px; font-weight: 500; letter-spacing: 0.5px; text-transform: uppercase; font-size: 0.875rem;">
                                <i class="fas fa-edit me-2"></i>Edit Profile
                            </button>
                            <button id="followBtn" class="btn btn-primary" style="display: none; background: #1a1a1a; border: 1px solid #1a1a1a; color: white; border-radius: 0; padding: 12px 32px; font-weight: 500; letter-spacing: 0.5px; text-transform: uppercase; font-size: 0.875rem;">
                                <i class="fas fa-user-plus me-2"></i>Follow
                            </button>
                            <button id="messageBtn" class="btn btn-outline-primary" style="display: none; background: transparent; border: 1px solid #1a1a1a; color: #1a1a1a; border-radius: 0; padding: 12px 32px; font-weight: 500; letter-spacing: 0.5px; text-transform: uppercase; font-size: 0.875rem;">
                                <i class="fas fa-envelope me-2"></i>Message
                            </button>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- Profile Content -->
    <div class="container my-5">
        <!-- Statistics Row -->
        <div class="mb-5" id="statsContainer">
            <div>
                <div class="stats-card">
                    <div class="stats-number" id="artworkCount">0</div>
                    <div class="text-muted">Artworks</div>
                </div>
            </div>
            <div>
                <div class="stats-card">
                    <div class="stats-number" id="likesCount">0</div>
                    <div class="text-muted">Likes</div>
                </div>
            </div>
            <div>
                <div class="stats-card">
                    <div class="stats-number" id="salesCount">0</div>
                    <div class="text-muted">Sales</div>
                </div>
            </div>
            <div>
                <div class="stats-card">
                    <div class="stats-number" id="followerCount">0</div>
                    <div class="text-muted">Followers</div>
                </div>
            </div>
        </div>

        <!-- Profile Tabs Navigation -->
        <ul class="nav nav-tabs mb-4" id="profileTabs" role="tablist" style="border-bottom: 1px solid #e0e0e0;">
            <li class="nav-item" role="presentation">
                <button class="nav-link active" id="artworks-tab" data-bs-toggle="tab" data-bs-target="#artworks-pane" 
                        type="button" role="tab" aria-controls="artworks-pane" aria-selected="true"
                        style="border: none; border-bottom: 2px solid #1a1a1a; color: #1a1a1a; padding: 12px 24px; font-weight: 500; border-radius: 0;">
                    <i class="fas fa-palette me-2"></i>Artworks
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="reviews-tab" data-bs-toggle="tab" data-bs-target="#reviews-pane" 
                        type="button" role="tab" aria-controls="reviews-pane" aria-selected="false"
                        style="border: none; border-bottom: 2px solid transparent; color: #666; padding: 12px 24px; font-weight: 500; border-radius: 0;">
                    <i class="fas fa-star me-2"></i>Reviews
                </button>
            </li>
            <li class="nav-item" role="presentation">
                <button class="nav-link" id="about-tab" data-bs-toggle="tab" data-bs-target="#about-pane" 
                        type="button" role="tab" aria-controls="about-pane" aria-selected="false"
                        style="border: none; border-bottom: 2px solid transparent; color: #666; padding: 12px 24px; font-weight: 500; border-radius: 0;">
                    <i class="fas fa-user me-2"></i>About
                </button>
            </li>
        </ul>

        <!-- Tab Content -->
        <div class="tab-content" id="profileTabContent">
            <!-- Artworks Tab Pane -->
            <div class="tab-pane fade show active" id="artworks-pane" role="tabpanel" aria-labelledby="artworks-tab">
                <!-- Artist Statement/Bio Section -->
                <div class="bio-section" id="artistStatementSection" style="display: none;">
                    <h3 class="section-title">Artist Statement</h3>
                    <p id="artistStatement" class="mb-0">No artist statement provided.</p>
                </div>

                <!-- Purchased Artworks Section (for buyers) -->
                <div id="purchasedArtworksSection" style="display: none;">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="section-title">My Collection</h3>
            </div>
            
            <div class="artwork-grid" id="purchasedArtworkContainer">
                <div id="purchasedArtworkGrid">
                    <!-- Purchased artworks will be loaded here -->
                </div>
                
                <!-- Loading State -->
                <div id="purchasedArtworksLoading" class="loading-state" style="display: none;">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-3">Loading purchased artworks...</p>
                </div>
                
                <!-- Empty State -->
                <div id="purchasedArtworksEmpty" class="empty-state" style="display: none;">
                    <i class="fas fa-shopping-bag"></i>
                    <h4>No Purchased Artworks</h4>
                    <p>This user hasn't purchased any artworks yet.</p>
                </div>
            </div>
            
            <!-- Load More Button -->
            <div class="text-center mt-4">
                <button id="loadMorePurchasedBtn" class="btn btn-outline-primary" style="display: none;">
                    Load More
                </button>
            </div>
        </div>

        <!-- Artworks Section (for artists) - Sold & Uploaded Artworks -->
        <div id="artworksSection">
            <div class="d-flex justify-content-between align-items-center mb-4">
                <h3 class="section-title">Sold & Uploaded Artworks</h3>
                <div class="artwork-filter">
                    <button class="filter-btn category-filter active" data-category="All">All</button>
                    <button class="filter-btn category-filter" data-category="PAINTING">Paintings</button>
                    <button class="filter-btn category-filter" data-category="SCULPTURE">Sculptures</button>
                    <button class="filter-btn category-filter" data-category="PHOTOGRAPHY">Photography</button>
                    <button class="filter-btn category-filter" data-category="DIGITAL_ART">Digital Art</button>
                </div>
            </div>
            
            <div class="artwork-grid" id="artworkContainer">
                <div class="row" id="artworkGrid">
                    <!-- Artworks will be loaded here -->
                </div>
                
                <!-- Loading State -->
                <div id="artworksLoading" class="loading-state" style="display: none;">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-3">Loading artworks...</p>
                </div>
                
                <!-- Empty State -->
                <div id="artworksEmpty" class="empty-state" style="display: none;">
                    <i class="fas fa-paint-brush"></i>
                    <h4>No Artworks Yet</h4>
                    <p>This artist hasn't uploaded any artworks yet.</p>
                </div>
            </div>
            
            <!-- Load More Button -->
            <div class="text-center mt-4">
                <button id="loadMoreBtn" class="btn btn-outline-primary" style="display: none;">
                    Load More Artworks
                </button>
            </div>
        </div>
            </div>

            <!-- Reviews Tab Pane -->
            <div class="tab-pane fade" id="reviews-pane" role="tabpanel" aria-labelledby="reviews-tab">
                <!-- Reviews Summary -->
                <div class="reviews-summary mb-4 pb-4" style="border-bottom: 1px solid #e0e0e0;">
                    <div class="row align-items-center">
                        <div class="col-md-6">
                            <div class="d-flex align-items-center">
                                <div class="average-rating-display me-4">
                                    <div class="star-rating-large mb-2" id="averageRatingStars">
                                        <!-- Stars will be populated dynamically -->
                                    </div>
                                    <div class="rating-value">
                                        <span id="averageRating" class="fs-3 fw-bold" style="color: #1a1a1a;">0.0</span>
                                        <span class="text-muted ms-1">/ 5.0</span>
                                    </div>
                                </div>
                                <div class="total-reviews">
                                    <div class="text-muted small">Based on</div>
                                    <div class="fs-4 fw-semibold" id="totalReviewsCount" style="color: #1a1a1a;">0</div>
                                    <div class="text-muted small">reviews</div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Filter Bar -->
                <div class="reviews-filter-bar mb-4">
                    <div class="row g-3">
                        <div class="col-md-3">
                            <label class="form-label small text-muted mb-2" style="font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px;">Rating</label>
                            <select class="form-select form-select-sm" id="ratingFilter" 
                                    style="border: 1px solid #e0e0e0; border-radius: 4px; padding: 8px 12px;">
                                <option value="all">All Ratings</option>
                                <option value="5">5★</option>
                                <option value="4">4★</option>
                                <option value="3">3★</option>
                                <option value="2">2★</option>
                                <option value="1">1★</option>
                            </select>
                        </div>
                        <div class="col-md-4">
                            <label class="form-label small text-muted mb-2" style="font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px;">Artwork</label>
                            <select class="form-select form-select-sm" id="artworkFilter" 
                                    style="border: 1px solid #e0e0e0; border-radius: 4px; padding: 8px 12px;">
                                <option value="all">All Artworks</option>
                                <!-- Artwork options will be populated dynamically -->
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="form-label small text-muted mb-2" style="font-weight: 500; text-transform: uppercase; letter-spacing: 0.5px;">Sort By</label>
                            <select class="form-select form-select-sm" id="sortFilter" 
                                    style="border: 1px solid #e0e0e0; border-radius: 4px; padding: 8px 12px;">
                                <option value="latest">Latest</option>
                                <option value="oldest">Oldest</option>
                                <option value="highest">Highest Rating</option>
                                <option value="lowest">Lowest Rating</option>
                            </select>
                        </div>
                        <div class="col-md-2 d-flex align-items-end">
                            <button type="button" class="btn btn-outline-secondary btn-sm w-100" id="clearFiltersBtn"
                                    style="border: 1px solid #e0e0e0; border-radius: 4px; padding: 8px 12px; color: #666;">
                                Clear
                            </button>
                        </div>
                    </div>
                </div>

                <!-- Reviews List -->
                <div id="reviewsList">
                    <!-- Loading State -->
                    <div id="reviewsLoading" class="loading-state" style="display: none;">
                        <div class="spinner-border text-muted" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                        <p class="mt-3 text-muted">Loading reviews...</p>
                    </div>

                    <!-- Empty State -->
                    <div id="reviewsEmpty" class="empty-state" style="display: none;">
                        <i class="fas fa-star" style="font-size: 4rem; margin-bottom: 20px; opacity: 0.3; color: #666;"></i>
                        <h4 class="text-muted">No Reviews Yet</h4>
                        <p class="text-muted">This artist hasn't received any reviews yet.</p>
                    </div>

                    <!-- Reviews Container -->
                    <div id="reviewsContainer">
                        <!-- Reviews will be loaded here -->
                    </div>
                </div>
            </div>

            <!-- About Tab Pane -->
            <div class="tab-pane fade" id="about-pane" role="tabpanel" aria-labelledby="about-tab">
                <!-- Artist Statement/Bio Section -->
                <div class="bio-section" id="aboutArtistStatementSection">
                    <h3 class="section-title">About</h3>
                    <p id="aboutArtistStatement" class="mb-0">No artist statement provided.</p>
                </div>
            </div>
        </div>
    </div>

    <!-- Edit Profile Modal -->
    <div class="modal fade" id="editProfileModal" tabindex="-1" aria-labelledby="editProfileModalLabel" aria-hidden="true">
        <div class="modal-dialog modal-lg">
            <div class="modal-content" style="border-radius: 0; border: 1px solid #f0f0f0;">
                <div class="modal-header" style="background: #ffffff; border-bottom: 1px solid #f0f0f0; border-radius: 0;">
                    <h5 class="modal-title" id="editProfileModalLabel" style="font-weight: 400; font-size: 1.25rem; letter-spacing: -0.01em;">
                        <i class="fas fa-edit me-2"></i>Edit Profile
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>
                <div class="modal-body" style="padding: 24px;">
                    <form id="editProfileForm">
                        <div class="row mb-4">
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label" style="font-size: 0.875rem; font-weight: 500; color: #1a1a1a; margin-bottom: 8px; letter-spacing: 0.3px;">
                                        Display Name *
                                    </label>
                                    <input type="text" class="form-control" id="editDisplayName" 
                                           style="border: 1px solid #e0e0e0; border-radius: 0; padding: 10px 16px; font-size: 0.95rem;"
                                           required minlength="2" maxlength="100">
                                    <small class="form-text text-muted" style="font-size: 0.8rem;">
                                        Your name as it appears on your profile (2-100 characters)
                                    </small>
                                </div>
                            </div>
                            <div class="col-md-6">
                                <div class="mb-3">
                                    <label class="form-label" style="font-size: 0.875rem; font-weight: 500; color: #1a1a1a; margin-bottom: 8px; letter-spacing: 0.3px;">
                                        Profile Picture
                                    </label>
                                    <input type="file" class="form-control" id="editProfilePicture" 
                                           accept="image/jpeg,image/jpg,image/png,image/webp"
                                           style="border: 1px solid #e0e0e0; border-radius: 0; padding: 10px 16px; font-size: 0.95rem;">
                                    <small class="form-text text-muted" style="font-size: 0.8rem;">
                                        JPG, PNG, or WebP (max 5MB). Will be resized to 300x300.
                                    </small>
                                </div>
                            </div>
                        </div>
                        <div class="mb-3">
                            <label class="form-label" style="font-size: 0.875rem; font-weight: 500; color: #1a1a1a; margin-bottom: 8px; letter-spacing: 0.3px;">
                                Bio / Artist Description
                            </label>
                            <textarea class="form-control" id="editBio" rows="5" maxlength="1000"
                                      style="border: 1px solid #e0e0e0; border-radius: 0; padding: 10px 16px; font-size: 0.95rem;"
                                      placeholder="Tell us about yourself..."></textarea>
                            <small class="form-text text-muted" style="font-size: 0.8rem;">
                                <span id="bioCharCount">0</span>/1000 characters
                            </small>
                        </div>
                        <div class="mb-3" id="profilePicturePreview" style="display: none;">
                            <label class="form-label" style="font-size: 0.875rem; font-weight: 500; color: #1a1a1a; margin-bottom: 8px;">
                                Preview
                            </label>
                            <div class="text-center">
                                <img id="profilePicturePreviewImg" src="" alt="Preview" 
                                     style="width: 200px; height: 200px; border-radius: 50%; border: 4px solid rgba(26, 26, 26, 0.08); object-fit: cover; background: #fafafa;">
                            </div>
                        </div>
                    </form>
                </div>
                <div class="modal-footer" style="border-top: 1px solid #f0f0f0; padding: 16px 24px;">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal"
                            style="border-radius: 0; padding: 10px 24px; font-weight: 500; border: 1px solid #e0e0e0; background: transparent; color: #666;">
                        Cancel
                    </button>
                    <button type="button" class="btn btn-primary" onclick="saveProfileChanges()"
                            style="background: #1a1a1a; border: 1px solid #1a1a1a; border-radius: 0; padding: 10px 24px; font-weight: 500; letter-spacing: 0.3px;">
                        <i class="fas fa-save me-2"></i>Save Changes
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Toast Notification Container -->
    <div class="toast-container position-fixed top-0 end-0 p-3" style="z-index: 9999;">
        <div id="toastContainer"></div>
    </div>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/firebase-config.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/profile.js"></script>
    
    <script>
        // ============================================
        // REVIEWS FUNCTIONALITY - PUBLIC READ-ONLY
        // ============================================
        
        // Mock reviews data (in real app, fetch from API)
        let allReviews = [];
        let filteredReviews = [];
        
        /**
         * Initialize reviews when Reviews tab is shown
         */
        document.addEventListener('DOMContentLoaded', function() {
            // Wait a bit for profile.js to initialize and set currentUserId
            setTimeout(function() {
                const reviewsTab = document.getElementById('reviews-tab');
                if (reviewsTab) {
                    reviewsTab.addEventListener('shown.bs.tab', function() {
                        console.log('Reviews tab clicked - loading reviews');
                        loadReviews();
                    });
                }
                
                // Load reviews on page load if Reviews tab is active
                const activeTab = document.querySelector('#reviews-tab.active, #reviews-pane.show.active');
                if (activeTab) {
                    console.log('Reviews tab is active on page load - loading reviews');
                    loadReviews();
                }
            }, 500); // Wait 500ms for profile.js to initialize
            
            // Filter event listeners (can be set up immediately)
            const ratingFilter = document.getElementById('ratingFilter');
            const artworkFilter = document.getElementById('artworkFilter');
            const sortFilter = document.getElementById('sortFilter');
            const clearFiltersBtn = document.getElementById('clearFiltersBtn');
            
            if (ratingFilter) {
                ratingFilter.addEventListener('change', applyFilters);
            }
            if (artworkFilter) {
                artworkFilter.addEventListener('change', applyFilters);
            }
            if (sortFilter) {
                sortFilter.addEventListener('change', applyFilters);
            }
            if (clearFiltersBtn) {
                clearFiltersBtn.addEventListener('click', clearFilters);
            }
        });
        
        /**
         * Load reviews for the current artist/seller
         * Fetches from: /api/users/{userId}/reviews
         * Uses 'userId' parameter from URL (matches profile.js convention)
         */
        function loadReviews() {
            const urlParams = new URLSearchParams(window.location.search);
            // Try 'userId' first (matches profile.js), then 'id' as fallback
            let artistId = urlParams.get('userId') || urlParams.get('id');
            
            // If still no artistId, try to get it from the profile manager
            if (!artistId) {
                // Check if profile manager has the current user ID (profile.js uses window.userProfileManager)
                if (typeof window.userProfileManager !== 'undefined' && window.userProfileManager.currentUserId) {
                    artistId = window.userProfileManager.currentUserId;
                    console.log('Using artistId from userProfileManager:', artistId);
                }
            }
            
            if (!artistId) {
                console.error('Artist ID not found in URL. URL params:', window.location.search);
                console.error('Available params:', Array.from(urlParams.keys()));
                showReviewsEmpty();
                return;
            }
            
            // Debug: Log artist ID being viewed
            console.log('=== LOADING REVIEWS ===');
            console.log('Viewing artist profile - artistId:', artistId);
            console.log('Full URL:', window.location.href);
            
            // Show loading state
            showReviewsLoading();
            
            // Fetch reviews from API
            fetch('/api/users/' + artistId + '/reviews', {
                method: 'GET',
                credentials: 'include',
                headers: {
                    'Content-Type': 'application/json'
                }
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Failed to load reviews: ' + response.status);
                }
                return response.json();
            })
            .then(data => {
                console.log('Reviews API response:', data);
                
                if (data.success && data.data) {
                    const reviewsData = data.data.reviews || [];
                    
                    // Debug: Log review count
                    console.log('=== REVIEWS FETCHED ===');
                    console.log('Reviews fetched:', reviewsData.length);
                    console.log('Average rating:', data.data.averageRating);
                    console.log('Total reviews:', data.data.totalReviews);
                    
                    if (reviewsData.length > 0) {
                        console.log('Sample review:', reviewsData[0]);
                    }
                    
                    // Transform API data to match expected format
                    allReviews = reviewsData.map(review => ({
                        reviewId: review.reviewId,
                        artworkId: review.artworkId,
                        artworkTitle: review.artwork ? review.artwork.title : 'Unknown Artwork',
                        rating: review.rating,
                        reviewText: review.reviewText,
                        reviewDate: review.reviewDate ? new Date(review.reviewDate) : new Date(),
                        buyerName: review.buyer ? (review.buyer.displayName || review.buyer.username) : 'Anonymous',
                        verified: review.verified !== false // Default to true
                    }));
                    
                    // Update summary with API data (use API averageRating if available)
                    if (data.data.averageRating !== undefined) {
                        updateReviewsSummaryFromAPI(data.data.averageRating, data.data.totalReviews);
                    }
                    
                    // Populate artwork filter dropdown
                    populateArtworkFilter(allReviews);
                    
                    // Apply initial filters and display
                    applyFilters();
                } else {
                    console.warn('No reviews data in response:', data);
                    showReviewsEmpty();
                }
            })
            .catch(error => {
                console.error('Error loading reviews:', error);
                showReviewsEmpty();
            });
        }
        
        // Note: generateMockReviews() removed - now using real API data from /api/users/{artistId}/reviews
        
        /**
         * Populate artwork filter dropdown
         */
        function populateArtworkFilter(reviews) {
            const artworkFilter = document.getElementById('artworkFilter');
            if (!artworkFilter) return;
            
            // Get unique artworks
            const artworks = [...new Map(reviews.map(r => [r.artworkId, r])).values()];
            
            // Clear existing options (except "All Artworks")
            artworkFilter.innerHTML = '<option value="all">All Artworks</option>';
            
            // Add artwork options
            artworks.forEach(artwork => {
                const option = document.createElement('option');
                option.value = artwork.artworkId;
                option.textContent = artwork.artworkTitle;
                artworkFilter.appendChild(option);
            });
        }
        
        /**
         * Apply filters and sorting
         */
        function applyFilters() {
            const ratingFilter = document.getElementById('ratingFilter')?.value || 'all';
            const artworkFilter = document.getElementById('artworkFilter')?.value || 'all';
            const sortFilter = document.getElementById('sortFilter')?.value || 'latest';
            
            // Start with all reviews
            filteredReviews = [...allReviews];
            
            // Filter by rating
            if (ratingFilter !== 'all') {
                filteredReviews = filteredReviews.filter(r => r.rating === parseInt(ratingFilter));
            }
            
            // Filter by artwork
            if (artworkFilter !== 'all') {
                filteredReviews = filteredReviews.filter(r => r.artworkId === artworkFilter);
            }
            
            // Sort reviews
            switch(sortFilter) {
                case 'latest':
                    filteredReviews.sort((a, b) => new Date(b.reviewDate) - new Date(a.reviewDate));
                    break;
                case 'oldest':
                    filteredReviews.sort((a, b) => new Date(a.reviewDate) - new Date(b.reviewDate));
                    break;
                case 'highest':
                    filteredReviews.sort((a, b) => b.rating - a.rating);
                    break;
                case 'lowest':
                    filteredReviews.sort((a, b) => a.rating - b.rating);
                    break;
            }
            
            // Update summary with filtered reviews
            updateReviewsSummary(filteredReviews);
            
            // Display filtered reviews
            displayReviews(filteredReviews);
        }
        
        /**
         * Clear all filters
         */
        function clearFilters() {
            document.getElementById('ratingFilter').value = 'all';
            document.getElementById('artworkFilter').value = 'all';
            document.getElementById('sortFilter').value = 'latest';
            applyFilters();
        }
        
        /**
         * Update reviews summary from API response (uses API-calculated average)
         */
        function updateReviewsSummaryFromAPI(averageRating, totalReviews) {
            // Update total count
            const totalReviewsEl = document.getElementById('totalReviewsCount');
            if (totalReviewsEl) {
                totalReviewsEl.textContent = totalReviews || 0;
            }
            
            // Update average rating
            const averageRatingEl = document.getElementById('averageRating');
            if (averageRatingEl) {
                averageRatingEl.textContent = (averageRating || 0.0).toFixed(1);
            }
            
            // Update star display
            const averageRatingStars = document.getElementById('averageRatingStars');
            if (averageRatingStars) {
                averageRatingStars.innerHTML = renderStars(parseFloat(averageRating || 0), true);
            }
        }
        
        /**
         * Update reviews summary (average rating, total count) from filtered reviews
         */
        function updateReviewsSummary(reviews) {
            const totalReviews = reviews.length;
            const averageRating = totalReviews > 0 
                ? (reviews.reduce((sum, r) => sum + r.rating, 0) / totalReviews).toFixed(1)
                : 0.0;
            
            // Update total count
            const totalReviewsEl = document.getElementById('totalReviewsCount');
            if (totalReviewsEl) {
                totalReviewsEl.textContent = totalReviews;
            }
            
            // Update average rating
            const averageRatingEl = document.getElementById('averageRating');
            if (averageRatingEl) {
                averageRatingEl.textContent = averageRating;
            }
            
            // Update star display
            const averageRatingStars = document.getElementById('averageRatingStars');
            if (averageRatingStars) {
                averageRatingStars.innerHTML = renderStars(parseFloat(averageRating), true);
            }
        }
        
        /**
         * Display reviews in the list
         */
        function displayReviews(reviews) {
            const reviewsContainer = document.getElementById('reviewsContainer');
            if (!reviewsContainer) return;
            
            // Hide loading and empty states
            hideReviewsLoading();
            hideReviewsEmpty();
            
            if (reviews.length === 0) {
                showReviewsEmpty();
                reviewsContainer.innerHTML = '';
                return;
            }
            
            // Render review cards
            reviewsContainer.innerHTML = reviews.map(review => renderReviewCard(review)).join('');
        }
        
        /**
         * Render a single review card
         */
        function renderReviewCard(review) {
            const reviewDate = new Date(review.reviewDate);
            const formattedDate = reviewDate.toLocaleDateString('en-US', { 
                year: 'numeric', 
                month: 'long', 
                day: 'numeric' 
            });
            
            return '<div class="review-card">' +
                '<div class="review-header">' +
                    '<div class="review-rating">' +
                        renderStars(review.rating, false) +
                    '</div>' +
                    '<div class="review-date">' +
                        formattedDate +
                    '</div>' +
                '</div>' +
                '<div class="review-text">' +
                    escapeHtml(review.reviewText) +
                '</div>' +
                '<div class="review-footer">' +
                    '<div class="review-artwork">' +
                        '<i class="fas fa-palette me-1"></i>' +
                        '<a href="/artwork-detail.jsp?id=' + review.artworkId + '">' + escapeHtml(review.artworkTitle) + '</a>' +
                    '</div>' +
                    (review.verified ? '<span class="verified-badge"><i class="fas fa-check-circle"></i> Verified Buyer</span>' : '') +
                '</div>' +
            '</div>';
        }
        
        /**
         * Render star rating display
         * @param {number} rating - Rating value (0-5)
         * @param {boolean} large - Whether to use large stars
         */
        function renderStars(rating, large = false) {
            const starSize = large ? '1.5rem' : '1rem';
            let html = '';
            const fullStars = Math.floor(rating);
            const hasHalfStar = rating % 1 >= 0.5;
            
            for (let i = 1; i <= 5; i++) {
                if (i <= fullStars) {
                    html += `<i class="fas fa-star star" style="font-size: ${starSize}; color: #1a1a1a;"></i>`;
                } else if (i === fullStars + 1 && hasHalfStar) {
                    html += `<i class="fas fa-star-half-alt star" style="font-size: ${starSize}; color: #1a1a1a;"></i>`;
                } else {
                    html += `<i class="far fa-star star empty" style="font-size: ${starSize}; color: #e0e0e0;"></i>`;
                }
            }
            
            return html;
        }
        
        /**
         * Show loading state
         */
        function showReviewsLoading() {
            const loading = document.getElementById('reviewsLoading');
            const container = document.getElementById('reviewsContainer');
            if (loading) loading.style.display = 'block';
            if (container) container.innerHTML = '';
            hideReviewsEmpty();
        }
        
        /**
         * Hide loading state
         */
        function hideReviewsLoading() {
            const loading = document.getElementById('reviewsLoading');
            if (loading) loading.style.display = 'none';
        }
        
        /**
         * Show empty state
         */
        function showReviewsEmpty() {
            const empty = document.getElementById('reviewsEmpty');
            const container = document.getElementById('reviewsContainer');
            if (empty) empty.style.display = 'block';
            if (container) container.innerHTML = '';
            hideReviewsLoading();
        }
        
        /**
         * Hide empty state
         */
        function hideReviewsEmpty() {
            const empty = document.getElementById('reviewsEmpty');
            if (empty) empty.style.display = 'none';
        }
        
        /**
         * Escape HTML to prevent XSS
         */
        function escapeHtml(text) {
            if (!text) return '';
            const map = {
                '&': '&amp;',
                '<': '&lt;',
                '>': '&gt;',
                '"': '&quot;',
                "'": '&#039;'
            };
            return String(text).replace(/[&<>"']/g, function(m) { return map[m]; });
        }
    </script>
</body>
</html>
