class Otp < ActiveRecord::Base
  attr_accessible :otp, :phone_number, :verified

  # Model Relation
  #belongs_to :customer,  foreign_key: :phone_number, primary_key: :mobile_no

  #Sms Gateway details
  API_BASE_URL  = "smsapi.24x7sms.com/api_2.0/SendSMS.aspx?APIKEY="
  API_KEY       = 'Q2JRePQw7py'
  SenderID      = 'YOTTOL'
  ServiceName   = 'TEMPLATE_BASED'


  def generate_pin
  	self.otp = rand(0000..9999).to_s.rjust(4, "0")
  	save
	end

	def verify(entered_otp='')
  	self.update_attribute(:verified, true)
	end
  
  def send_pin
		if self.phone_number.present? 
      sms_sender_id = AppConfiguration.get_config('sms_sender_id') != '' ? AppConfiguration.get_config('sms_sender_id') : SenderID
      mobile_no = self.phone_number
      otp = self.otp
      # if self.app="kisok"
      app = DeveloperApp.last
      #message   = 'OTP is '+otp+' for login NoQ kiosk@choithrams. Enjoy the "Queue Free" shopping while sipping coffee.'
      message = 'OTP is '+otp+' for login '+app.name+'. Enjoy the "Queue Free" shopping while sipping coffee.'
      # else
      # message   = otp + ' is your OTP for registering with Table Tapp App for ordering food and booking a table at your favorite restaurants. Enjoy the experience. Enjoy the food.'
      # end
      message   = URI.encode(message)
      uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{sms_sender_id}&Message=#{message}&ServiceName=#{ServiceName}"   
      uri = URI.parse(uri)    
      rest_response = Net::HTTP.get_response(uri)   
    else
      puts "phone number missing"
    end
	end

end