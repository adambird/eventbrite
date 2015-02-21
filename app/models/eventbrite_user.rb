class EventbriteUser
  include Hatchet

  Order = Struct.new(:id, :name, :start_time, :end_time, :description, :url)

  attr_reader :access_token

  def initialize(access_token)
    @access_token = access_token
  end

  def orders
    @orders ||= begin
      response = api_connection.get("/v3/users/me/orders/") do |request|
        request.headers['Authorization'] = "Bearer #{access_token}"
      end

      unless response.success?
        log.debug { "#orders response headers #{response.headers}"}
        raise "#{response.status}"
      end

      JSON.parse(response.body)['orders']
        .reject { |order| order['event'].nil? }
        .map do |order| Order.new(
          order['event_id'],
          order['event']['name']['text'],
          Time.parse(order['event']['start']['utc']),
          Time.parse(order['event']['end']['utc']),
          order['event']['description'],
          order['event']['url']
          )
        end
    end
  end

  def upcoming_orders
    orders.select { |order| order.start_time > Time.now.to_date }
  end

  def api_connection
    @api_connection ||= Faraday.new(:url => 'https://www.eventbriteapi.com')
  end
end