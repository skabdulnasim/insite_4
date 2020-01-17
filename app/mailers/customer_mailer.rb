class CustomerMailer < ActionMailer::Base
  def welcome_mail_to_customer(customer)
    @customer = customer
    @site_url = AppConfiguration.get_config('site_url')
    @site_title = AppConfiguration.get_config('site_title').split('|')[0].upcase
    _email_id = AppConfiguration.get_config('bill_email')
    _passwrd = AppConfiguration.get_config('bill_email_passwrd')
    admin_email = AppConfiguration.get_config('admin_email_bill')
  	CustomerMailer.smtp_settings = { 
  		:address              => 'smtp.gmail.com',
	    :port                 => 587,
	    :domain               => 'gmail.com',
	    :user_name            => _email_id,
	    :password             => _passwrd,
	    :authentication       => 'plain',
	    :enable_starttls_auto => true
    }
    mail(:to => admin_email, :subject => "New Customer Register", from: _email_id) if admin_email.present?
  end

  def new_customer_to_admin(customer)
    @customer = customer
    @site_url = AppConfiguration.get_config('site_url')
    @site_title = AppConfiguration.get_config('site_title').split('|')[0].upcase
    _email_id = AppConfiguration.get_config('bill_email')
    _passwrd = AppConfiguration.get_config('bill_email_passwrd')
    admin_email = AppConfiguration.get_config('admin_email_bill')
    CustomerMailer.smtp_settings = { 
      :address              => 'smtp.gmail.com',
      :port                 => 587,
      :domain               => 'gmail.com',
      :user_name            => _email_id,
      :password             => _passwrd,
      :authentication       => 'plain',
      :enable_starttls_auto => true
    }
    mail(:to => admin_email, :subject => "New Customer Register", from: _email_id) if admin_email.present? 
  end

end