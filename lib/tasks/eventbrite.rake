require 'faraday'
require 'json'
require 'hatchet'
include Hatchet

namespace :eventbrite do

  def notify_slack(webhook_url, message)
    raise ArgumentError.new("#notify_slack missing webhook_url") if webhook_url.blank?

    message[:username] = "Eventbrite Calendar Connector"

    Faraday.new(url: webhook_url).post do |req|
      req.headers['Content-Type'] = 'application/json'
      req.body = JSON.generate(message)
    end

  rescue => e
    log.error "Failed to send message - message=#{message} -  #{e.message}", e
    raise
  end


  desc "Report user metrics"
  task :report_user_metrics => :environment do

    total_user_count = User.count
    sync_always_user_count = User.where(sync_always: true).count
    message = "> Total Users: #{total_user_count}\n> Sync Always: #{sync_always_user_count}"

    notify_slack(ENV['SLACK_MONITORING_WEBHOOK_URL'], { text: message })
  end
end