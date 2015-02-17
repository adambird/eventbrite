Rails.application.config.middleware.use OmniAuth::Builder do
  provider :cronofy, ENV["CRONOFY_KEY"], ENV["CRONOFY_SECRET"], {
    scope: "read_account"
  }
end