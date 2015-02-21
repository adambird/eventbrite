module Eventbrite
  class Order

    attr_accessor :description,
                  :end_time,
                  :event_id,
                  :name,
                  :start_time,
                  :url

    def initialize(args)
      args.each_pair { |k,v| send("#{k}=", v) }
    end

    def self.load_from_api(data)
      self.new(
        event_id: data['event_id'],
        name: data['event']['name']['text'],
        start_time: Time.parse(data['event']['start']['utc']),
        end_time: Time.parse(data['event']['end']['utc']),
        description: data['event']['description']['text'],
        url: data['event']['url']
      )
    end
  end
end