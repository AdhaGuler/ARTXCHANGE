/**
 * User Menu Dropdown Component
 * Handles user menu dropdown with keyboard navigation and accessibility
 * Uses portal approach (renders to body) to avoid clipping issues
 */

class UserMenu {
  constructor() {
    this.trigger = document.getElementById('userMenuTrigger');
    this.originalDropdown = document.getElementById('userMenuDropdown');
    this.dropdown = null; // Will be cloned and moved to body
    this.isOpen = false;
    this.currentMenuItem = -1;
    this.menuItems = [];
    this.clickOutsideHandler = null;
    this.keydownHandler = null;

    this.init();
  }

  init() {
    if (!this.trigger || !this.originalDropdown) {
      console.warn('User menu elements not found', {
        trigger: !!this.trigger,
        dropdown: !!this.originalDropdown
      });
      return;
    }

    // Get all menu items from original dropdown
    this.menuItems = Array.from(this.originalDropdown.querySelectorAll('[role="menuitem"]'));

    // Click trigger to toggle
    this.trigger.addEventListener('click', (e) => {
      e.stopPropagation();
      e.preventDefault();
      this.toggle();
    });

    // Keyboard support for trigger
    this.trigger.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        this.open();
      } else if (e.key === 'ArrowDown') {
        e.preventDefault();
        this.open();
        setTimeout(() => this.focusMenuItem(0), 50);
      }
    });

    // Set up click outside handler
    this.clickOutsideHandler = (e) => {
      if (this.isOpen && 
          this.dropdown && 
          !this.dropdown.contains(e.target) && 
          !this.trigger.contains(e.target)) {
        this.close();
      }
    };

    // Set up ESC handler
    this.keydownHandler = (e) => {
      if (e.key === 'Escape' && this.isOpen) {
        this.close();
        this.trigger.focus();
      }
    };

    document.addEventListener('click', this.clickOutsideHandler);
    document.addEventListener('keydown', this.keydownHandler);
  }

  toggle() {
    if (this.isOpen) {
      this.close();
    } else {
      this.open();
    }
  }

  getTriggerPosition() {
    const rect = this.trigger.getBoundingClientRect();
    const scrollY = window.pageYOffset || document.documentElement.scrollTop;
    const scrollX = window.pageXOffset || document.documentElement.scrollLeft;
    
    return {
      top: rect.bottom + scrollY + 8,
      right: window.innerWidth - rect.right + scrollX
    };
  }

  open() {
    if (this.isOpen) return;

    this.isOpen = true;
    this.trigger.setAttribute('aria-expanded', 'true');

    // Clone the dropdown and move it to body (portal approach)
    this.dropdown = this.originalDropdown.cloneNode(true);
    this.dropdown.id = 'userMenuDropdownPortal';
    this.dropdown.classList.add('user-menu-dropdown-portal');
    
    // Get fresh menu items from cloned dropdown
    this.menuItems = Array.from(this.dropdown.querySelectorAll('[role="menuitem"]'));

    // Set up event handlers for cloned dropdown
    this.setupDropdownEvents();

    // Position the dropdown
    const position = this.getTriggerPosition();
    this.dropdown.style.position = 'fixed';
    this.dropdown.style.top = `${position.top}px`;
    this.dropdown.style.right = `${position.right}px`;
    this.dropdown.style.zIndex = '9999';
    this.dropdown.style.display = 'block';
    this.dropdown.style.opacity = '0';
    this.dropdown.style.visibility = 'hidden';
    this.dropdown.style.transform = 'translateY(-8px)';
    this.dropdown.style.pointerEvents = 'none';

    // Append to body
    document.body.appendChild(this.dropdown);

    // Force reflow
    this.dropdown.offsetHeight;

    // Animate in
    requestAnimationFrame(() => {
      if (this.isOpen && this.dropdown) {
        this.dropdown.classList.add('show');
        this.dropdown.style.opacity = '1';
        this.dropdown.style.visibility = 'visible';
        this.dropdown.style.pointerEvents = 'auto';
        this.dropdown.style.transform = 'translateY(0)';
      }
    });

    // Update position on scroll/resize
    this.updatePosition = () => {
      if (this.isOpen && this.dropdown && this.trigger) {
        const pos = this.getTriggerPosition();
        this.dropdown.style.top = `${pos.top}px`;
        this.dropdown.style.right = `${pos.right}px`;
        
        // Ensure dropdown doesn't overflow viewport on mobile
        const dropdownRect = this.dropdown.getBoundingClientRect();
        const scrollY = window.pageYOffset || document.documentElement.scrollTop;
        
        if (dropdownRect.left < 0) {
          this.dropdown.style.right = '8px';
          this.dropdown.style.left = 'auto';
        }
        if (dropdownRect.bottom > window.innerHeight) {
          const triggerRect = this.trigger.getBoundingClientRect();
          this.dropdown.style.top = `${triggerRect.top + scrollY - dropdownRect.height - 8}px`;
        }
      }
    };
    window.addEventListener('scroll', this.updatePosition, true);
    window.addEventListener('resize', this.updatePosition);
  }

  close() {
    if (!this.isOpen) return;

    this.isOpen = false;
    this.trigger.setAttribute('aria-expanded', 'false');

    if (this.dropdown) {
      // Animate out
      this.dropdown.style.opacity = '0';
      this.dropdown.style.visibility = 'hidden';
      this.dropdown.style.pointerEvents = 'none';
      this.dropdown.style.transform = 'translateY(-8px)';
      this.dropdown.classList.remove('show');

      // Remove from DOM after animation
      setTimeout(() => {
        if (this.dropdown && this.dropdown.parentNode) {
          this.dropdown.parentNode.removeChild(this.dropdown);
        }
        this.dropdown = null;
        this.menuItems = [];
      }, 150);
    }

    // Remove position update listeners
    if (this.updatePosition) {
      window.removeEventListener('scroll', this.updatePosition, true);
      window.removeEventListener('resize', this.updatePosition);
      this.updatePosition = null;
    }

    this.currentMenuItem = -1;
  }

  setupDropdownEvents() {
    if (!this.dropdown) return;

    // Keyboard navigation in menu
    this.dropdown.addEventListener('keydown', (e) => {
      this.handleMenuKeydown(e);
    });

    // Handle menu item clicks
    this.menuItems.forEach((item) => {
      item.addEventListener('click', (e) => {
        // For buttons (like logout), prevent default and let onclick handle it
        if (item.tagName === 'BUTTON') {
          // onclick handler will be called
        }
        // Close menu after a short delay to allow navigation
        setTimeout(() => {
          this.close();
        }, 100);
      });
    });
  }

  focusMenuItem(index) {
    if (index < 0 || index >= this.menuItems.length) return;

    this.currentMenuItem = index;
    if (this.menuItems[index]) {
      this.menuItems[index].focus();
    }
  }

  handleMenuKeydown(e) {
    if (!this.isOpen) return;

    switch (e.key) {
      case 'ArrowDown':
        e.preventDefault();
        this.currentMenuItem = (this.currentMenuItem + 1) % this.menuItems.length;
        this.focusMenuItem(this.currentMenuItem);
        break;

      case 'ArrowUp':
        e.preventDefault();
        this.currentMenuItem = this.currentMenuItem <= 0 
          ? this.menuItems.length - 1 
          : this.currentMenuItem - 1;
        this.focusMenuItem(this.currentMenuItem);
        break;

      case 'Home':
        e.preventDefault();
        this.focusMenuItem(0);
        break;

      case 'End':
        e.preventDefault();
        this.focusMenuItem(this.menuItems.length - 1);
        break;

      case 'Enter':
      case ' ':
        e.preventDefault();
        if (this.currentMenuItem >= 0 && this.currentMenuItem < this.menuItems.length) {
          const item = this.menuItems[this.currentMenuItem];
          if (item.tagName === 'A') {
            window.location.href = item.href;
          } else if (item.tagName === 'BUTTON') {
            item.click();
          }
        }
        break;

      case 'Escape':
        e.preventDefault();
        this.close();
        this.trigger.focus();
        break;
    }
  }

  destroy() {
    this.close();
    if (this.clickOutsideHandler) {
      document.removeEventListener('click', this.clickOutsideHandler);
    }
    if (this.keydownHandler) {
      document.removeEventListener('keydown', this.keydownHandler);
    }
  }
}

// Initialize user menu when DOM is ready
let userMenuInstance = null;

function initUserMenu() {
  const trigger = document.getElementById('userMenuTrigger');
  const dropdown = document.getElementById('userMenuDropdown');
  
  if (trigger && dropdown) {
    if (!userMenuInstance) {
      userMenuInstance = new UserMenu();
      console.log('User menu initialized successfully');
    }
  } else {
    // Retry if elements not found
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', initUserMenu);
    } else {
      setTimeout(initUserMenu, 200);
    }
  }
}

// Try to initialize
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initUserMenu);
} else {
  setTimeout(initUserMenu, 100);
}

// Also try after a short delay to catch late-loading elements
setTimeout(initUserMenu, 500);

// Handle logout
function handleLogout() {
  // Close menu first
  if (userMenuInstance) {
    userMenuInstance.close();
  }

  // Check if logout function exists in auth.js
  if (typeof logout === 'function') {
    logout().then(() => {
      window.location.href = '/';
    }).catch((error) => {
      console.error('Logout error:', error);
      window.location.href = '/';
    });
  } else {
    // Fallback logout - use Firebase auth directly
    if (typeof firebase !== 'undefined' && firebase.auth) {
      firebase.auth().signOut().then(() => {
        fetch('/auth/logout', { method: 'POST' }).catch(() => {
          // Ignore errors
        }).finally(() => {
          window.location.href = '/';
        });
      }).catch((error) => {
        console.error('Logout error:', error);
        window.location.href = '/';
      });
    } else {
      window.location.href = '/';
    }
  }
}
