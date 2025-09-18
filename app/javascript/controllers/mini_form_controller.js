import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="mini-form"
export default class extends Controller {
  static targets = ["submitButton"]

  handleResponse(event) {
    const response = event.detail.fetchResponse.response
    
    if (response.ok) {
      // Success - redirect will be handled by Rails
      // Show loading state briefly
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.innerHTML = `
          <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          Updating...
        `
        this.submitButtonTarget.disabled = true
      }
      
      // The redirect will happen automatically via Rails
      setTimeout(() => {
        window.location.reload()
      }, 500)
    } else {
      // Error handling is done by Rails rendering the form with errors
      console.log('Form submission had errors, form will be re-rendered with errors')
    }
  }

  connect() {
    // Add loading state management
    this.element.addEventListener('submit', () => {
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.innerHTML = `
          <svg class="animate-spin -ml-1 mr-3 h-5 w-5 text-white" fill="none" viewBox="0 0 24 24">
            <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
            <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
          </svg>
          Updating...
        `
        this.submitButtonTarget.disabled = true
      }
    })
  }
}
