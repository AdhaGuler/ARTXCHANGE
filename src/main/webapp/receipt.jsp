<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.artexchange.model.Purchase" %>
<%@ page import="com.artexchange.model.Artwork" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.ZoneId" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<%
    Purchase purchase = (Purchase) request.getAttribute("purchase");
    Artwork artwork = (Artwork) request.getAttribute("artwork");
    Boolean isBuyerAttr = (Boolean) request.getAttribute("isBuyer");
    boolean isBuyer = isBuyerAttr != null && isBuyerAttr;

    if (purchase == null) {
        response.sendRedirect(request.getContextPath() + "/dashboard.jsp");
        return;
    }

    DecimalFormat moneyFormat = new DecimalFormat("#,##0.00");
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a").withZone(ZoneId.systemDefault());

    String artworkTitle = artwork != null ? artwork.getTitle() : "Artwork";
    String artworkImage = artwork != null && artwork.getPrimaryImageUrl() != null
            ? artwork.getPrimaryImageUrl()
            : (request.getContextPath() + "/assets/images/placeholder-artwork.jpg");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receipt - <%=artworkTitle%> | ArtXchange</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/main.css">
    <style>
        body {
            background: #f5f7fb;
        }
        .receipt-card {
            border: none;
            border-radius: 1rem;
            box-shadow: 0 20px 40px rgba(15, 23, 42, 0.08);
        }
        .receipt-header {
            background: linear-gradient(135deg, #1f2937 0%, #111827 100%);
            color: #fff;
            border-radius: 1rem 1rem 0 0;
            padding: 2rem;
        }
        .receipt-status {
            padding: 0.4rem 0.9rem;
            border-radius: 999px;
            font-weight: 600;
        }
        .status-success {
            background: rgba(25, 135, 84, 0.15);
            color: #d1fae5;
        }
        .status-pending {
            background: rgba(255, 193, 7, 0.2);
            color: #fff3cd;
        }
        .summary-row {
            display: flex;
            justify-content: space-between;
            margin-bottom: 0.7rem;
            font-size: 0.95rem;
        }
        .summary-row strong {
            color: #111827;
        }
        .qr-placeholder {
            width: 120px;
            height: 120px;
            background: #f1f5f9;
            border-radius: 0.75rem;
            display: flex;
            align-items: center;
            justify-content: center;
            color: #94a3b8;
            font-size: 0.85rem;
            font-weight: 600;
        }
    </style>
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="${pageContext.request.contextPath}/index.jsp">
                <i class="fas fa-palette me-2"></i>ArtXchange
            </a>
            <div class="collapse navbar-collapse">
                <ul class="navbar-nav ms-auto">
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/dashboard.jsp">Dashboard</a>
                    </li>
                    <li class="nav-item">
                        <a class="nav-link" href="${pageContext.request.contextPath}/browse.jsp">Browse</a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <div class="container my-5">
        <div class="card receipt-card">
            <div class="receipt-header">
                <div class="d-flex justify-content-between align-items-start flex-wrap gap-3">
                    <div>
                        <p class="text-uppercase small text-muted mb-1">Purchase Receipt</p>
                        <h2 class="fw-bold mb-1">Transaction #<%=purchase.getTransactionId()%></h2>
                        <p class="mb-0">
                            Completed on <%=purchase.getPurchaseDate() != null ? purchase.getPurchaseDate().format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")) : "N/A"%>
                        </p>
                    </div>
                    <div class="text-end">
                        <span class="receipt-status <%= "COMPLETED".equalsIgnoreCase(purchase.getStatus()) ? "status-success" : "status-pending"%>">
                            <i class="fas fa-check-circle me-1"></i><%=purchase.getStatus()%>
                        </span>
                        <p class="small mt-3 mb-0">
                            <strong>Purchase ID:</strong> <%=purchase.getPurchaseId()%>
                        </p>
                    </div>
                </div>
            </div>
            <div class="card-body p-4">
                <div class="row g-4">
                    <div class="col-lg-8">
                        <div class="d-flex gap-3 align-items-center flex-column flex-sm-row">
                            <img src="<%=artworkImage%>" alt="Artwork" class="rounded" style="width:140px;height:140px;object-fit:cover;">
                            <div>
                                <h4 class="mb-1"><%=artworkTitle%></h4>
                                <p class="text-muted mb-2">
                                    by <%=artwork != null ? artwork.getArtistName() : "Unknown Artist"%>
                                </p>
                                <span class="badge bg-light text-dark me-2">
                                    <i class="fas fa-tag me-1"></i><%=artwork != null && artwork.getCategory() != null ? artwork.getCategory().getDisplayName() : "Artwork"%>
                                </span>
                                <span class="badge bg-success-subtle text-success">
                                    <i class="fas fa-shipping-fast me-1"></i>
                                    Shipping: <%=purchase.getShippingAddress() != null ? "Arranged" : "Not specified"%>
                                </span>
                            </div>
                        </div>

                        <hr class="my-4">

                        <h6 class="text-uppercase text-muted mb-3">Order Summary</h6>
                        <div class="summary-row">
                            <span>Artwork Price</span>
                            <strong>RM <%=purchase.getPurchasePrice() != null ? moneyFormat.format(purchase.getPurchasePrice()) : "0.00"%></strong>
                        </div>
                        <div class="summary-row">
                            <span>Shipping</span>
                            <strong>
                                <% if (purchase.getShippingCost() == null || purchase.getShippingCost().doubleValue() == 0) { %>
                                    Free
                                <% } else { %>
                                    RM <%=moneyFormat.format(purchase.getShippingCost())%>
                                <% } %>
                            </strong>
                        </div>
                        <div class="summary-row">
                            <span>Payment Method</span>
                            <strong><%=purchase.getPaymentMethod() != null ? purchase.getPaymentMethod().replace('_', ' ').toUpperCase() : "N/A"%></strong>
                        </div>
                        <div class="summary-row">
                            <span>Status</span>
                            <strong><%=purchase.getStatus()%></strong>
                        </div>
                        <div class="summary-row" style="font-size:1.1rem;font-weight:700;">
                            <span>Total Paid</span>
                            <span>RM <%=purchase.getPurchasePrice() != null ? moneyFormat.format(purchase.getPurchasePrice()) : "0.00"%></span>
                        </div>

                        <hr class="my-4">

                        <div class="row g-3">
                            <div class="col-md-6">
                                <h6 class="text-uppercase text-muted">Shipping Address</h6>
                                <p class="mb-0"><%=purchase.getShippingAddress() != null ? purchase.getShippingAddress() : "Not provided"%></p>
                            </div>
                            <div class="col-md-6">
                                <h6 class="text-uppercase text-muted">Notes</h6>
                                <p class="mb-0"><%=purchase.getNotes() != null && !purchase.getNotes().isEmpty() ? purchase.getNotes() : "No additional notes"%></p>
                            </div>
                        </div>
                    </div>
                    <div class="col-lg-4">
                        <div class="p-4 bg-light rounded h-100">
                            <h6 class="text-uppercase text-muted mb-3">Receipt Summary</h6>
                            <p class="mb-1"><strong>Name:</strong> <%=isBuyer ? "Buyer" : "Seller"%></p>
                            <p class="mb-1"><strong>Transaction ID:</strong> <%=purchase.getTransactionId()%></p>
                            <p class="mb-1"><strong>Purchase Date:</strong> <%=purchase.getPurchaseDate() != null ? purchase.getPurchaseDate().format(java.time.format.DateTimeFormatter.ofPattern("dd MMM yyyy, hh:mm a")) : "N/A"%></p>

                            <div class="qr-placeholder mt-4 mx-auto">
                                QR Code
                            </div>
                            <p class="text-muted small text-center mt-3">
                                Save this receipt for your records. Contact support if you need further assistance.
                            </p>
                            <div class="d-grid gap-2 mt-3">
                                <a class="btn btn-primary" href="${pageContext.request.contextPath}/browse.jsp">
                                    <i class="fas fa-arrow-left me-1"></i>Back to Browse
                                </a>
                                <a class="btn btn-outline-secondary" href="#" onclick="window.print(); return false;">
                                    <i class="fas fa-print me-1"></i>Print Receipt
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

