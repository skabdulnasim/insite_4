require 'fcm'
class Notification < ActiveRecord::Base
  attr_accessible :description, :viewed, :json_data, :notification_type, :target_url, :title, :unit_id, :priority, :notification_source_type, :notification_source_id, :role_id
  
  # => Model relations
  belongs_to :unit
  belongs_to :role
  belongs_to :notification_source, :polymorphic => true
  # belongs_to :stock, foreign_key: 'notification_source_id', conditions: "notifications.notification_source_type = 'Stock'"
  # belongs_to :stock, foreign_key: 'notification_source_id', -> { where :notification_source_type => "Stock" }
  belongs_to :stock, -> { where "notifications.notification_source_type" => "Stock" }, foreign_key: 'notification_source_id'
  # => Defining notification priority
  PRIORITY = %w(low medium high)
	
  # => Model validations
  validates :title, 						  :presence => true
	validates :notification_type,  :presence => true
  validates :priority,            :presence => true, :inclusion => {:in => PRIORITY}
  
  # => Dynamic methods for bill statuses
  PRIORITY.each do |priority|
    define_method "#{priority}?" do
      self.priority == priority
    end
  end

  # => Dynamically defining these custom finder methods
  class << self
    PRIORITY.each do |priority|
      define_method "#{priority}" do
        where(["priority=?", priority])
      end
    end
  end

  # => Model scopes
  scope :set_unit, lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :set_unit_or_role, lambda {|unit_id,role_id|where(["unit_id=? OR role_id=?", unit_id,role_id])}
  scope :set_type, lambda {|type|where(["notification_type=?", type])}
  scope :is_unread, lambda { where(:viewed => false) }
  scope :type_inventory, lambda { where(:notification_type => 'inventory') }
  scope :type_sales, lambda { where(:notification_type => 'sales') }
  scope :set_notification_source_type,    lambda {|ns_type|where(["notification_source_type=?", ns_type])}
  scope :set_notification_source_id,    lambda {|ns_id|where(["notification_source_id=?", ns_id])}

  def self.new_notification(title,description,notification_type,target_url,unit_id,json_data,priority,notification_source_type='',notification_source_id='')
    _new_notice = Notification.create(:title=>title, :description=>description, :notification_type=>notification_type, :target_url=>target_url, :unit_id=>unit_id, :viewed=>false, :json_data=>json_data, :priority=>priority, :notification_source_type=>notification_source_type, :notification_source_id=>notification_source_id)
    # Publish in faye
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _channels=Array.new
    _channels.push "/notifications/portal/subdomain/#{_subdomain.config_value}/unit/#{unit_id}/generic"
    _hash = {:type => notification_type, :json_data => _new_notice}
    Notification.publish_in_faye(_channels,_hash)  
  end

  def self.new_role_notification(title,description,notification_type,target_url,role_id,json_data,priority,notification_source_type='',notification_source_id='')
    _new_notice = Notification.create(:title=>title, :description=>description, :notification_type=>notification_type, :target_url=>target_url, :role_id=>role_id, :viewed=>false, :json_data=>json_data, :priority=>priority, :notification_source_type=>notification_source_type, :notification_source_id=>notification_source_id)
    # Publish in faye
    _subdomain = AppConfiguration.find_by_config_key('site_id')
    _channels=Array.new
    _channels.push "/notifications/portal/subdomain/#{_subdomain.config_value}/role/#{role_id}/generic"
    _hash = {:type => notification_type, :json_data => _new_notice}
    Notification.publish_in_faye(_channels,_hash)  
  end

  def self.publish_in_faye(channels, data)
    channels.each do |channel|
      message = {:channel => channel, :data=> data, :ext  => {:auth_token => FAYE_TOKEN}}
      uri = URI.parse(FAYE_SERVER_URL)
      Net::HTTP.post_form(uri, :message => message.to_json)
    end
  end

  def self.send_fcm_notification(message)
    server_key  = "AAAAkWub7wo:APA91bEH7iOMNy42sOLkl1Gwn3wz8sH9gP_IbcdhB8xZX7bMqaswhYHSGZfVcE6Vsgy1tnt9RVA9G-W3MRyCk4-C6NLX9xkLorF6r-yil3fQbOoGE95zzZp4Z2RqBq0MCXiNRhKa1NLf"
    fcm_notifiaction = FCM.new(server_key)
    registration_device_ids = ["ceLBb6zhDrQ:APA91bHSDau9N9xHaDcThUY3nPKErMQQYAlIFIS3PSojPv0sFxMH0UxOgucyXpVI1ZhsxSs3XgDUcplLIMsGA036xm6hSI9xU1iaRtk6p598cRdW8nng3gZAUTxNV_Ug3CkEeclk0jC5"]
    options = {data: {notification: message}, collapse_key: "updated_count"} 
    registration_device_ids.each do |device_id|
      resp =fcm_notifiaction.send(device_id,options)
      puts resp
    end
  end

end
