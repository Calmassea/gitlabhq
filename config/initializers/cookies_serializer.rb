# Be sure to restart your server when you modify this file.

Rails.application.config.action_dispatch.use_cookies_with_metadata = true
Rails.application.config.action_dispatch.cookies_serializer =
  Gitlab::Utils.to_boolean(ENV['USE_UNSAFE_HYBRID_COOKIES']) ? :hybrid : :json
