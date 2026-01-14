// Authentication functionality

let currentUser = null;

// Initialize authentication state
document.addEventListener('DOMContentLoaded', function() {
    // Ensure Artists link is visible by default (public access)
    // Call multiple times to ensure it works even if DOM loads slowly
    ensureArtistsLinkVisible();
    setTimeout(ensureArtistsLinkVisible, 50);
    setTimeout(ensureArtistsLinkVisible, 100);
    setTimeout(ensureArtistsLinkVisible, 300);
    setTimeout(ensureArtistsLinkVisible, 500);
    setTimeout(ensureArtistsLinkVisible, 1000);
    
    checkAuthState();
    
    // Set up a MutationObserver to watch for any changes that might hide Artists link
    const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
            if (mutation.type === 'attributes' && mutation.attributeName === 'style') {
                const artistsLink = document.querySelector('a[href*="artists.jsp"]');
                if (artistsLink) {
                    const parentLi = artistsLink.closest('li.nav-item') || artistsLink.parentElement;
                    if (parentLi && (parentLi.style.display === 'none' || parentLi.classList.contains('d-none'))) {
                        console.warn('Artists link was hidden! Re-showing...');
                        ensureArtistsLinkVisible();
                    }
                }
            }
        });
    });
    
    // Observe the navbar for changes
    const navbar = document.querySelector('.navbar-nav');
    if (navbar) {
        observer.observe(navbar, {
            attributes: true,
            attributeFilter: ['style', 'class'],
            subtree: true
        });
    }
});

// Ensure Artists navigation link is always visible (public access)
// This function MUST be called to guarantee Artists link visibility for buyers
function ensureArtistsLinkVisible() {
    // Use multiple selectors to find Artists link
    const artistsLink = document.querySelector('a[href*="artists.jsp"]') || 
                        document.querySelector('a[href*="/artists"]') ||
                        document.querySelector('a[href="artists.jsp"]');
    
    if (artistsLink) {
        const parentLi = artistsLink.closest('li.nav-item') || artistsLink.parentElement;
        if (parentLi) {
            // Force visibility with multiple methods
            parentLi.style.display = 'block';
            parentLi.style.visibility = 'visible';
            parentLi.removeAttribute('hidden');
            parentLi.classList.remove('d-none');
            // Use setAttribute to override any inline styles
            parentLi.setAttribute('style', 'display: block !important; visibility: visible !important;');
            console.log('Artists link FORCED visible (ensureArtistsLinkVisible) - parent:', parentLi);
        } else {
            console.warn('Artists link found but parent element not found');
        }
    } else {
        console.warn('Artists link not found in DOM - checking all nav links...');
        // Debug: log all nav links
        const allNavLinks = document.querySelectorAll('.navbar-nav a.nav-link');
        console.log('All nav links found:', allNavLinks.length);
        allNavLinks.forEach((link, index) => {
            console.log(`Nav link ${index}:`, link.href, link.textContent.trim());
        });
    }
}

// Check authentication state
function checkAuthState() {
    const loading = showLoadingOverlay();
    
    firebaseAuth.onAuthStateChanged(async (user) => {
        hideLoadingOverlay(loading);
        
        if (user) {
            try {
                // Verify token with backend
                const idToken = await user.getIdToken();
                const response = await fetch('/auth/verify-token', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                    },
                    body: JSON.stringify({ idToken: idToken })
                });
                
                if (response.ok) {
                    const data = await response.json();
                    if (data.success && data.user) {
                        currentUser = data.user;
                        updateUIForLoggedInUser(currentUser);
                    } else {
                        console.warn('User verification failed:', data.message);
                        updateUIForLoggedOutUser();
                    }
                } else if (response.status === 404) {
                    console.warn('User not found in database, user might need to complete registration');
                    updateUIForLoggedOutUser();
                } else {
                    console.error('Authentication verification failed with status:', response.status);
                    updateUIForLoggedOutUser();
                }
            } catch (error) {
                console.error('Auth verification error:', error);
                updateUIForLoggedOutUser();
            }
        } else {
            currentUser = null;
            updateUIForLoggedOutUser();
        }
    });
}

// Sign in with email and password
async function signInWithEmail() {
    try {
        showLoadingInModal('login');
        
        const emailField = document.getElementById('loginEmail');
        const passwordField = document.getElementById('loginPassword');
        
        if (!emailField || !passwordField) {
            handleAuthError('Login form elements not found');
            hideLoadingInModal('login');
            return;
        }
        
        const email = emailField.value.trim();
        const password = passwordField.value;
        
        // Validate inputs
        if (!email || !password) {
            handleAuthError('Please enter both email and password');
            hideLoadingInModal('login');
            return;
        }
        
        if (!isValidEmail(email)) {
            handleAuthError('Please enter a valid email address');
            hideLoadingInModal('login');
            return;
        }
        
        // Sign in with Firebase
        const result = await firebaseAuth.signInWithEmailAndPassword(email, password);
        const user = result.user;
        const idToken = await user.getIdToken();
        
        // Send token to backend for verification
        const response = await fetch('/auth/login', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({ idToken: idToken })
        });
        
        const data = await response.json();
        
        if (response.ok && data.success) {
            currentUser = data.user;
            updateUIForLoggedInUser(currentUser);
            hideModal('loginModal');
            showSuccessMessage('Login successful!');
        } else {
            if (response.status === 401) {
                // User not registered, redirect to registration
                showRegisterModal();
                showInfoMessage('Please complete your registration to continue.');
            } else {
                handleAuthError(data.message || 'Login failed');
            }
        }
    } catch (error) {
        console.error('Login error:', error);
        let errorMessage = 'Login failed. Please try again.';
        
        // Handle specific Firebase Auth errors
        switch (error.code) {
            case 'auth/user-not-found':
                errorMessage = 'No account found with this email address.';
                break;
            case 'auth/wrong-password':
                errorMessage = 'Incorrect password. Please try again.';
                break;
            case 'auth/too-many-requests':
                errorMessage = 'Too many failed attempts. Please try again later.';
                break;
            case 'auth/user-disabled':
                errorMessage = 'This account has been disabled.';
                break;
            case 'auth/invalid-email':
                errorMessage = 'Invalid email address format.';
                break;
        }
        
        handleAuthError(errorMessage);
    } finally {
        hideLoadingInModal('login');
    }
}

// Register with email and password
async function registerWithEmail() {
    try {
        showLoadingInModal('register');
        
        const emailField = document.getElementById('registerEmail');
        const passwordField = document.getElementById('registerPassword');
        const confirmPasswordField = document.getElementById('confirmPassword');
        const usernameField = document.getElementById('username');
        const firstNameField = document.getElementById('firstName');
        const lastNameField = document.getElementById('lastName');
        const roleField = document.getElementById('role');
        
        if (!emailField || !passwordField || !confirmPasswordField || !usernameField || 
            !firstNameField || !lastNameField || !roleField) {
            handleAuthError('Registration form elements not found');
            hideLoadingInModal('register');
            return;
        }
        
        const email = emailField.value.trim();
        const password = passwordField.value;
        const confirmPassword = confirmPasswordField.value;
        const username = usernameField.value.trim();
        const firstName = firstNameField.value.trim();
        const lastName = lastNameField.value.trim();
        const role = roleField.value;
        
        // Validate inputs
        if (!email || !password || !confirmPassword || !username || !firstName || !lastName || !role) {
            handleAuthError('Please fill in all required fields');
            hideLoadingInModal('register');
            return;
        }
        
        if (!isValidEmail(email)) {
            handleAuthError('Please enter a valid email address');
            hideLoadingInModal('register');
            return;
        }
        
        if (password.length < 6) {
            handleAuthError('Password must be at least 6 characters long');
            hideLoadingInModal('register');
            return;
        }
        
        if (password !== confirmPassword) {
            handleAuthError('Passwords do not match');
            hideLoadingInModal('register');
            return;
        }
        
        if (username.length < 3) {
            handleAuthError('Username must be at least 3 characters long');
            hideLoadingInModal('register');
            return;
        }
        
        // Create Firebase user
        const result = await firebaseAuth.createUserWithEmailAndPassword(email, password);
        const user = result.user;
        const idToken = await user.getIdToken();
        
        // Prepare registration data
        const registrationData = {
            idToken: idToken,
            username: username,
            firstName: firstName,
            lastName: lastName,
            role: role,
            bio: '',
            phone: '',
            city: '',
            country: 'Malaysia'
        };
        
        // Send registration data to backend
        const response = await fetch('/auth/register', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(registrationData)
        });
        
        const data = await response.json();
        console.log('Registration response:', { status: response.status, data });
        
        if (response.ok && data.success) {
            currentUser = data.user;
            updateUIForLoggedInUser(currentUser);
            hideModal('registerModal');
            showSuccessMessage('Registration successful! Welcome to ArtXchange!');
        } else {
            // If backend registration fails, delete the Firebase user
            if (user) {
                await user.delete();
            }
            
            if (response.status === 409) {
                handleAuthError(data.message || 'Username or email already exists');
            } else {
                handleAuthError(data.message || 'Registration failed');
            }
        }
    } catch (error) {
        console.error('Registration error:', error);
        let errorMessage = 'Registration failed. Please try again.';
        
        // Handle specific Firebase Auth errors
        switch (error.code) {
            case 'auth/email-already-in-use':
                errorMessage = 'An account with this email already exists.';
                break;
            case 'auth/weak-password':
                errorMessage = 'Password is too weak. Please choose a stronger password.';
                break;
            case 'auth/invalid-email':
                errorMessage = 'Invalid email address format.';
                break;
            case 'auth/operation-not-allowed':
                errorMessage = 'Email/password accounts are not enabled. Please contact support.';
                break;
        }
        
        handleAuthError(errorMessage);
    } finally {
        hideLoadingInModal('register');
    }
}

// Logout
async function logout() {
    try {
        const loading = showLoadingOverlay();
        
        // Sign out from Firebase
        await firebaseAuth.signOut();
        
        // Clear session on backend
        await fetch('/auth/logout', {
            method: 'POST'
        });
        
        currentUser = null;
        updateUIForLoggedOutUser();
        showSuccessMessage('Logged out successfully');
        
        hideLoadingOverlay(loading);
    } catch (error) {
        console.error('Logout error:', error);
        handleAuthError('Logout failed');
    }
}

// Update UI for logged in user
function updateUIForLoggedInUser(user) {
    const authButtons = document.getElementById('auth-buttons');
    const userMenu = document.getElementById('user-menu');
    const userName = document.getElementById('user-name');
    
    if (authButtons) authButtons.classList.add('d-none');
    if (userMenu) userMenu.classList.remove('d-none');
    if (userName) userName.textContent = user.firstName || user.username;
    
    // Ensure Artists link is visible (public access for all users including buyers)
    ensureArtistsLinkVisible();
    
    // Update navigation based on user role
    updateNavigationForUserRole(user);
    
    // Double-check Artists link visibility after navigation update (especially for buyers)
    setTimeout(ensureArtistsLinkVisible, 100);
    setTimeout(ensureArtistsLinkVisible, 500);
    
    // Hide modals if open
    hideModal('loginModal');
    hideModal('registerModal');
}

// Update navigation based on user role
function updateNavigationForUserRole(user) {
    console.log('updateNavigationForUserRole called with user:', user);
    console.log('User role:', user.role);
    
    // Get the current page to determine which navigation to update
    const currentPath = window.location.pathname;
    console.log('Current path:', currentPath);
    
    // Update main navigation items based on role
    updateMainNavigationForRole(user);
    
    // Only update user dropdown navigation on non-dashboard pages
    if (!currentPath.includes('dashboard.jsp')) {
        const userMenuDropdown = document.querySelector('#user-menu .dropdown-menu');
        console.log('User menu dropdown found:', !!userMenuDropdown);
        
        if (userMenuDropdown && user.role) {
            // Clear existing menu items and rebuild based on role
            userMenuDropdown.innerHTML = '';
            
            // Common menu items for all users
            userMenuDropdown.innerHTML += 
                '<li><a class="dropdown-item" href="' + getContextPath() + '/profile.jsp">My Profile</a></li>';
            
            // Role-specific menu items
            if (user.role === 'ARTIST') {
                console.log('Adding artist menu items');
                userMenuDropdown.innerHTML += 
                    '<li><a class="dropdown-item" href="' + getContextPath() + '/dashboard.jsp">Artist Dashboard</a></li>';
            } else if (user.role === 'BUYER') {
                console.log('Adding buyer menu items');
                userMenuDropdown.innerHTML += 
                    '<li><a class="dropdown-item" href="' + getContextPath() + '/dashboard.jsp">My Dashboard</a></li>';
            }
            
            // Common menu items
            userMenuDropdown.innerHTML += 
                '<li><a class="dropdown-item" href="' + getContextPath() + '/messages.jsp">Messages</a></li>' +
                '<li><hr class="dropdown-divider"></li>' +
                '<li><a class="dropdown-item" href="#" onclick="logout()">Logout</a></li>';
                
            console.log('Updated dropdown innerHTML:', userMenuDropdown.innerHTML);
        }
    }
}

// Update main navigation items based on user role
function updateMainNavigationForRole(user) {
    // Find navigation items that should be role-specific
    const artistsLink = document.querySelector('a[href*="artists.jsp"]');
    const biddingsNav = document.getElementById('biddings-nav');
    const bidsTabNav = document.getElementById('bids-tab-nav');
    const bidsTab = document.getElementById('bids');
    
    console.log('=== updateMainNavigationForRole Debug ===');
    console.log('User role:', user ? user.role : 'guest');
    console.log('biddingsNav element found:', !!biddingsNav);
    console.log('bidsTabNav element found:', !!bidsTabNav);
    console.log('artistsLink element found:', !!artistsLink);
    
    // Artists link is PUBLIC - always visible for all users (buyers, artists, guests)
    // This is a public page, no role restriction - MUST be visible
    if (artistsLink) {
        const parentLi = artistsLink.closest('li.nav-item') || artistsLink.parentElement;
        if (parentLi) {
            parentLi.style.display = 'block';
            parentLi.style.visibility = 'visible';
            parentLi.removeAttribute('hidden');
            // Force visibility with !important via style attribute
            parentLi.setAttribute('style', 'display: block !important; visibility: visible !important;');
            console.log('Artists link is public - FORCED visible for all users (role:', user ? user.role : 'guest', ')');
        } else {
            console.warn('Artists link found but parent element not found');
        }
    } else {
        console.warn('Artists link not found in navigation - selector:', 'a[href*="artists.jsp"]');
        // Try alternative selector
        const altLink = document.querySelector('a[href*="/artists"]');
        if (altLink) {
            const parentLi = altLink.closest('li.nav-item') || altLink.parentElement;
            if (parentLi) {
                parentLi.style.display = 'block';
                parentLi.style.visibility = 'visible';
                console.log('Artists link found with alternative selector');
            }
        }
    }
    
    if (user && user.role === 'BUYER') {
        // CRITICAL: Ensure Artists link is visible for buyers (public access)
        ensureArtistsLinkVisible();
        
        // Show Biddings menu for buyers
        if (biddingsNav) {
            biddingsNav.style.display = 'block';
            console.log('Showing biddings menu for buyer');
        } else {
            console.log('ERROR: biddings-nav element not found for buyer');
        }
        
        // Show My Bids tab for buyers
        if (bidsTabNav) {
            bidsTabNav.style.display = 'block';
            console.log('Showing bids tab for buyer');
        }
        
        // Double-check Artists link after showing biddings (in case it got hidden)
        setTimeout(ensureArtistsLinkVisible, 50);
    } else if (user && user.role === 'ARTIST') {
        // Hide Biddings menu for artists
        if (biddingsNav) {
            biddingsNav.style.display = 'none';
            console.log('Hiding biddings menu for artist');
        }
        
        // Hide My Bids tab for artists (they see bids on their artworks in a different way)
        if (bidsTabNav) {
            bidsTabNav.style.display = 'none';
            console.log('Hiding bids tab for artist');
        }
    } else {
        // For guests or other roles, hide biddings menu
        if (biddingsNav) {
            biddingsNav.style.display = 'none';
        }
        if (bidsTabNav) {
            bidsTabNav.style.display = 'none';
        }
    }
}

// Helper function to get context path
function getContextPath() {
    return window.location.origin;
}

// Update UI for logged out user
function updateUIForLoggedOutUser() {
    const authButtons = document.getElementById('auth-buttons');
    const userMenu = document.getElementById('user-menu');
    
    if (authButtons) authButtons.classList.remove('d-none');
    if (userMenu) userMenu.classList.add('d-none');
    
    // Ensure Artists link is visible for guests (public access)
    ensureArtistsLinkVisible();
    
    // Update navigation for guests
    updateMainNavigationForRole(null);
    
    // Double-check Artists link visibility after navigation update
    setTimeout(ensureArtistsLinkVisible, 100);
}

// Show login modal
function showLoginModal() {
    hideModal('registerModal');
    showModal('loginModal');
}

// Show register modal
function showRegisterModal() {
    hideModal('loginModal');
    showModal('registerModal');
}

// Email validation helper
function isValidEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return emailRegex.test(email);
}

// Check if user is logged in
function isLoggedIn() {
    return currentUser !== null;
}

// Handle login form submission
const loginForm = document.getElementById('login-form');
if (loginForm) {
    loginForm.addEventListener('submit', function(e) {
        e.preventDefault();
        signInWithEmail();
    });
}

// Handle registration form submission
const registerForm = document.getElementById('register-form');
if (registerForm) {
    registerForm.addEventListener('submit', function(e) {
        e.preventDefault();
        registerWithEmail();
    });
}

// Show modal
function showModal(modalId) {
    const modalElement = document.getElementById(modalId);
    if (modalElement) {
        const modal = new bootstrap.Modal(modalElement);
        modal.show();
    }
}

// Hide modal
function hideModal(modalId) {
    const modalElement = document.getElementById(modalId);
    if (modalElement) {
        const modal = bootstrap.Modal.getInstance(modalElement);
        if (modal) {
            modal.hide();
        }
    }
}

// Show loading in modal
function showLoadingInModal(type) {
    if (type === 'login') {
        const loginForm = document.getElementById('login-form-container');
        const loginLoading = document.getElementById('login-loading');
        if (loginForm) loginForm.classList.add('d-none');
        if (loginLoading) loginLoading.classList.remove('d-none');
    } else if (type === 'register') {
        const registerForm = document.getElementById('register-form');
        const registerLoading = document.getElementById('register-loading');
        if (registerForm) registerForm.classList.add('d-none');
        if (registerLoading) registerLoading.classList.remove('d-none');
    }
}

// Hide loading in modal
function hideLoadingInModal(type) {
    if (type === 'login') {
        const loginForm = document.getElementById('login-form-container');
        const loginLoading = document.getElementById('login-loading');
        if (loginForm) loginForm.classList.remove('d-none');
        if (loginLoading) loginLoading.classList.add('d-none');
    } else if (type === 'register') {
        const registerLoading = document.getElementById('register-loading');
        const registerForm = document.getElementById('register-form');
        if (registerLoading) registerLoading.classList.add('d-none');
        if (registerForm) registerForm.classList.remove('d-none');
    }
}

// Show loading overlay
function showLoadingOverlay() {
    const overlay = document.createElement('div');
    overlay.className = 'loading-overlay';
    overlay.innerHTML = `
        <div class="spinner-border-custom"></div>
    `;
    document.body.appendChild(overlay);
    return overlay;
}

// Hide loading overlay
function hideLoadingOverlay(overlay) {
    if (overlay && overlay.parentNode) {
        overlay.parentNode.removeChild(overlay);
    }
}

// Handle authentication errors
function handleAuthError(message) {
    showErrorMessage(message);
}

// Initialize authentication (alias for checkAuthState for compatibility)
function initializeAuth() {
    checkAuthState();
}

// Show success message
function showSuccessMessage(message) {
    showMessage(message, 'success');
}

// Show error message
function showErrorMessage(message) {
    showMessage(message, 'danger');
}

// Show info message
function showInfoMessage(message) {
    showMessage(message, 'info');
}

// Show message
function showMessage(message, type) {
    // Create toast element
    const toast = document.createElement('div');
    toast.className = `toast align-items-center text-white bg-${type} border-0`;
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');
    toast.setAttribute('aria-atomic', 'true');
    
    toast.innerHTML = `
        <div class="d-flex">
            <div class="toast-body">
                ${message}
            </div>
            <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
        </div>
    `;
    
    // Add to toast container
    let toastContainer = document.getElementById('toast-container');
    if (!toastContainer) {
        toastContainer = document.createElement('div');
        toastContainer.id = 'toast-container';
        toastContainer.className = 'toast-container position-fixed top-0 end-0 p-3';
        toastContainer.style.zIndex = '1050';
        document.body.appendChild(toastContainer);
    }
    
    toastContainer.appendChild(toast);
    
    // Show toast
    const bsToast = new bootstrap.Toast(toast);
    bsToast.show();
    
    // Remove from DOM after hiding
    toast.addEventListener('hidden.bs.toast', function() {
        toast.remove();
    });
}
