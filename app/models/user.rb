class User < ActiveRecord::Base

  def self.find_or_create_from_auth_hash(auth_hash)
    email = auth_hash['info']['email']

    user = User.find_or_create_by(email: email)
    user.cronofy_id = auth_hash['uid']
    user.cronofy_access_token = auth_hash['token']
    user.cronofy_refresh_token = auth_hash['refresh_token']
    user.save
    user
  end
end
