import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="collapsible-sidebar"
export default class extends Controller {
  static targets = ["sidebar", "content", "logo", "icon", "userInfo", "navText", "logoutText"]

  connect() {
    this.isCollapsed = false
    this.hoverTimeout = null
    
    // Start in collapsed state for more working space
    setTimeout(() => {
      this.collapse()
    }, 1000) // Collapse after 1 second
  }

  mouseEnter() {
    // Clear any pending collapse
    if (this.hoverTimeout) {
      clearTimeout(this.hoverTimeout)
      this.hoverTimeout = null
    }
    
    // Expand sidebar immediately
    if (this.isCollapsed) {
      this.expand()
    }
  }

  mouseLeave() {
    // Delay collapse to prevent flickering
    this.hoverTimeout = setTimeout(() => {
      this.collapse()
    }, 300) // 300ms delay
  }

  expand() {
    this.isCollapsed = false
    
    // Expand sidebar
    this.sidebarTarget.classList.remove('w-16')
    this.sidebarTarget.classList.add('w-64')
    
    // Adjust content margin
    this.contentTarget.classList.remove('ml-16')
    this.contentTarget.classList.add('ml-64')
    
    // Show text elements
    this.navTextTargets.forEach(element => {
      element.classList.remove('hidden')
    })
    
    if (this.hasLogoTarget) {
      this.logoTarget.classList.remove('hidden')
    }
    
    if (this.hasIconTarget) {
      this.iconTarget.classList.add('hidden')
    }
    
    if (this.hasUserInfoTarget) {
      this.userInfoTarget.classList.remove('hidden')
    }
    
    if (this.hasLogoutTextTarget) {
      this.logoutTextTarget.classList.remove('hidden')
    }
  }

  collapse() {
    this.isCollapsed = true
    
    // Collapse sidebar
    this.sidebarTarget.classList.remove('w-64')
    this.sidebarTarget.classList.add('w-16')
    
    // Adjust content margin
    this.contentTarget.classList.remove('ml-64')
    this.contentTarget.classList.add('ml-16')
    
    // Hide text elements
    this.navTextTargets.forEach(element => {
      element.classList.add('hidden')
    })
    
    if (this.hasLogoTarget) {
      this.logoTarget.classList.add('hidden')
    }
    
    if (this.hasIconTarget) {
      this.iconTarget.classList.remove('hidden')
    }
    
    if (this.hasUserInfoTarget) {
      this.userInfoTarget.classList.add('hidden')
    }
    
    if (this.hasLogoutTextTarget) {
      this.logoutTextTarget.classList.add('hidden')
    }
  }
}
