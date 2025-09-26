import { Controller } from "@hotwired/stimulus"
import { createConsumer } from "@rails/actioncable"

export default class extends Controller {
  static values = { 
    channel: String,
    companyId: String
  }

  connect() {
    this.establishConnection()
    this.setupHeartbeat()
  }

  disconnect() {
    this.cleanup()
  }

  establishConnection() {
    // Create ActionCable consumer with connection management
    this.consumer = createConsumer()
    
    // Subscribe to the leads channel
    this.subscription = this.consumer.subscriptions.create(
      {
        channel: this.channelValue,
        company_id: this.companyIdValue
      },
      {
        connected: () => {
          console.log("ActionCable connected")
          this.connectionActive = true
        },
        
        disconnected: () => {
          console.log("ActionCable disconnected")
          this.connectionActive = false
          // Attempt to reconnect after a delay
          setTimeout(() => this.attemptReconnect(), 5000)
        },
        
        received: (data) => {
          this.handleMessage(data)
        }
      }
    )
  }

  handleMessage(data) {
    switch(data.type) {
      case 'connected':
        console.log("Channel connected at", new Date(data.timestamp * 1000))
        break
        
      case 'heartbeat':
        // Update last heartbeat timestamp
        this.lastHeartbeat = Date.now()
        break
        
      case 'lead_created':
      case 'lead_update':
        this.handleLeadUpdate(data)
        break
        
      default:
        console.log("Unknown message type:", data.type)
    }
  }

  handleLeadUpdate(data) {
    // Refresh the leads list when updates are received
    if (window.location.pathname.includes('/leads')) {
      // Use Turbo to refresh the page content
      Turbo.visit(window.location.href, { action: 'replace' })
    }
  }

  setupHeartbeat() {
    // Send heartbeat every 30 seconds to keep connection alive
    this.heartbeatInterval = setInterval(() => {
      if (this.subscription && this.connectionActive) {
        this.subscription.perform('heartbeat')
      }
    }, 30000)
  }

  attemptReconnect() {
    if (!this.connectionActive) {
      console.log("Attempting to reconnect ActionCable...")
      this.establishConnection()
    }
  }

  cleanup() {
    if (this.heartbeatInterval) {
      clearInterval(this.heartbeatInterval)
    }
    
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
    
    if (this.consumer) {
      this.consumer.disconnect()
    }
    
    this.connectionActive = false
  }
}