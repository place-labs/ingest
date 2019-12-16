require "uuid"

abstract class Application < ActionController::Base
  before_action :set_request_id
  before_action :set_date_header
  before_action :check_api_key

  private API_KEY = ENV["PLACE_API_KEY"]? || abort "PLACE_API_KEY not set in ENV"

  # This makes it simple to match client requests with server side logs.
  # When building microservices this ID should be propagated to upstream services.
  def set_request_id
    logger.client_ip = client_ip
    response.headers["X-Request-ID"] = logger.request_id = UUID.random.to_s

    # If this is an upstream service, the ID should be extracted from a request header.
    # response.headers["X-Request-ID"] = logger.request_id = request.headers["X-Request-ID"]? || UUID.random.to_s
  end

  def set_date_header
    response.headers["Date"] = HTTP.format_time(Time.utc)
  end

  def check_api_key
    head :forbidden unless request.headers["X-API-Key"]? == API_KEY
  end
end
