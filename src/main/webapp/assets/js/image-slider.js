/**
 * Image Slider Component for Artwork Images
 * Supports multiple images with navigation arrows, thumbnails, and swipe gestures
 */

class ImageSlider {
    constructor(containerId, images, options = {}) {
        this.container = document.getElementById(containerId);
        if (!this.container) {
            console.error('Container not found:', containerId);
            return;
        }

        this.images = images && images.length > 0 ? images : [];
        this.currentIndex = 0;
        this.options = {
            showThumbnails: options.showThumbnails !== false,
            showArrows: options.showArrows !== false,
            autoPlay: options.autoPlay || false,
            autoPlayInterval: options.autoPlayInterval || 3000,
            showIndicators: options.showIndicators !== false,
            ...options
        };

        this.touchStartX = 0;
        this.touchEndX = 0;
        this.autoPlayTimer = null;

        this.init();
    }

    init() {
        if (this.images.length === 0) {
            this.renderEmpty();
            return;
        }

        this.render();
        this.attachEventListeners();
        
        if (this.options.autoPlay) {
            this.startAutoPlay();
        }
    }

    render() {
        const hasMultiple = this.images.length > 1;
        
        this.container.innerHTML = `
            <div class="image-slider-container">
                <div class="image-slider-main position-relative">
                    ${hasMultiple && this.options.showArrows ? `
                        <button class="slider-arrow slider-arrow-prev" aria-label="Previous image">
                            <i class="fas fa-chevron-left"></i>
                        </button>
                        <button class="slider-arrow slider-arrow-next" aria-label="Next image">
                            <i class="fas fa-chevron-right"></i>
                        </button>
                    ` : ''}
                    
                    <div class="slider-image-wrapper">
                        <img 
                            src="${this.images[this.currentIndex]}" 
                            alt="Artwork image ${this.currentIndex + 1}"
                            class="slider-main-image"
                            id="slider-main-image-${this.container.id}"
                        />
                        ${hasMultiple ? `
                            <div class="slider-image-counter">
                                ${this.currentIndex + 1} / ${this.images.length}
                            </div>
                        ` : ''}
                    </div>
                    
                    ${hasMultiple && this.options.showIndicators ? `
                        <div class="slider-indicators">
                            ${this.images.map((_, index) => `
                                <button 
                                    class="slider-indicator ${index === this.currentIndex ? 'active' : ''}"
                                    data-index="${index}"
                                    aria-label="Go to image ${index + 1}"
                                ></button>
                            `).join('')}
                        </div>
                    ` : ''}
                </div>
                
                ${hasMultiple && this.options.showThumbnails ? `
                    <div class="slider-thumbnails">
                        ${this.images.map((img, index) => `
                            <div 
                                class="thumbnail-item ${index === this.currentIndex ? 'active' : ''}"
                                data-index="${index}"
                            >
                                <img src="${img}" alt="Thumbnail ${index + 1}" />
                            </div>
                        `).join('')}
                    </div>
                ` : ''}
            </div>
        `;

        // Update active states
        this.updateActiveStates();
    }

    renderEmpty() {
        this.container.innerHTML = `
            <div class="image-slider-container">
                <div class="image-slider-main">
                    <img 
                        src="${this.options.placeholder || '/assets/images/placeholder-artwork.jpg'}" 
                        alt="No image available"
                        class="slider-main-image"
                    />
                </div>
            </div>
        `;
    }

    attachEventListeners() {
        if (this.images.length <= 1) return;

        // Arrow buttons
        const prevBtn = this.container.querySelector('.slider-arrow-prev');
        const nextBtn = this.container.querySelector('.slider-arrow-next');
        
        if (prevBtn) {
            prevBtn.addEventListener('click', () => this.prev());
        }
        if (nextBtn) {
            nextBtn.addEventListener('click', () => this.next());
        }

        // Thumbnail clicks
        const thumbnails = this.container.querySelectorAll('.thumbnail-item');
        thumbnails.forEach(thumb => {
            thumb.addEventListener('click', (e) => {
                const index = parseInt(e.currentTarget.dataset.index);
                this.goTo(index);
            });
        });

        // Indicator clicks
        const indicators = this.container.querySelectorAll('.slider-indicator');
        indicators.forEach(indicator => {
            indicator.addEventListener('click', (e) => {
                const index = parseInt(e.currentTarget.dataset.index);
                this.goTo(index);
            });
        });

        // Touch/swipe support
        const imageWrapper = this.container.querySelector('.slider-image-wrapper');
        if (imageWrapper) {
            imageWrapper.addEventListener('touchstart', (e) => {
                this.touchStartX = e.changedTouches[0].screenX;
            }, { passive: true });

            imageWrapper.addEventListener('touchend', (e) => {
                this.touchEndX = e.changedTouches[0].screenX;
                this.handleSwipe();
            }, { passive: true });
        }

        // Keyboard navigation
        document.addEventListener('keydown', (e) => {
            if (this.container.contains(document.activeElement) || 
                document.querySelector('.slider-main-image') === document.activeElement) {
                if (e.key === 'ArrowLeft') {
                    e.preventDefault();
                    this.prev();
                } else if (e.key === 'ArrowRight') {
                    e.preventDefault();
                    this.next();
                }
            }
        });
    }

    handleSwipe() {
        const swipeThreshold = 50;
        const diff = this.touchStartX - this.touchEndX;

        if (Math.abs(diff) > swipeThreshold) {
            if (diff > 0) {
                // Swipe left - next image
                this.next();
            } else {
                // Swipe right - previous image
                this.prev();
            }
        }
    }

    goTo(index) {
        if (index < 0 || index >= this.images.length) return;
        
        this.currentIndex = index;
        this.updateDisplay();
        this.updateActiveStates();
        
        if (this.options.autoPlay) {
            this.resetAutoPlay();
        }
    }

    next() {
        const nextIndex = (this.currentIndex + 1) % this.images.length;
        this.goTo(nextIndex);
    }

    prev() {
        const prevIndex = (this.currentIndex - 1 + this.images.length) % this.images.length;
        this.goTo(prevIndex);
    }

    updateDisplay() {
        const mainImage = this.container.querySelector('.slider-main-image');
        const counter = this.container.querySelector('.slider-image-counter');
        
        if (mainImage) {
            mainImage.src = this.images[this.currentIndex];
            mainImage.alt = `Artwork image ${this.currentIndex + 1}`;
        }
        
        if (counter) {
            counter.textContent = `${this.currentIndex + 1} / ${this.images.length}`;
        }
    }

    updateActiveStates() {
        // Update indicators
        const indicators = this.container.querySelectorAll('.slider-indicator');
        indicators.forEach((indicator, index) => {
            indicator.classList.toggle('active', index === this.currentIndex);
        });

        // Update thumbnails
        const thumbnails = this.container.querySelectorAll('.thumbnail-item');
        thumbnails.forEach((thumb, index) => {
            thumb.classList.toggle('active', index === this.currentIndex);
        });
    }

    startAutoPlay() {
        this.autoPlayTimer = setInterval(() => {
            this.next();
        }, this.options.autoPlayInterval);
    }

    stopAutoPlay() {
        if (this.autoPlayTimer) {
            clearInterval(this.autoPlayTimer);
            this.autoPlayTimer = null;
        }
    }

    resetAutoPlay() {
        this.stopAutoPlay();
        if (this.options.autoPlay) {
            this.startAutoPlay();
        }
    }

    destroy() {
        this.stopAutoPlay();
        // Remove event listeners if needed
    }
}

// Export for use in other scripts
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ImageSlider;
}

