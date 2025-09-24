import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { text: String }
  static targets = ["button"]

  copy() {
    const textToCopy = this.textValue || this.element.textContent.trim()
    
    navigator.clipboard.writeText(textToCopy).then(() => {
      this.showSuccess()
    }).catch((err) => {
      console.error('Could not copy text: ', err)
      // Fallback for older browsers
      this.fallbackCopy(textToCopy)
    })
  }

  fallbackCopy(text) {
    const textArea = document.createElement('textarea')
    textArea.value = text
    document.body.appendChild(textArea)
    textArea.select()
    document.execCommand('copy')
    document.body.removeChild(textArea)
    this.showSuccess()
  }

  showSuccess() {
    const button = this.hasButtonTarget ? this.buttonTarget : this.element
    
    // Store original content
    const originalContent = button.innerHTML
    const originalClasses = button.className
    
    // Show success state
    button.innerHTML = this.getSuccessIcon()
    button.className = originalClasses.replace(/text-\w+-\d+/, 'text-green-600')
    
    // Reset after 2 seconds
    setTimeout(() => {
      button.innerHTML = originalContent
      button.className = originalClasses
    }, 2000)
  }

  getSuccessIcon() {
    // Return appropriate success icon based on button size
    const isSmall = this.element.classList.contains('w-3') || this.element.classList.contains('w-4')
    const iconSize = isSmall ? 'w-3 h-3' : 'w-4 h-4'
    
    return `<svg class="${iconSize}" fill="none" stroke="currentColor" viewBox="0 0 24 24">
      <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M5 13l4 4L19 7"></path>
    </svg>`
  }
}
