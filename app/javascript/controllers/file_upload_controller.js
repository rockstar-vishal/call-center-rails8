import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="file-upload"
export default class extends Controller {
  static targets = ["input", "info", "name", "removeButton", "dropzone"]

  connect() {
    this.setupDragAndDrop()
  }

  setupDragAndDrop() {
    const dropzone = this.hasDropzoneTarget ? this.dropzoneTarget : this.element

    // Prevent default drag behaviors
    ;['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
      dropzone.addEventListener(eventName, this.preventDefaults, false)
      document.body.addEventListener(eventName, this.preventDefaults, false)
    })

    // Highlight drop area when item is dragged over it
    ;['dragenter', 'dragover'].forEach(eventName => {
      dropzone.addEventListener(eventName, () => this.highlight(dropzone), false)
    })

    ;['dragleave', 'drop'].forEach(eventName => {
      dropzone.addEventListener(eventName, () => this.unhighlight(dropzone), false)
    })

    // Handle dropped files
    dropzone.addEventListener('drop', (e) => this.handleDrop(e), false)
  }

  preventDefaults(e) {
    e.preventDefault()
    e.stopPropagation()
  }

  highlight(dropzone) {
    dropzone.classList.add('border-blue-400', 'bg-blue-50')
  }

  unhighlight(dropzone) {
    dropzone.classList.remove('border-blue-400', 'bg-blue-50')
  }

  handleDrop(e) {
    const dt = e.dataTransfer
    const files = dt.files

    if (files.length > 0) {
      const file = files[0]
      
      // Check if it's a CSV file
      if (file.type === 'text/csv' || file.name.endsWith('.csv')) {
        this.inputTarget.files = files
        this.displayFile(file)
      } else {
        alert('Please upload a CSV file only.')
      }
    }
  }

  fileSelected(event) {
    const files = event.target.files
    
    if (files.length > 0) {
      const file = files[0]
      this.displayFile(file)
    }
  }

  displayFile(file) {
    this.nameTarget.textContent = file.name
    this.infoTarget.classList.remove('hidden')
  }

  removeFile() {
    this.inputTarget.value = ''
    this.infoTarget.classList.add('hidden')
  }
}
