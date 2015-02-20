class SessionsController < ApplicationController

  def create
    logger.debug { "#create #{auth_hash.inspect}" }

    case auth_hash['provider']
    when 'cronofy'
      process_cronofy_login
    when 'eventbrite'
      process_eventbrite_login
    else
      log.warn { "#create provider=#{auth_hash['provider']} not recognised" }
      flash.alert = "Unrecognised provider login"
    end
    redirect_to :root
  end

  def failure
    render text: "Failed : #{params.inspect}"
  end

  def destroy
    logout
    redirect_to :root
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

  def process_cronofy_login
    @user = User.find_or_create_from_auth_hash(auth_hash)
    login(@user)
  end

  def process_eventbrite_login
    current_user.eventbrite_user_id = auth_hash['uid']
    current_user.eventbrite_access_token = auth_hash['credentials']['token']
    current_user.save
  end

end