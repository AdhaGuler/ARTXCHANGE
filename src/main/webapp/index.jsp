<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ArtXchange - Digital Art Marketplace</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="assets/css/main.css" rel="stylesheet">
</head>
<body class="fixed-navbar">
    <!-- Navigation -->
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark fixed-top">
        <div class="container">
            <a class="navbar-brand fw-bold" href="index.jsp">
                <i class="fas fa-palette me-2"></i>ArtXchange
            </a>
            
            <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
                <span class="navbar-toggler-icon"></span>
            </button>
            
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav me-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="browse.jsp">Browse Art</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="auctions.jsp">Auctions</a>
                    </li>
                    <li class="nav-item" id="biddings-nav" style="display: none;">
                        <a class="nav-link" href="biddings.jsp">
                            <i class="fas fa-gavel me-1"></i>Biddings
                        </a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="artists.jsp">Artists</a>
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
                            <li><a class="dropdown-item" href="profile.jsp">My Profile</a></li>
                            <li><a class="dropdown-item" href="dashboard.jsp">Dashboard</a></li>
                            <li><a class="dropdown-item" href="messages.jsp">Messages</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#" onclick="logout()">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
<section class="hero-section-minimal">
    <div class="container">
        <div class="row align-items-start pt-5">

            <div class="col-lg-7 mx-auto text-center">

                <img src="assets/images/trade-art.png" class="hero-top-image mb-4">

                <h1 class="hero-title mb-4">Discover Authentic Art</h1>

                <p class="hero-subtitle mb-5">
                    Malaysia's premier digital art marketplace. Connect with talented artists, 
                    discover unique pieces, and participate in curated auctions.
                </p>

                <div class="hero-actions">
                    <a href="browse.jsp" class="btn btn-primary-minimal">Browse Collection</a>
                    <a href="auctions.jsp" class="btn btn-outline-minimal">View Auctions</a>
                </div>

            </div>
        </div>
    </div>
</section>

    <!-- Features Section -->
    <section class="features-section-minimal">
        <div class="container">
            <div class="row g-5">
                <div class="col-md-4">
                    <div class="feature-item-minimal">
                        <div class="feature-icon-minimal">
                            <i class="fas fa-shield-alt"></i>
                        </div>
                        <h3 class="feature-title-minimal">Secure</h3>
                        <p class="feature-text-minimal">
                            Protected transactions with advanced encryption and secure payment processing
                        </p>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="feature-item-minimal">
                        <div class="feature-icon-minimal">
                            <i class="fas fa-gavel"></i>
                        </div>
                        <h3 class="feature-title-minimal">Live Auctions</h3>
                        <p class="feature-text-minimal">
                            Real-time bidding with transparent auction mechanics and instant updates
                        </p>
                    </div>
                </div>
                
                <div class="col-md-4">
                    <div class="feature-item-minimal">
                        <div class="feature-icon-minimal">
                            <i class="fas fa-users"></i>
                        </div>
                        <h3 class="feature-title-minimal">Community</h3>
                        <p class="feature-text-minimal">
                            Connect directly with artists and collectors in a trusted environment
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- Featured Artworks Section -->
    <section class="artworks-section-minimal">
        <div class="container">
            <div class="section-header-minimal mb-5">
                <h2 class="section-title-minimal">Featured Artworks</h2>
                <p class="section-subtitle-minimal">
                    Curated selection from talented Malaysian artists
                </p>
            </div>
            
            <div class="row g-4" id="featured-artworks">
                <!-- Featured artworks will be loaded here -->
                <div class="col-12 text-center py-5">
                    <div class="spinner-border-minimal" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
        </div>
    </section>

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

    <!-- Footer -->
    <footer class="footer-minimal">
        <div class="container">
            <div class="row">
                <div class="col-lg-4 mb-4 mb-lg-0">
                    <h5 class="footer-brand mb-3">ArtXchange</h5>
                    <p class="footer-text">
                        Malaysia's premier digital art marketplace, connecting artists and art lovers 
                        in a trusted online environment.
                    </p>
                </div>
                
                <div class="col-lg-2 col-md-4 mb-4 mb-lg-0">
                    <h6 class="footer-heading mb-3">Platform</h6>
                    <ul class="footer-links">
                        <li><a href="browse.jsp">Browse Art</a></li>
                        <li><a href="auctions.jsp">Auctions</a></li>
                        <li><a href="artists.jsp">Artists</a></li>
                    </ul>
                </div>
                
                <div class="col-lg-2 col-md-4 mb-4 mb-lg-0">
                    <h6 class="footer-heading mb-3">Support</h6>
                    <ul class="footer-links">
                        <li><a href="#">Help Center</a></li>
                        <li><a href="#">Contact Us</a></li>
                        <li><a href="#">Terms of Service</a></li>
                    </ul>
                </div>
                
                <div class="col-lg-4 col-md-4">
                    <h6 class="footer-heading mb-3">Connect</h6>
                    <p class="footer-text mb-3">Follow us for updates</p>
                    <div class="footer-social">
                        <a href="#" class="social-link">
                            <i class="fab fa-facebook-f"></i>
                        </a>
                        <a href="#" class="social-link">
                            <i class="fab fa-instagram"></i>
                        </a>
                        <a href="#" class="social-link">
                            <i class="fab fa-twitter"></i>
                        </a>
                    </div>
                </div>
            </div>
            
            <div class="footer-divider"></div>
            
            <div class="row align-items-center">
                <div class="col-md-6">
                    <p class="footer-copyright">
                        &copy; 2025 ArtXchange. All rights reserved.
                    </p>
                </div>
                <div class="col-md-6 text-md-end">
                    <p class="footer-copyright">
                        Supporting Malaysia's Digital Creative Economy
                    </p>
                </div>
            </div>
        </div>
    </footer>

    <!-- Scripts -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.23.0/firebase-auth-compat.js"></script>
    <script src="assets/js/firebase-config.js"></script>
    <script src="assets/js/auth.js"></script>
    <script src="assets/js/main.js"></script>
</body>
</html>
