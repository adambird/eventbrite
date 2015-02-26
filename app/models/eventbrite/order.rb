module Eventbrite
  class Order

    attr_accessor :description,
                  :end_time,
                  :event_id,
                  :location,
                  :name,
                  :start_time,
                  :venue_id,
                  :url

    def initialize(args)
      args.each_pair { |k,v| send("#{k}=", v) }
    end

    def self.load_from_api(data)
      args = {
        event_id: data['event_id'],
        name: data['event']['name']['text'],
        start_time: Time.parse(data['event']['start']['utc']),
        end_time: Time.parse(data['event']['end']['utc']),
        url: data['event']['url'],
        venue_id: data['event']['venue_id']
      }

      args[:description] = data['event']['description']['text'] if data['event']['description']

      self.new(args)
    end

    def set_location_from_venue(venue)
      address = ["address_1", "address_2", "city", "region", "postal_code", "country"]
        .map { |field| venue['address'][field] }
        .reject { |value| value.blank? }
        .join(", ")

      @location = "#{venue['name']}, #{address}"
    end
  end
end