# Passenger + ActionCable configuration
# This helps manage WebSocket connections in Passenger environment

if defined?(PhusionPassenger)
  # Configure Passenger for ActionCable
  PhusionPassenger.advertised_concurrency_level = 2
  
  # Set connection timeout for WebSocket connections
  PhusionPassenger.max_requests = 1000
  
  # Configure memory limits
  PhusionPassenger.memory_limit = 512 # MB
  
  # Enable connection pooling
  PhusionPassenger.pool_idle_time = 300 # 5 minutes
  
  Rails.logger.info "Passenger configured for ActionCable with concurrency: #{PhusionPassenger.advertised_concurrency_level}"
end

# ActionCable configuration for Passenger
Rails.application.configure do
  # Reduce connection timeout to help Passenger manage processes
  config.action_cable.connection_class = -> { ApplicationCable::Connection }
  
  # Configure for production with Passenger
  if Rails.env.production?
    config.action_cable.mount_path = '/cable'
    config.action_cable.disable_request_forgery_protection = false
    
    # Use Redis for ActionCable in production (if available)
    # config.action_cable.adapter = :redis
    # config.action_cable.url = ENV['REDIS_URL'] || 'redis://localhost:6379/1'
  end
end
