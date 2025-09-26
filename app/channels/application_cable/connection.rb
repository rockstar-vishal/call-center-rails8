module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    identified_by :current_company
    
    # Passenger-friendly connection management
    def connect
      self.current_user = find_verified_user
      self.current_company = current_user.company if current_user
      
      # Set connection timeout for Passenger compatibility
      @connection_timeout = 30.seconds.from_now
      
      logger.add_tags 'ActionCable', "User #{current_user.id}", "Company #{current_company.id}" if current_user
    end
    
    def disconnect
      # Clean up any resources
      logger.info "ActionCable connection closed for user #{current_user&.id}"
    end

    private

    def find_verified_user
      # Use Devise's session-based authentication for Action Cable
      if (current_user = env['warden'].user)
        current_user
      else
        reject_unauthorized_connection
      end
    end
  end
end
