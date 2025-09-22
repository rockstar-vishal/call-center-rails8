import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="comment-display"
export default class extends Controller {
  static targets = ["truncated", "toggleButton", "toggleText"]
  static values = { 
    fullComment: String, 
    leadId: String 
  }

  connect() {
    this.isExpanded = false
    this.maxLength = 100
  }

  toggleExpanded() {
    this.isExpanded = !this.isExpanded
    
    if (this.isExpanded) {
      this.showFullComment()
    } else {
      this.showTruncatedComment()
    }
  }

  openModal() {
    // Find the comment modal
    const modalElement = document.querySelector('#comment-modal')
    if (!modalElement) {
      console.error('Comment modal not found')
      return
    }

    // Get the modal controller
    const modalController = this.application.getControllerForElementAndIdentifier(modalElement, 'modal')
    if (!modalController) {
      console.error('Modal controller not found')
      return
    }

    // Set the full comment content
    const contentElement = document.getElementById('full-comment-content')
    if (contentElement) {
      contentElement.textContent = this.fullCommentValue
    }

    // Open the modal
    modalController.open()
  }

  showFullComment() {
    if (this.hasTruncatedTarget) {
      this.truncatedTarget.innerHTML = this.formatComment(this.fullCommentValue)
    }
    
    if (this.hasToggleTextTarget) {
      this.toggleTextTarget.textContent = "Show less"
    }
  }

  showTruncatedComment() {
    if (this.hasTruncatedTarget) {
      const truncated = this.fullCommentValue.length > this.maxLength 
        ? this.fullCommentValue.substring(0, this.maxLength) + "..."
        : this.fullCommentValue
      
      this.truncatedTarget.innerHTML = this.formatComment(truncated)
    }
    
    if (this.hasToggleTextTarget) {
      this.toggleTextTarget.textContent = "Show more"
    }
  }

  formatComment(comment) {
    if (!comment) return '<span class="text-gray-400 italic">No comments</span>'
    
    // Convert \n to <br> tags and escape HTML
    const formatted = comment
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/\n/g, '<br>')
    
    return formatted
  }
}
