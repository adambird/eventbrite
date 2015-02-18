class SessionsController < ApplicationController

  def create
    logger.debug { "#create #{auth_hash.inspect}" }

    case auth_hash['provider']
    when 'cronofy'
      @user = User.find_or_create_from_auth_hash(auth_hash)
      login(@user)
    when 'eventbrite'
      current_user.eventbrite_user_id = auth_hash['uid']
      current_user.eventbrite_access_token = auth_hash['credentials']['token']
      current_user.save
    else
      flash.alert = "Unrecognised provider"
    end
    redirect_to :root
  end

  def destroy
    logout
    redirect_to :root
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end