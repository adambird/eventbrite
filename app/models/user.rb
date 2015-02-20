class User < ActiveRecord::Base

  def eventbrite_credentials?
    !self.eventbrite_user_id.blank? && !self.eventbrite_access_token.blank?
  end

end
