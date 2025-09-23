import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapsible-menu"
export default class extends Controller {
  static targets = ["content", "icon", "buttonText"]

  toggle() {
    const content = this.contentTarget
    const icon = this.iconTarget
    const buttonText = this.hasButtonTextTarget ? this.buttonTextTarget : null
    
    if (content.classList.contains("hidden")) {
      // Expand
      content.classList.remove("hidden")
      if (icon) icon.style.transform = "rotate(180deg)"
      if (buttonText) buttonText.textContent = "Hide Filters"
    } else {
      // Collapse
      content.classList.add("hidden")
      if (icon) icon.style.transform = "rotate(0deg)"
      if (buttonText) buttonText.textContent = "Show Filters"
    }
  }
}
