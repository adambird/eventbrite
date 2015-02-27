class MainController < ApplicationController

  helper_method :eventbrite_orders, :calendars, :default_calendar_id

  def index

  end

  def destroy
    User.destroy(current_user.id)
    flash[:success] = "Account deleted"
    redirect_to :root
  end

  def sync
    eventbrite_orders.each do |order|
      event_synchronizer.sync_order(order)
    end

    flash[:success] = "Your Eventbrite events are now in your calendar"
    redirect_to root_path(sync_complete: 1)
  rescue => e
    log.error "#sync failed with #{e.message}", e
    flash[:error] = "Sorry, but something went wrong and we couldn't sync your events"
    redirect_to :root
  end

  def sync_always
    current_user.sync_always = true
    current_user.save
  end

  def eventbrite_orders
    @eventbrite_orders ||= begin
      return unless logged_in? && current_user.eventbrite_credentials?
      eventbrite = Eventbrite::API.new(current_user.eventbrite_access_token)
      eventbrite.upcoming_orders
    end
  end

  def calendars
    @calendars ||= begin
      return unless logged_in?
      event_synchronizer.editable_calendars
    end
  end

  def default_calendar_id
    event_synchronizer.default_calendar_id
  end

  def event_synchronizer
    @event_synchronizer ||= EventSynchronizer.new(current_user)
  end
end