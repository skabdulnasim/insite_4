module AppConfigurationManagement

########################################
## Get the app_configutaion of current client
########################################
  def self.get_app_configutaion(config_key)
    _app_configuration = AppConfiguration.where(:config_key => config_key).first
    if _app_configuration.present?
	  return _app_configuration.config_value
    end
  end
############################################ 

########################################
## Save the app_configutaion of current client
########################################
  def self.save_app_configutaion(config_key, config_value)
  	puts config_value
    _app_configuration = AppConfiguration.where(:config_key => config_key).first
    _app_configuration[:config_value] = config_value
    _app_configuration.save
  end
############################################ 

########################################
## Create app_configutaion of current client
########################################
  def self.load_basic_configurations(config_key, config_value)
  	if !AppConfiguration.where(:config_key => config_key).first.present?
  	  _app_configuration = AppConfiguration.new
	  _app_configuration[:config_key] = config_key
	  _app_configuration[:config_value] = config_value
	  _app_configuration.save
	end
  end
############################################ 

end