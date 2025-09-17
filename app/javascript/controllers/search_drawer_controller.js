import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="search-drawer"
export default class extends Controller {
  static targets = ["drawer", "overlay", "form"]

  connect() {
    // Close drawer on escape key
    this.boundHandleKeydown = this.handleKeydown.bind(this)
    document.addEventListener('keydown', this.boundHandleKeydown)
  }

  disconnect() {
    document.removeEventListener('keydown', this.boundHandleKeydown)
  }

  open() {
    // Show overlay and drawer
    this.overlayTarget.classList.remove('hidden')
    this.overlayTarget.classList.add('opacity-100')
    
    // Slide in drawer from right
    setTimeout(() => {
      this.drawerTarget.classList.remove('translate-x-full')
      this.drawerTarget.classList.add('translate-x-0')
    }, 10)
    
    // Prevent body scroll
    document.body.classList.add('overflow-hidden')
  }

  close() {
    // Slide out drawer to right
    this.drawerTarget.classList.remove('translate-x-0')
    this.drawerTarget.classList.add('translate-x-full')
    
    // Hide overlay after animation
    setTimeout(() => {
      this.overlayTarget.classList.remove('opacity-100')
      this.overlayTarget.classList.add('hidden')
    }, 300)
    
    // Restore body scroll
    document.body.classList.remove('overflow-hidden')
  }

  overlayClick(event) {
    // Close drawer if clicking on overlay (not the drawer itself)
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    // Close drawer on escape key
    if (event.key === 'Escape' && !this.overlayTarget.classList.contains('hidden')) {
      this.close()
    }
  }

  clearForm() {
    // Clear all form inputs
    this.formTarget.reset()
  }

  submitSearch() {
    // Submit the search form
    this.formTarget.submit()
  }
}
