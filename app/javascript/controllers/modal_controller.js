import { Controller } from "@hotwired/stimulus"

// Base Modal Controller - Reusable for any modal type
export default class extends Controller {
  static targets = ["overlay", "container", "content", "title", "closeButton"]
  static values = { 
    type: String,           // "center", "drawer-right", "drawer-left", "drawer-top", "drawer-bottom"
    size: String,           // "sm", "md", "lg", "xl", "full"
    closable: Boolean,      // Can be closed by clicking outside or ESC
    persistent: Boolean     // Prevents closing by outside click/ESC
  }

  connect() {
    // Set default values
    this.typeValue = this.typeValue || "center"
    this.sizeValue = this.sizeValue || "md"
    this.closableValue = this.closableValue !== false
    this.persistentValue = this.persistentValue || false
    
    // Bind keyboard events
    document.addEventListener("keydown", this.handleKeydown.bind(this))
    
    // Apply initial styling based on type and size
    this.applyModalStyles()
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown.bind(this))
    this.restoreBodyScroll()
  }

  // Open modal
  open() {
    this.showOverlay()
    this.showContainer()
    this.preventBodyScroll()
    this.focusFirstElement()
  }

  // Close modal
  close() {
    if (this.persistentValue) return
    
    this.hideContainer()
    this.hideOverlay()
    this.restoreBodyScroll()
  }

  // Force close (ignores persistent setting)
  forceClose() {
    this.hideContainer()
    this.hideOverlay()
    this.restoreBodyScroll()
  }

  // Handle overlay clicks
  overlayClick(event) {
    if (event.target === this.overlayTarget && this.closableValue && !this.persistentValue) {
      this.close()
    }
  }

  // Handle close button clicks
  closeButtonClick() {
    this.close()
  }

  // Handle load content clicks (for external triggers)
  async loadContentClick(event) {
    const url = event.currentTarget.dataset.url
    const title = event.currentTarget.dataset.title
    const loadingMessage = event.currentTarget.dataset.loadingMessage || "Loading..."
    const errorMessage = event.currentTarget.dataset.errorMessage || "Failed to load content. Please try again."
    
    await this.loadContent(url, {
      title: title,
      loadingMessage: loadingMessage,
      errorMessage: errorMessage
    })
  }

  // Load content via AJAX
  async loadContent(url, options = {}) {
    try {
      this.showLoading(options.loadingMessage)
      
      const response = await fetch(url, {
        headers: {
          'Accept': 'text/html, application/json',
          'X-Requested-With': 'XMLHttpRequest',
          ...options.headers
        },
        method: options.method || 'GET',
        body: options.body
      })
      
      if (response.ok) {
        const contentType = response.headers.get('content-type')
        
        if (contentType && contentType.includes('application/json')) {
          // Handle JSON response (could be an error)
          const jsonData = await response.json()
          if (jsonData.success === false) {
            return { success: false, error: 'JSON Error', data: jsonData }
          }
        } else {
          // Handle HTML response (normal case)
          const html = await response.text()
          this.setContent(html)
          if (options.title) this.setTitle(options.title)
          this.open()
          return { success: true, data: html }
        }
      } else {
        // Check if the error response is JSON
        const contentType = response.headers.get('content-type')
        if (contentType && contentType.includes('application/json')) {
          const errorData = await response.json()
          return { success: false, error: 'HTTP Error', data: errorData }
        } else {
          this.showError(options.errorMessage)
          return { success: false, error: 'HTTP Error' }
        }
      }
    } catch (error) {
      console.error('Modal content loading error:', error)
      this.showError(options.errorMessage)
      return { success: false, error: error.message }
    }
  }

  // Set modal content
  setContent(html) {
    if (this.hasContentTarget) {
      this.contentTarget.innerHTML = html
    }
  }

  // Set modal title
  setTitle(title) {
    if (this.hasTitleTarget) {
      this.titleTarget.textContent = title
    }
  }

  // Show loading state
  showLoading(message = "Loading...") {
    const loadingHtml = `
      <div class="flex items-center justify-center py-12">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
        <span class="ml-3 text-gray-600">${message}</span>
      </div>
    `
    this.setContent(loadingHtml)
    this.open()
  }

  // Show error state
  showError(message = "An error occurred. Please try again.") {
    const errorHtml = `
      <div class="flex items-center justify-center py-12">
        <div class="text-center">
          <svg class="mx-auto h-12 w-12 text-red-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-2.5L13.732 4c-.77-.833-1.964-.833-2.732 0L4.082 16.5c-.77.833.192 2.5 1.732 2.5z"></path>
          </svg>
          <h3 class="mt-2 text-sm font-medium text-gray-900">Error</h3>
          <p class="mt-1 text-sm text-gray-500">${message}</p>
          <button data-action="click->modal#close" class="mt-3 inline-flex items-center px-3 py-2 border border-transparent text-sm font-medium rounded-md text-white bg-red-600 hover:bg-red-700">
            Close
          </button>
        </div>
      </div>
    `
    this.setContent(errorHtml)
  }

  // Apply modal styles based on type and size
  applyModalStyles() {
    if (!this.hasContainerTarget) return

    const container = this.containerTarget
    
    // Remove existing classes
    container.classList.remove(
      'modal-center', 'modal-drawer-right', 'modal-drawer-left', 'modal-drawer-top', 'modal-drawer-bottom',
      'modal-sm', 'modal-md', 'modal-lg', 'modal-xl', 'modal-full'
    )

    // Apply type classes
    container.classList.add(`modal-${this.typeValue}`)
    
    // Apply size classes
    container.classList.add(`modal-${this.sizeValue}`)
  }

  // Show overlay
  showOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove('hidden', 'opacity-0')
      this.overlayTarget.classList.add('opacity-100')
    }
  }

  // Hide overlay
  hideOverlay() {
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove('opacity-100')
      this.overlayTarget.classList.add('opacity-0')
      setTimeout(() => {
        this.overlayTarget.classList.add('hidden')
      }, 300) // Match transition duration
    }
  }

  // Show container
  showContainer() {
    if (this.hasContainerTarget) {
      const container = this.containerTarget
      
      // Remove hidden classes
      container.classList.remove('hidden')
      
      // Apply show classes based on type
      switch (this.typeValue) {
        case 'drawer-right':
          container.classList.remove('translate-x-full')
          break
        case 'drawer-left':
          container.classList.remove('-translate-x-full')
          break
        case 'drawer-top':
          container.classList.remove('-translate-y-full')
          break
        case 'drawer-bottom':
          container.classList.remove('translate-y-full')
          break
        default: // center
          // For center modals, we just need to remove hidden
          // The positioning is handled by CSS flexbox
          break
      }
    }
  }

  // Hide container
  hideContainer() {
    if (this.hasContainerTarget) {
      const container = this.containerTarget
      
      // Apply hide classes based on type
      switch (this.typeValue) {
        case 'drawer-right':
          container.classList.add('translate-x-full')
          break
        case 'drawer-left':
          container.classList.add('-translate-x-full')
          break
        case 'drawer-top':
          container.classList.add('-translate-y-full')
          break
        case 'drawer-bottom':
          container.classList.add('translate-y-full')
          break
        default: // center
          // For center modals, just hide immediately
          container.classList.add('hidden')
          return // Don't set timeout for center modals
      }

      // Hide after animation (for drawer modals only)
      setTimeout(() => {
        container.classList.add('hidden')
      }, 300)
    }
  }

  // Prevent body scroll
  preventBodyScroll() {
    document.body.classList.add('overflow-hidden')
  }

  // Restore body scroll
  restoreBodyScroll() {
    document.body.classList.remove('overflow-hidden')
  }

  // Focus first focusable element
  focusFirstElement() {
    setTimeout(() => {
      const focusable = this.containerTarget?.querySelector('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])')
      focusable?.focus()
    }, 100)
  }

  // Handle keyboard events
  handleKeydown(event) {
    if (event.key === "Escape" && this.closableValue && !this.persistentValue) {
      this.close()
    }
  }

  // Value changed callbacks
  typeValueChanged() {
    this.applyModalStyles()
  }

  sizeValueChanged() {
    this.applyModalStyles()
  }
}
