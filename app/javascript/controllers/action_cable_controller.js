import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

// Connects to data-controller="action-cable"
export default class extends Controller {
  static values = { 
    channel: String,
    companyId: String 
  }

  connect() {
    this.consumer = createConsumer()
    this.subscribe()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  subscribe() {
    if (this.channelValue && this.companyIdValue) {
      this.subscription = this.consumer.subscriptions.create(
        { 
          channel: this.channelValue
        },
        {
          connected: () => {
            // Connection established
          },
          disconnected: () => {
            // Connection lost
          },
          received: (data) => {
            this.handleMessage(data)
          }
        }
      )
    }
  }

  handleMessage(data) {
    switch (data.type) {
      case 'lead_update':
        this.handleLeadUpdate(data)
        break
      case 'lead_created':
        this.handleLeadCreated(data)
        break
      default:
        // Unknown message type - ignore silently
    }
  }

  handleLeadUpdate(data) {
    // Update the lead row in the table
    const leadRow = document.getElementById(`lead-row-${data.lead_id}`)
    if (leadRow) {
      this.updateLeadRow(leadRow, data.data)
    }
  }

  handleLeadCreated(data) {
    // For new leads, refresh the page to ensure proper ordering and pagination
    window.location.reload()
  }

  updateLeadRow(leadRow, data) {
    // Update name (first cell with lead name)
    const nameCell = leadRow.querySelector('td:first-child .text-gray-900')
    if (nameCell) nameCell.textContent = data.name

    // Update status (third cell with status badge)
    const statusCell = leadRow.querySelector('td:nth-child(3) span')
    if (statusCell) {
      statusCell.textContent = data.status
      // Update status badge classes
      statusCell.className = `inline-flex px-2 py-1 text-xs font-semibold rounded-full ${this.getStatusBadgeClass(data.status)}`
    }

    // Update comment (last cell with comment display)
    const commentCell = leadRow.querySelector('td:last-child .comment-content')
    if (commentCell) {
      if (data.comment && data.comment.trim()) {
        const truncatedComment = data.comment.length > 100 ? data.comment.substring(0, 100) + "..." : data.comment
        commentCell.innerHTML = this.formatComment(truncatedComment)
      } else {
        commentCell.innerHTML = '<span class="text-gray-400 italic">No comments</span>'
      }
    }
  }

  formatComment(comment) {
    if (!comment) return ''
    
    // Convert \n to <br> and limit length
    const formatted = comment.replace(/\n/g, '<br>')
    if (formatted.length > 100) {
      return formatted.substring(0, 100) + '...'
    }
    return formatted
  }

  getStatusBadgeClass(status) {
    const statusClasses = {
      'Call Back Today': 'bg-yellow-100 text-yellow-800',
      'Interested': 'bg-green-100 text-green-800',
      'Not Interested': 'bg-red-100 text-red-800',
      'Follow Up': 'bg-blue-100 text-blue-800',
      'New': 'bg-gray-100 text-gray-800',
      'Contacted': 'bg-blue-100 text-blue-800',
      'Converted': 'bg-green-100 text-green-800',
      'Lost': 'bg-red-100 text-red-800'
    }
    return statusClasses[status] || 'bg-gray-100 text-gray-800'
  }

}
