import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="lead-opener"
export default class extends Controller {
  static values = { url: String, name: String }

  async openLead() {
    await this.openModal('#lead-details-modal', {
      title: this.nameValue,
      loadingMessage: "Loading lead details...",
      errorMessage: "Failed to load lead details. Please try again."
    })
  }

  async openMiniEdit() {
    await this.openModal('#mini-edit-modal', {
      title: `Edit ${this.nameValue}`,
      loadingMessage: "Loading edit form...",
      errorMessage: "Failed to load edit form. Please try again."
    })
  }

  // Note: openCall method removed - now handled by Rails remote: true links

  async openModal(modalSelector, options) {
    try {
      // Find the modal element
      const modalElement = document.querySelector(modalSelector)
      if (!modalElement) {
        console.error(`Modal ${modalSelector} not found`)
        return
      }

      // Get the modal controller
      const modalController = this.application.getControllerForElementAndIdentifier(modalElement, 'modal')
      if (!modalController) {
        console.error('Modal controller not found')
        return
      }

      // Load content into the modal
      await modalController.loadContent(this.urlValue, options)

    } catch (error) {
      console.error('Error opening modal:', error)
    }
  }
}
