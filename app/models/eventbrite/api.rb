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

    # utility method for iterating over all pages of a given resource
    def all_pages(resource_path, items_key)
      current_page = 1
      items = []

      begin
        log.info { "#all_pages #{resource_path} current_page=#{current_page}" }
        response = connection.get("#{resource_path}?page=#{current_page}") do |request|
          request.headers['Authorization'] = "Bearer #{access_token}"
        end

        unless response.success?
          log.warn { "#all_pages #{resource_path} response #{response.status} headers #{response.headers}"}
          raise StandardError.new("HTTP: #{response.status}")
        end

        payload = JSON.parse(response.body)
        items.concat(payload[items_key])

        total_pages = payload['pagination']['page_count'].to_i
        current_page += 1

      end while current_page <= total_pages

      items
    end

    # Events you attend in Eventbrite are modelled as Orders
    # An order is composed of an Event which in turn is composed
    # a venue
    def orders
      @orders ||= all_pages("/v3/users/me/orders/", 'orders')
                    .reject { |order| order['event'].nil? }
                    .map { |order| Eventbrite::Order.load_from_api(order) }
    end

    def upcoming_orders
      orders
        .select { |order| order.start_time > Time.now.to_date }
        .map do |order|
          if order_venue = venue(order.venue_id)
            order.set_location_from_venue(order_venue)
          end
          order
        end
    end

    def venue(venue_id)
      return if venue_id.blank?
      # don't lookup venue again if nothing returned last time
      return venue_dictionary[venue_id] if venue_dictionary.has_key?(venue_id)

      venue_dictionary[venue_id] = begin
        response = connection.get("/v3/venues/#{venue_id}/") do |request|
          request.headers['Authorization'] = "Bearer #{access_token}"
        end

        # log failures but don't fail
        if response.success?
          JSON.parse(response.body)
        else
          log.warn { "#venue venue_id=#{venue_id} response #{response.status} headers #{response.headers}"}
          nil
        end
      end
    end

    # local venue lookup to save duplicate API calls
    def venue_dictionary
      @venue_dictionary ||= {}
    end
  end
end