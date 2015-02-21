class MainController < ApplicationController

  helper_method :eventbrite_orders

  def index


  end

  def eventbrite_orders
    @eventbrite_orders ||= begin
      if logged_in? && current_user.eventbrite_credentials?
        eventbrite_user = EventbriteUser.new(current_user.eventbrite_access_token)
        eventbrite_user.upcoming_orders
      end
    end
  end
end