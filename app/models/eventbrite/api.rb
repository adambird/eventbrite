module Eventbrite
  class API
    include Hatchet

    attr_reader :access_token

    def initialize(access_token)
      @access_token = access_token
    end

    def connection
      @connection ||= Faraday.new('https://www.eventbriteapi.com')
    end

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
      orders.select { |order| order.start_time > Time.now.to_date }
    end

  end
end