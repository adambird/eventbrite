module Eventbrite
  class API
    include Hatchet

    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
    end

    def connection
      # haven't worked out how to add the Authorization header for every request
      @connection ||= Faraday.new('https://www.eventbriteapi.com')
    end

    # Events you attend in Eventbrite are modelled as Orders
    # An order is composed of an Event which in turn is composed
    # a venue
    def orders
      @orders ||= begin
        response = connection.get("/v3/users/me/orders/") do |request|
          request.headers['Authorization'] = "Bearer #{access_token}"
        end

        unless response.success?
          log.debug { "#orders response #{response.status} headers #{response.headers}"}
          raise "#{response.status}"
        end

        JSON.parse(response.body)['orders']
          .reject { |order| order['event'].nil? }
          .map { |order| Eventbrite::Order.load_from_api(order) }
      end
    end

    def upcoming_orders
      orders
        .select { |order| order.start_time > Time.now.to_date }
        .map do |order|
          order_venue = venue(order.venue_id)
          order.set_location_from_venue(order_venue)
          order
        end
    end

    def venue(venue_id)
      response = connection.get("/v3/venues/#{venue_id}/") do |request|
        request.headers['Authorization'] = "Bearer #{access_token}"
      end

      unless response.success?
        log.debug { "#orders response #{response.status} headers #{response.headers}"}
        raise "#{response.status}"
      end

      JSON.parse(response.body)
    end
  end
end