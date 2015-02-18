class SessionsController < ApplicationController

  def create
    Rails.logger.debug auth_hash.inspect
    @user = User.find_or_create_from_auth_hash(auth_hash)
    login(@user)
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