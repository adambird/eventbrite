class EventSynchronizer

  attr_reader :order, :cronofy_access_token

  def initialize(order, cronofy_access_token)
    @order = order
    @cronofy_access_token = cronofy_access_token
  end

  def cronofy_api
    @cronofy ||= Cronofy::Cronofy.new(ENV["CRONOFY_CLIENT_ID"], ENV["CRONOFY_CLIENT_SECRET"], cronofy_access_token)
  end

  # Currently just choosing first calendar in the in the linked account
  def calendar_id
    @calendar_id ||= cronofy_api.list_calendars['calendars'].first['calendar_id']
  end

  # Note in the representation of the event passed to Cronofy you use the
  # local ID so no mapping required on your side
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
    cronofy_api.create_or_update_event(calendar_id, cronofy_event)
  end
end