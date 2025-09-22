import ModalOpenerController from "controllers/modal_opener_base"

// Connects to data-controller="project-drawer"
export default class extends ModalOpenerController {
  async openProject() {
    await this.openModal('#project-details-modal', {
      title: `${this.nameValue} - Project Details`,
      loadingMessage: "Loading project details...",
      errorMessage: "Failed to load project details. Please try again."
    })
  }
}