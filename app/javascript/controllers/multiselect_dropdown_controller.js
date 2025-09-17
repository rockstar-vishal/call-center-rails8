import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="multiselect-dropdown"
export default class extends Controller {
  static targets = ["input", "dropdown", "searchInput", "options", "selectedCount"]
  static values = { 
    placeholder: String,
    searchPlaceholder: String
  }

  connect() {
    this.selectedItems = new Set()
    this.allOptions = Array.from(this.optionsTarget.children)
    this.updateDisplay()
    
    // Close dropdown when clicking outside
    this.boundCloseOnOutsideClick = this.closeOnOutsideClick.bind(this)
    document.addEventListener('click', this.boundCloseOnOutsideClick)
  }

  disconnect() {
    document.removeEventListener('click', this.boundCloseOnOutsideClick)
  }

  toggle() {
    if (this.dropdownTarget.classList.contains('hidden')) {
      this.open()
    } else {
      this.close()
    }
  }

  open() {
    this.dropdownTarget.classList.remove('hidden')
    this.searchInputTarget.focus()
    this.searchInputTarget.value = ''
    this.filterOptions('')
  }

  close() {
    this.dropdownTarget.classList.add('hidden')
  }

  closeOnOutsideClick(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  search() {
    const query = this.searchInputTarget.value.toLowerCase()
    this.filterOptions(query)
  }

  filterOptions(query) {
    this.allOptions.forEach(option => {
      const text = option.textContent.toLowerCase()
      if (text.includes(query)) {
        option.classList.remove('hidden')
      } else {
        option.classList.add('hidden')
      }
    })
  }

  toggleOption(event) {
    const checkbox = event.target
    const value = checkbox.value
    
    if (checkbox.checked) {
      this.selectedItems.add(value)
    } else {
      this.selectedItems.delete(value)
    }
    
    this.updateDisplay()
  }

  updateDisplay() {
    const count = this.selectedItems.size
    
    if (count === 0) {
      this.inputTarget.textContent = this.placeholderValue
      this.inputTarget.classList.add('text-gray-500')
      this.inputTarget.classList.remove('text-gray-900')
    } else {
      this.inputTarget.textContent = `${count} selected`
      this.inputTarget.classList.remove('text-gray-500')
      this.inputTarget.classList.add('text-gray-900')
    }
    
    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = count
    }
  }

  clear() {
    // Uncheck all checkboxes
    this.element.querySelectorAll('input[type="checkbox"]').forEach(checkbox => {
      checkbox.checked = false
    })
    
    this.selectedItems.clear()
    this.updateDisplay()
    this.close()
  }
}
