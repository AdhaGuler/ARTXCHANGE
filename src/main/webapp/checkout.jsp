<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.artexchange.model.Artwork" %>
<%@ page import="com.artexchange.model.Purchase" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    Artwork artwork = (Artwork) request.getAttribute("artwork");
    if (artwork == null) {
        response.sendRedirect(request.getContextPath() + "/browse.jsp");
        return;
    }
    
    Boolean checkoutDisabledAttr = (Boolean) request.getAttribute("checkoutDisabled");
    boolean checkoutDisabled = checkoutDisabledAttr != null && checkoutDisabledAttr;
    String checkoutError = (String) request.getAttribute("checkoutError");
    Boolean isAuctionWinAttr = (Boolean) request.getAttribute("isAuctionWin");
    boolean isAuctionWin = isAuctionWinAttr != null && isAuctionWinAttr;
    Purchase purchase = (Purchase) request.getAttribute("purchase");
    
    DecimalFormat priceFormat = new DecimalFormat("#,##0.00");
    
    // For auction wins, use purchase price; otherwise use artwork price
    BigDecimal artworkPrice;
    if (isAuctionWin && purchase != null && purchase.getPurchasePrice() != null) {
        artworkPrice = purchase.getPurchasePrice();
    } else {
        artworkPrice = artwork.getPrice() != null ? artwork.getPrice() : BigDecimal.ZERO;
    }
    
    BigDecimal shippingCost = artwork.getShippingCost() != null ? artwork.getShippingCost() : BigDecimal.ZERO;
    BigDecimal totalCost = artworkPrice.add(shippingCost);
    
    String artworkPriceDisplay = "RM " + priceFormat.format(artworkPrice);
    String shippingCostDisplay = shippingCost.compareTo(BigDecimal.ZERO) > 0
            ? "RM " + priceFormat.format(shippingCost)
            : "Free";
    String totalCostDisplay = "RM " + priceFormat.format(totalCost);
    
    String artworkPriceValue = artworkPrice.toPlainString();
    String shippingCostValue = shippingCost.toPlainString();
    String totalCostValue = totalCost.toPlainString();
    
    String primaryImageUrl = artwork.getPrimaryImageUrl() != null && !artwork.getPrimaryImageUrl().trim().isEmpty()
            ? artwork.getPrimaryImageUrl()
            : (request.getContextPath() + "/assets/images/placeholder-artwork.jpg");
    String artistName = artwork.getArtistName() != null && !artwork.getArtistName().trim().isEmpty()
            ? artwork.getArtistName()
            : "Unknown Artist";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Checkout - <c:out value="${artwork.title}" /> | ArtXchange</title>
    
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    
    <style>
        body {
            background-color: #f4f6f9;
        }
        .checkout-hero {
            background: linear-gradient(135deg, #12182c 0%, #1f2937 100%);
            color: #fff;
            padding: 2.5rem 0;
        }
        .checkout-steps {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            margin-bottom: 2rem;
        }
        .checkout-step {
            flex: 1;
            min-width: 180px;
            background: #fff;
            border: 1px solid #e3e6ed;
            border-radius: 0.75rem;
            padding: 0.85rem 1.15rem;
            display: flex;
            align-items: center;
            gap: 0.75rem;
            color: #6c757d;
            font-weight: 600;
            box-shadow: 0 1px 2px rgba(15, 23, 42, 0.05);
        }
        .checkout-step .step-index {
            width: 32px;
            height: 32px;
            border-radius: 50%;
            background: #e9ecef;
            color: #495057;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
        }
        .checkout-step.active {
            border-color: #0d6efd;
            color: #0d6efd;
            box-shadow: 0 10px 25px rgba(13, 110, 253, 0.15);
        }
        .checkout-step.active .step-index {
            background: #0d6efd;
            color: #fff;
        }
        .checkout-card {
            border: none;
            border-radius: 1rem;
            box-shadow: 0 15px 35px rgba(15, 23, 42, 0.08);
        }
        .checkout-card .card-header {
            background: transparent;
            border-bottom: 1px solid rgba(15, 23, 42, 0.08);
            padding: 1.25rem 1.5rem;
        }
        .checkout-card .card-body {
            padding: 1.5rem;
        }
        .checkout-artwork-thumb {
            width: 96px;
            height: 96px;
            border-radius: 0.85rem;
            object-fit: cover;
        }
        .order-summary-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 0.85rem;
            font-size: 0.95rem;
        }
        .order-summary-row strong {
            font-size: 1rem;
            color: #111827;
        }
        .order-total-row {
            font-size: 1.15rem;
            font-weight: 700;
            color: #111827;
            border-top: 1px dashed #e5e7eb;
            padding-top: 1rem;
            margin-top: 1rem;
        }
        .secure-badge {
            display: inline-flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 0.9rem;
            background: rgba(25, 135, 84, 0.1);
            color: #198754;
            border-radius: 999px;
            font-weight: 600;
            font-size: 0.9rem;
        }
        .checkout-support-card li {
            margin-bottom: 0.45rem;
            display: flex;
            gap: 0.65rem;
            align-items: center;
        }
        @media (max-width: 767px) {
            .checkout-step {
                flex: 1 1 calc(50% - 1rem);
            }
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
                    <li class="nav-item" id="auth-buttons">
                        <a class="nav-link" href="#" onclick="showLoginModal()">Login</a>
                        <a class="nav-link" href="#" onclick="showRegisterModal()">Register</a>
                    </li>
                    <li class="nav-item dropdown d-none" id="user-menu">
                        <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown">
                            <i class="fas fa-user-circle me-1"></i>
                            <span id="user-name">Account</span>
                        </a>
                        <ul class="dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/profile.jsp">Profile</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/messages.jsp">Messages</a></li>
                            <li><hr class="dropdown-divider"></li>
                            <li><a class="dropdown-item" href="#" onclick="logout()">Logout</a></li>
                        </ul>
                    </li>
                </ul>
            </div>
        </div>
    </nav>
    
    <!-- Hero -->
    <section class="checkout-hero mt-5 pt-4">
        <div class="container">
            <div class="d-flex flex-wrap align-items-center justify-content-between">
                <div>
                    <p class="text-uppercase text-muted mb-1 small">Secure Checkout</p>
                    <h1 class="display-6 fw-bold mb-2"><c:out value="${artwork.title}" /></h1>
                    <p class="mb-0">
                        Completing purchase for <span class="fw-semibold"><%=artistName%></span>'s artwork.
                    </p>
                </div>
                <div class="text-end">
                    <span class="secure-badge">
                        <i class="fas fa-lock"></i> SSL Encrypted
                    </span>
                </div>
            </div>
        </div>
    </section>
    
    <div class="container my-5">
        <div class="checkout-steps">
            <div class="checkout-step active">
                <span class="step-index">1</span>
                <div>
                    <small class="d-block text-muted">Step 1</small>
                    Artwork Review
                </div>
            </div>
            <div class="checkout-step active">
                <span class="step-index">2</span>
                <div>
                    <small class="d-block text-muted">Step 2</small>
                    Shipping Details
                </div>
            </div>
            <div class="checkout-step <%=checkoutDisabled ? "" : "active"%>">
                <span class="step-index">3</span>
                <div>
                    <small class="d-block text-muted">Step 3</small>
                    Payment
                </div>
            </div>
            <div class="checkout-step">
                <span class="step-index">4</span>
                <div>
                    <small class="d-block text-muted">Step 4</small>
                    Confirmation
                </div>
            </div>
        </div>
        
        <% if (checkoutError != null && !checkoutError.isEmpty()) { %>
            <div class="alert alert-warning shadow-sm mb-4" role="alert">
                <i class="fas fa-info-circle me-2"></i><%=checkoutError%>
                <div class="mt-2 small">
                    <a href="${pageContext.request.contextPath}/artwork/<%=artwork.getArtworkId()%>" class="text-decoration-none">
                        <i class="fas fa-arrow-left me-1"></i>Return to artwork page
                    </a>
                </div>
            </div>
        <% } %>
        
        <div class="alert alert-success d-none" id="checkoutSuccessAlert" role="alert"></div>
        
        <div class="row g-4">
            <div class="col-lg-7">
                <div class="card checkout-card">
                    <div class="card-header">
                        <div class="d-flex align-items-center">
                            <i class="fas fa-map-marker-alt text-primary me-2"></i>
                            <div>
                                <h5 class="mb-0">Contact & Shipping</h5>
                                <small class="text-muted">We’ll send your receipt and shipping updates here</small>
                            </div>
                        </div>
                    </div>
                    <div class="card-body">
                        <form id="checkoutForm" novalidate>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <label for="contactFirstName" class="form-label">First Name *</label>
                                    <input type="text" class="form-control" id="contactFirstName" placeholder="Jane" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="contactLastName" class="form-label">Last Name *</label>
                                    <input type="text" class="form-control" id="contactLastName" placeholder="Doe" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="contactEmail" class="form-label">Email Address *</label>
                                    <input type="email" class="form-control" id="contactEmail" placeholder="you@email.com" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="contactPhone" class="form-label">Phone Number</label>
                                    <input type="tel" class="form-control" id="contactPhone" placeholder="+60 12 345 6789">
                                </div>
                            </div>
                            
                            <hr class="my-4">
                            <h6 class="mb-3"><i class="fas fa-truck me-2"></i>Shipping Address *</h6>
                            <div class="row g-3">
                                <div class="col-12">
                                    <label for="addressLine1" class="form-label">Address Line 1 *</label>
                                    <input type="text" class="form-control" id="addressLine1" placeholder="Street address" required>
                                </div>
                                <div class="col-12">
                                    <label for="addressLine2" class="form-label">Address Line 2</label>
                                    <input type="text" class="form-control" id="addressLine2" placeholder="Apartment, suite, etc (optional)">
                                </div>
                                <div class="col-md-6">
                                    <label for="city" class="form-label">City *</label>
                                    <input type="text" class="form-control" id="city" required>
                                </div>
                                <div class="col-md-3">
                                    <label for="stateRegion" class="form-label">State *</label>
                                    <input type="text" class="form-control" id="stateRegion" placeholder="Selangor" required>
                                </div>
                                <div class="col-md-3">
                                    <label for="postalCode" class="form-label">Postal Code *</label>
                                    <input type="text" class="form-control" id="postalCode" placeholder="43000" required>
                                </div>
                                <div class="col-md-6">
                                    <label for="country" class="form-label">Country *</label>
                                    <input type="text" class="form-control" id="country" value="Malaysia" required>
                                </div>
                            </div>
                            
                            <hr class="my-4">
                            <h6 class="mb-3"><i class="fas fa-credit-card me-2"></i>Payment Method *</h6>
                            <div class="row g-3">
                                <div class="col-md-6">
                                    <div class="form-check border rounded p-3 h-100">
                                        <input class="form-check-input" type="radio" name="paymentMethod" id="paymentCard" value="credit_card" required>
                                        <label class="form-check-label w-100" for="paymentCard">
                                            <div class="fw-semibold">Credit / Debit Card</div>
                                            <small class="text-muted">Visa, Mastercard, Amex</small>
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-check border rounded p-3 h-100">
                                        <input class="form-check-input" type="radio" name="paymentMethod" id="paymentTransfer" value="bank_transfer">
                                        <label class="form-check-label w-100" for="paymentTransfer">
                                            <div class="fw-semibold">FPX / Bank Transfer</div>
                                            <small class="text-muted">Maybank, CIMB, RHB & more</small>
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-check border rounded p-3 h-100">
                                        <input class="form-check-input" type="radio" name="paymentMethod" id="paymentPayPal" value="paypal">
                                        <label class="form-check-label w-100" for="paymentPayPal">
                                            <div class="fw-semibold">PayPal</div>
                                            <small class="text-muted">Pay securely with PayPal</small>
                                        </label>
                                    </div>
                                </div>
                                <div class="col-md-6">
                                    <div class="form-check border rounded p-3 h-100">
                                        <input class="form-check-input" type="radio" name="paymentMethod" id="paymentOther" value="other">
                                        <label class="form-check-label w-100" for="paymentOther">
                                            <div class="fw-semibold">Other Arrangements</div>
                                            <small class="text-muted">Discuss with the artist</small>
                                        </label>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="mt-4">
                                <label for="orderNotes" class="form-label">Order Notes</label>
                                <textarea class="form-control" id="orderNotes" rows="3" placeholder="Any delivery notes, framing requests, etc."></textarea>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
            
            <div class="col-lg-5">
                <div class="card checkout-card mb-4">
                    <div class="card-header d-flex align-items-center justify-content-between">
                        <div>
                            <h5 class="mb-0">Order Summary</h5>
                            <small class="text-muted">Review artwork & totals before paying</small>
                        </div>
                        <a href="${pageContext.request.contextPath}/artwork/<%=artwork.getArtworkId()%>" class="btn btn-link btn-sm text-decoration-none">
                            <i class="fas fa-arrow-left me-1"></i>Back to artwork
                        </a>
                    </div>
                    <div class="card-body">
                        <div class="d-flex gap-3 align-items-center mb-3">
                            <img src="<%=primaryImageUrl%>" alt="Artwork thumbnail" class="checkout-artwork-thumb shadow-sm">
                            <div>
                                <h6 class="mb-1"><c:out value="${artwork.title}" /></h6>
                                <small class="text-muted d-block mb-1">by <%=artistName%></small>
                                <span class="badge bg-light text-dark">
                                    <i class="fas fa-image me-1"></i><%=artwork.getCategory() != null ? artwork.getCategory().getDisplayName() : "Artwork"%>
                                </span>
                            </div>
                        </div>
                        
                        <div class="order-summary-row">
                            <span><%=isAuctionWin ? "Winning Bid" : "Artwork Price"%></span>
                            <strong><%=artworkPriceDisplay%></strong>
                        </div>
                        <% if (isAuctionWin && purchase != null && purchase.getPaymentDeadline() != null) { 
                            LocalDateTime deadline = purchase.getPaymentDeadline();
                            java.time.format.DateTimeFormatter formatter = java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy 'at' HH:mm");
                        %>
                        <div class="order-summary-row">
                            <span>Payment Deadline</span>
                            <strong id="paymentDeadlineCountdown" class="text-warning"><%=deadline.format(formatter)%></strong>
                        </div>
                        <% } %>
                        <div class="order-summary-row">
                            <span>Shipping</span>
                            <strong>
                                <% if (shippingCost.compareTo(BigDecimal.ZERO) == 0) { %>
                                    Free
                                <% } else { %>
                                    <%=shippingCostDisplay%>
                                <% } %>
                            </strong>
                        </div>
                        <div class="order-summary-row">
                            <span>Insurance & Handling</span>
                            <strong>Included</strong>
                        </div>
                        <div class="order-summary-row">
                            <span>Estimated Delivery</span>
                            <strong>5 - 7 working days</strong>
                        </div>
                        
                        <div class="order-summary-row order-total-row">
                            <span>Total (incl. tax)</span>
                            <span><%=totalCostDisplay%></span>
                        </div>
                        
                        <div class="d-grid gap-2 mt-4">
                            <button type="button"
                                    class="btn btn-success btn-lg"
                                    id="completeCheckoutBtn"
                                    onclick="completeCheckout()"
                                    <%=checkoutDisabled ? "disabled" : ""%>>
                                <i class="fas fa-lock me-2"></i><%=checkoutDisabled ? "Unavailable" : "Pay & Complete Order"%>
                            </button>
                            <small class="text-muted text-center">
                                You will be charged <strong><%=totalCostDisplay%></strong>
                            </small>
                        </div>
                        
                        <div class="mt-4 p-3 bg-light rounded">
                            <div class="d-flex align-items-center">
                                <i class="fas fa-shield-alt text-success me-2"></i>
                                <div>
                                    <strong>Buyer Protection</strong>
                                    <p class="small mb-0 text-muted">
                                        Full refund guarantee if artwork is not as described or damaged during transit.
                                    </p>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="card checkout-card checkout-support-card">
                    <div class="card-header">
                        <h6 class="mb-0"><i class="fas fa-headset me-2 text-primary"></i>Need assistance?</h6>
                    </div>
                    <div class="card-body">
                        <ul class="list-unstyled mb-3">
                            <li><i class="fas fa-phone text-primary"></i><span>+60 12-345 6789 (9am - 6pm MYT)</span></li>
                            <li><i class="fas fa-envelope text-primary"></i><span>support@artexchange.com</span></li>
                            <li><i class="fas fa-comments text-primary"></i><span>Live chat with art advisors</span></li>
                        </ul>
                        <small class="text-muted">
                            We'll keep you updated via email and messages once the artist confirms your order.
                        </small>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- Firebase & Auth -->
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.0.0/firebase-auth-compat.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/firebase-config.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/auth.js"></script>
    <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    
    <script>
        const checkoutState = {
            artworkId: '<%=artwork.getArtworkId()%>',
            purchaseId: '<%=isAuctionWin && purchase != null ? purchase.getPurchaseId() : ""%>',
            isAuctionWin: <%=isAuctionWin%>,
            price: parseFloat('<%=artworkPriceValue%>'),
            shippingCost: parseFloat('<%=shippingCostValue%>'),
            total: parseFloat('<%=totalCostValue%>'),
            checkoutDisabled: <%=checkoutDisabled%>
        };
        const apiBase = '${pageContext.request.contextPath}/api/artworks/';
        const purchaseApiBase = '${pageContext.request.contextPath}/api/purchases/';
        const receiptPageUrl = window.location.origin + '${pageContext.request.contextPath}/receipt/';
        
        <% if (isAuctionWin && purchase != null && purchase.getPaymentDeadline() != null) { %>
        const paymentDeadline = new Date('<%=purchase.getPaymentDeadline().toString()%>');
        <% } else { %>
        const paymentDeadline = null;
        <% } %>
        
        document.addEventListener('DOMContentLoaded', function() {
            initializeAuth();
            prefillCheckoutForm();
            
            // Start payment deadline countdown if this is an auction win
            if (paymentDeadline && checkoutState.isAuctionWin) {
                startPaymentCountdown();
            }
        });
        
        function startPaymentCountdown() {
            const countdownElement = document.getElementById('paymentDeadlineCountdown');
            if (!countdownElement || !paymentDeadline) return;
            
            function updateCountdown() {
                const now = new Date();
                const diff = paymentDeadline - now;
                
                if (diff <= 0) {
                    countdownElement.innerHTML = '<span class="text-danger"><i class="fas fa-exclamation-triangle me-1"></i>Payment deadline expired</span>';
                    checkoutState.checkoutDisabled = true;
                    const checkoutBtn = document.getElementById('completeCheckoutBtn');
                    if (checkoutBtn) {
                        checkoutBtn.disabled = true;
                        checkoutBtn.innerHTML = '<i class="fas fa-ban me-2"></i>Payment Expired';
                    }
                    return;
                }
                
                const hours = Math.floor(diff / (1000 * 60 * 60));
                const minutes = Math.floor((diff % (1000 * 60 * 60)) / (1000 * 60));
                const seconds = Math.floor((diff % (1000 * 60)) / 1000);
                
                countdownElement.innerHTML = '<span class="text-warning"><i class="fas fa-clock me-1"></i>' + 
                    hours + 'h ' + minutes + 'm ' + seconds + 's remaining</span>';
            }
            
            updateCountdown();
            setInterval(updateCountdown, 1000);
        }
        
        function prefillCheckoutForm(attempt = 0) {
            if (typeof currentUser !== 'undefined' && currentUser) {
                setIfEmpty('contactFirstName', currentUser.firstName || '');
                setIfEmpty('contactLastName', currentUser.lastName || '');
                setIfEmpty('contactEmail', currentUser.email || '');
                setIfEmpty('contactPhone', currentUser.phone || '');
                setIfEmpty('city', currentUser.city || '');
                setIfEmpty('country', currentUser.country || 'Malaysia');
            } else if (attempt < 10) {
                setTimeout(() => prefillCheckoutForm(attempt + 1), 400);
            }
        }
        
        function setIfEmpty(fieldId, value) {
            const field = document.getElementById(fieldId);
            if (field && !field.value && value) {
                field.value = value;
            }
        }
        
        function buildShippingAddress() {
            const requiredFields = ['addressLine1', 'city', 'stateRegion', 'postalCode', 'country'];
            for (const id of requiredFields) {
                const field = document.getElementById(id);
                if (!field || !field.value.trim()) {
                    return '';
                }
            }
            
            const parts = [
                document.getElementById('addressLine1').value.trim(),
                document.getElementById('addressLine2').value.trim(),
                document.getElementById('city').value.trim(),
                document.getElementById('stateRegion').value.trim(),
                document.getElementById('postalCode').value.trim(),
                document.getElementById('country').value.trim()
            ];
            
            return parts.filter(Boolean).join(', ');
        }
        
        function completeCheckout() {
            if (checkoutState.checkoutDisabled) {
                return;
            }
            
            if (!isLoggedIn()) {
                showInfoMessage('Please login to complete your purchase.');
                showLoginModal();
                return;
            }
            
            const form = document.getElementById('checkoutForm');
            if (!form.checkValidity()) {
                form.reportValidity();
                return;
            }
            
            const selectedPayment = document.querySelector('input[name="paymentMethod"]:checked');
            if (!selectedPayment) {
                showErrorMessage('Please select a payment method.');
                return;
            }
            
            const shippingAddress = buildShippingAddress();
            if (!shippingAddress) {
                showErrorMessage('Please complete your shipping address.');
                return;
            }
            
            const payload = {
                paymentMethod: selectedPayment.value,
                shippingAddress: shippingAddress,
                notes: document.getElementById('orderNotes').value.trim()
            };
            
            const checkoutBtn = document.getElementById('completeCheckoutBtn');
            const originalLabel = checkoutBtn.innerHTML;
            checkoutBtn.disabled = true;
            checkoutBtn.innerHTML = '<i class="fas fa-spinner fa-spin me-2"></i>Processing...';
            
            // Use different endpoint for auction wins vs regular purchases
            const apiUrl = checkoutState.isAuctionWin && checkoutState.purchaseId
                ? purchaseApiBase + checkoutState.purchaseId + '/complete-payment'
                : apiBase + checkoutState.artworkId + '/purchase';
            
            fetch(apiUrl, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                credentials: 'include',
                body: JSON.stringify(payload)
            })
            .then(response => response.json())
            .then(data => {
                if (data.success) {
                    checkoutState.checkoutDisabled = true;
                    showCheckoutSuccess(data);
                } else {
                    throw new Error(data.message || 'Purchase failed.');
                }
            })
            .catch(error => {
                console.error('Checkout error:', error);
                showErrorMessage(error.message || 'Unable to complete purchase.');
            })
            .finally(() => {
                if (!checkoutState.checkoutDisabled) {
                    checkoutBtn.disabled = false;
                    checkoutBtn.innerHTML = originalLabel;
                }
            });
        }
        
        function showCheckoutSuccess(data) {
            const alert = document.getElementById('checkoutSuccessAlert');
            alert.innerHTML = '<i class="fas fa-check-circle me-2"></i>' +
                'Thank you! Your order is confirmed. Transaction ID: <strong>' + data.transactionId + '</strong>.';
            alert.classList.remove('d-none');
            
            showSuccessMessage('Purchase completed successfully!');
            
            const checkoutBtn = document.getElementById('completeCheckoutBtn');
            checkoutBtn.innerHTML = '<i class="fas fa-check me-2"></i>Order Completed';
            checkoutBtn.classList.remove('btn-success');
            checkoutBtn.classList.add('btn-secondary');
            checkoutBtn.disabled = true;
            
            document.getElementById('checkoutForm').reset();

            if (data.purchaseId) {
                setTimeout(() => {
                    window.location.href = receiptPageUrl + data.purchaseId;
                }, 1500);
            }
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
</body>
</html>

