import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="bulk-selector"
export default class extends Controller {
  static targets = ["bulkForm", "selectAllButton", "selectedCount", "leadCheckbox"]
  static values = { isAdmin: Boolean }

  connect() {
    this.selectedLeads = new Set()
    this.updateUI()
  }

  toggleLead(event) {
    const leadId = event.currentTarget.dataset.leadId
    const checkbox = event.currentTarget.querySelector('input[type="checkbox"]')
    const initials = event.currentTarget.querySelector('.lead-initials')
    const checkmark = event.currentTarget.querySelector('.lead-checkmark')
    
    if (this.selectedLeads.has(leadId)) {
      // Deselect lead
      this.selectedLeads.delete(leadId)
      checkbox.checked = false
      event.currentTarget.classList.remove('ring-2', 'ring-blue-500', 'bg-green-500')
      event.currentTarget.classList.add('bg-blue-500')
      
      // Show initials, hide checkmark
      if (initials) initials.classList.remove('opacity-0')
      if (checkmark) checkmark.classList.add('opacity-0')
    } else {
      // Select lead
      this.selectedLeads.add(leadId)
      checkbox.checked = true
      event.currentTarget.classList.remove('bg-blue-500')
      event.currentTarget.classList.add('ring-2', 'ring-blue-500', 'bg-green-500')
      
      // Hide initials, show checkmark
      if (initials) initials.classList.add('opacity-0')
      if (checkmark) checkmark.classList.remove('opacity-0')
    }
    
    this.updateUI()
  }

  selectAll() {
    const allLeads = this.leadCheckboxTargets
    
    if (this.selectedLeads.size === allLeads.length) {
      // Deselect all
      this.selectedLeads.clear()
      allLeads.forEach(lead => {
        const checkbox = lead.querySelector('input[type="checkbox"]')
        const initials = lead.querySelector('.lead-initials')
        const checkmark = lead.querySelector('.lead-checkmark')
        
        checkbox.checked = false
        lead.classList.remove('ring-2', 'ring-blue-500', 'bg-green-500')
        lead.classList.add('bg-blue-500')
        
        // Show initials, hide checkmark
        if (initials) initials.classList.remove('opacity-0')
        if (checkmark) checkmark.classList.add('opacity-0')
      })
    } else {
      // Select all
      allLeads.forEach(lead => {
        const leadId = lead.dataset.leadId
        this.selectedLeads.add(leadId)
        const checkbox = lead.querySelector('input[type="checkbox"]')
        const initials = lead.querySelector('.lead-initials')
        const checkmark = lead.querySelector('.lead-checkmark')
        
        checkbox.checked = true
        lead.classList.remove('bg-blue-500')
        lead.classList.add('ring-2', 'ring-blue-500', 'bg-green-500')
        
        // Hide initials, show checkmark
        if (initials) initials.classList.add('opacity-0')
        if (checkmark) checkmark.classList.remove('opacity-0')
      })
    }
    
    this.updateUI()
  }

  updateUI() {
    const selectedCount = this.selectedLeads.size
    const totalLeads = this.leadCheckboxTargets.length
    
    // Show/hide bulk form
    if (selectedCount > 0 && this.isAdminValue && this.hasBulkFormTarget) {
      this.bulkFormTarget.classList.remove('hidden')
    } else if (this.hasBulkFormTarget) {
      this.bulkFormTarget.classList.add('hidden')
    }
    
    // Update selected count
    if (this.hasSelectedCountTarget) {
      this.selectedCountTarget.textContent = selectedCount
    }
    
    // Update select all button
    if (this.hasSelectAllButtonTarget) {
      if (selectedCount === 0) {
        this.selectAllButtonTarget.textContent = "Select All"
        this.selectAllButtonTarget.classList.add('hidden')
      } else if (selectedCount === totalLeads) {
        this.selectAllButtonTarget.textContent = "Deselect All"
        this.selectAllButtonTarget.classList.remove('hidden')
      } else {
        this.selectAllButtonTarget.textContent = "Select All on Page"
        this.selectAllButtonTarget.classList.remove('hidden')
      }
    }
    
    // Update hidden input with selected IDs
    this.updateHiddenInput()
  }

  updateHiddenInput() {
    if (!this.hasBulkFormTarget) return
    
    // Find the form element inside bulkForm
    const form = this.bulkFormTarget.querySelector('form')
    if (!form) return
    
    // Remove existing hidden inputs
    const existingInputs = form.querySelectorAll('input[name="lead_ids[]"]')
    existingInputs.forEach(input => input.remove())
    
    // Add hidden inputs for each selected lead
    this.selectedLeads.forEach(leadId => {
      const input = document.createElement('input')
      input.type = 'hidden'
      input.name = 'lead_ids[]'
      input.value = leadId
      form.appendChild(input)
    })
  }

  clearSelection() {
    this.selectedLeads.clear()
    this.leadCheckboxTargets.forEach(lead => {
      const checkbox = lead.querySelector('input[type="checkbox"]')
      const initials = lead.querySelector('.lead-initials')
      const checkmark = lead.querySelector('.lead-checkmark')
      
      checkbox.checked = false
      lead.classList.remove('ring-2', 'ring-blue-500', 'bg-green-500')
      lead.classList.add('bg-blue-500')
      
      // Show initials, hide checkmark
      if (initials) initials.classList.remove('opacity-0')
      if (checkmark) checkmark.classList.add('opacity-0')
    })
    this.updateUI()
  }
}
