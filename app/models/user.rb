class User < ActiveRecord::Base

  def self.find_or_create_from_auth_hash(auth_hash)
    email = auth_hash['info']['email']

    user = User.find_or_create_by(email: email)
    user.cronofy_id = auth_hash['uid']
    user.cronofy_access_token = auth_hash['credentials']['token']
    user.cronofy_refresh_token = auth_hash['credentials']['refresh_token']
    user.save
    user
  end

  def eventbrite_credentials?
    !self.eventbrite_user_id.blank? && !self.eventbrite_access_token.blank?
  end
end
