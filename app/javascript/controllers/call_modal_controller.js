import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="call-modal"
export default class extends Controller {
  static values = { url: String }

  connect() {
    this.element.addEventListener('click', this.openModal.bind(this))
  }

  async openModal(event) {
    event.preventDefault()
    
    try {
      const response = await fetch(this.urlValue, {
        method: 'GET',
        headers: {
          'Accept': 'text/vnd.turbo-stream.html',
          'Content-Type': 'application/x-turbo-stream',
        }
      })

      if (response.ok) {
        const turboStreamContent = await response.text()
        Turbo.renderStreamMessage(turboStreamContent)
      } else {
        console.error('Failed to load modal content')
      }
    } catch (error) {
      console.error('Error loading modal:', error)
    }
  }
}
