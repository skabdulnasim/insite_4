Apipie.configure do |config|
  config.app_name                = "Touchventory"
  config.api_base_url            = ""
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  # config.api_controllers_matcher = "#{Rails.root}/app/controllers/*.rb"
  config.api_controllers_matcher = File.join(Rails.root, "app", "controllers", "api","v2", "**","*.rb")
  config.copyright            = "Yottolabs Pvt. Ltd."
  config.app_info             = "A Smart Inventory Solution"
  config.authenticate = Proc.new do
    authenticate_or_request_with_http_basic do |username, password|
     username == "admin" && password == "welcome@123"
    end
  end  
end
