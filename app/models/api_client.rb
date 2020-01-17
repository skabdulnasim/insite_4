class APIClient
  require "net/http"
  require 'resolv-replace'
  API_KEY ="YOTTO05"
  # API_BASE_URL = "http://#{(AppConfiguration.get_config_value('site_url')).to_s}/"
  HL_BASE_URL = "http://hungryleopard.com/"
  # HL_BASE_URL = "http://176.9.20.35:3002/"

  def self.find(resource,id)
    _api_base_url = "http://#{(AppConfiguration.get_config_value('site_url')).to_s}/"
    uri = URI.parse("#{_api_base_url}#{resource}/#{id.to_i}.json?device_id=#{API_KEY}")
    rest_response = Net::HTTP.get_response(uri)
    response_body = JSON.parse(rest_response.body, :symbolize_names => true)
  end

  def self.hl_get_resource(resource,parammeters)
    uri = URI.parse("#{HL_BASE_URL}api/restapi/#{resource}.json?#{parammeters}")
    rest_response = Net::HTTP.get_response(uri)
    response_body = JSON.parse(rest_response.body, :symbolize_names => true)
  end

  def self.hl_post_resource(resource,data)
    uri = URI.parse("#{HL_BASE_URL}api/restapi/#{resource}.json")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, {'Content-Type' =>'application/json'})
    request.set_form_data(data)
    response = http.request(request)
    response_body = JSON.parse(response.body, :symbolize_names => true)
  end

end
