Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cronofy, ENV["CRONOFY_CLIENT_ID"], ENV["CRONOFY_CLIENT_SECRET"], {
    scope: "read_account list_calendars"
  }

  provider :eventbrite, ENV["EVENTBRITE_CLIENT_KEY"], ENV["EVENTBRITE_CLIENT_SECRET"]

end