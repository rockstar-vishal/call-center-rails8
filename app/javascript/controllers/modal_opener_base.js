import { Controller } from "@hotwired/stimulus"

// Base controller for opening modals with content loading
export default class extends Controller {
  static values = { url: String, name: String }

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
