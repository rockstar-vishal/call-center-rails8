import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay"]

  connect() {
    // Close menu on escape key
    document.addEventListener("keydown", this.handleEscape.bind(this))
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleEscape.bind(this))
  }

  get sidebar() {
    return document.querySelector('[data-mobile-menu-target="sidebar"]')
  }

  toggle() {
    console.log("Mobile menu toggle clicked")
    if (this.sidebar) {
      console.log("Sidebar classes:", this.sidebar.classList.toString())
      if (this.sidebar.classList.contains("-translate-x-full")) {
        console.log("Opening sidebar")
        this.open()
      } else {
        console.log("Closing sidebar")
        this.close()
      }
    } else {
      console.log("Sidebar not found")
    }
  }

  open() {
    if (this.sidebar) {
      console.log("Opening sidebar - removing -translate-x-full")
      this.sidebar.classList.remove("-translate-x-full")
      console.log("Sidebar classes after open:", this.sidebar.classList.toString())
    }
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.remove("hidden")
    }
    document.body.classList.add("overflow-hidden")
  }

  close() {
    if (this.sidebar) {
      this.sidebar.classList.add("-translate-x-full")
    }
    if (this.hasOverlayTarget) {
      this.overlayTarget.classList.add("hidden")
    }
    document.body.classList.remove("overflow-hidden")
  }

  handleEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }
}
