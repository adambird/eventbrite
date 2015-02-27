class MainController < ApplicationController

  helper_method :eventbrite_orders, :grouped_calendars, :default_calendar_id

  def index

  end

  def destroy
    User.destroy(current_user.id)
    flash[:success] = "Account deleted"
    redirect_to :root
  end

  def sync
    eventbrite_orders.each do |order|
      event_synchronizer.sync_order(order, params[:calendar_id])
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
    return unless logged_in? && current_user.eventbrite_credentials?

    @eventbrite_orders ||= begin
      eventbrite = Eventbrite::API.new(current_user.eventbrite_access_token)
      eventbrite.upcoming_orders
    end
  end

  def grouped_calendars
    return unless logged_in?

    @grouped_calendars ||= begin
      event_synchronizer.editable_calendars
        .map { |c| [ c.calendar_name, "#{c.profile_name} [#{c.provider_name.titlecase}]", c.calendar_id ] }
        .group_by { |c| c[1] }
    end
  end

  def default_calendar_id
    event_synchronizer.default_calendar_id
  end

  def event_synchronizer
    return unless logged_in?

    @event_synchronizer ||= EventSynchronizer.new(current_user)
  end
end