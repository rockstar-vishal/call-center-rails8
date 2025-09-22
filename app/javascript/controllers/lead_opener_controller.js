import ModalOpenerController from "controllers/modal_opener_base"

// Connects to data-controller="lead-opener"
export default class extends ModalOpenerController {
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
}
