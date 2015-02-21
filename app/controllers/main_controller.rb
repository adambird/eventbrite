class MainController < ApplicationController

  helper_method :eventbrite_orders

  def index


  end

  def sync
    eventbrite_orders.each do |order|
      EventSynchronizer.new(order, current_user.cronofy_access_token).sync
    end
    redirect_to :root
  end

  def eventbrite_orders
    @eventbrite_orders ||= begin
      if logged_in? && current_user.eventbrite_credentials?
        eventbrite = Eventbrite::API.new(current_user.eventbrite_access_token)
        eventbrite.upcoming_orders
      end
    end
  end
end