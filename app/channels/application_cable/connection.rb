module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      Rails.logger.info "ApplicationCable::Connect#connect: ...: %s" % cookies.signed[:username]
      self.current_user = find_verified_user
    end

    protected
      def find_verified_user
        if current_user = User.find_by(username: cookies.signed[:username])
          current_user
        else
          reject_unauthorized_connection
        end
      end
  end
end
