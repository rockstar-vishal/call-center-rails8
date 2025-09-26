module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user
    identified_by :current_company

    def connect
      self.current_user = find_verified_user
      self.current_company = current_user.company if current_user
      logger.add_tags 'ActionCable', "User #{current_user.id}", "Company #{current_company.id}" if current_user
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
