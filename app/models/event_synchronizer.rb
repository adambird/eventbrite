class EventSynchronizer
  include Hatchet

  attr_reader :order, :user

  def initialize(order, user)
    @order = order
    @user = user
  end

  def cronofy_api
    Cronofy::Cronofy.new(
      ENV["CRONOFY_CLIENT_ID"],
      ENV["CRONOFY_CLIENT_SECRET"],
      user.cronofy_access_token,
      user.cronofy_refresh_token
      )
  end

  # Currently just choosing first editable calendar in the linked account
  def calendar_id
    @calendar_id ||= editable_calendars.first['calendar_id']
  end

  def calendars
    api_request { cronofy_api.list_calendars['calendars'] }
  end

  def editable_calendars
    calendars.reject { |calendar| calendar['calendar_readonly']}
  end

  # Note in the representation of the event passed to Cronofy you use the
  # local ID so no mapping required on client side
  def cronofy_event
    {
      event_id: order.event_id,
      summary: order.name,
      description: "#{order.url}\n\n#{order.description}",
      start: order.start_time,
      end: order.end_time,
      location: {
        description: order.location
      }
    }
  end

  def sync
    api_request { cronofy_api.create_or_update_event(calendar_id, cronofy_event) }
  end

  # Wrapper for API requests to handle refreshing the access token when it's expired
  def api_request(&block)
    begin
      block.call
    rescue Cronofy::AuthenticationFailureError
      log.info "#api_request attempting to refresh token"
      refresh_user_access_token
      block.call
    rescue => e
      log.error "#api_request failed with #{e.message}", e
      raise
    end
  end

  def refresh_user_access_token
    credentials = cronofy_api.refresh_access_token
    user.cronofy_access_token = credentials.access_token
    user.cronofy_refresh_token = credentials.refresh_token
    user.save
  end
end