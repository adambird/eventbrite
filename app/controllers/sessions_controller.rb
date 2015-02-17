class SessionsController < ApplicationController

  def create
    Rails.logger.debug auth_hash.inspectj
    # @user = User.find_or_create_from_auth_hash(auth_hash)
    # self.current_user = @user
    # redirect_to '/'
  end

  protected

  def auth_hash
    request.env['omniauth.auth']
  end

end