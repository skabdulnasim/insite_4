class BillMailer < ActionMailer::Base
  ## Bill send to admin
  def bill_details_mail_to_admin(bill)
    @bill = bill
    @customer = bill.customer
    @site_url = AppConfiguration.get_config('site_url')
    _email_id = AppConfiguration.get_config('bill_email')
    _passwrd = AppConfiguration.get_config('bill_email_passwrd')
    admin_email = AppConfiguration.get_config('admin_email_bill')
  	BillMailer.smtp_settings = { 
  		:address              => 'smtp.gmail.com',
	    :port                 => 587,
	    :domain               => 'gmail.com',
	    :user_name            => _email_id,
	    :password             => _passwrd,
	    :authentication       => 'plain',
	    :enable_starttls_auto => true
    }
    #mail(:to => "gobinda@yottolabs.com", :subject => "Bill Details", from: _email_id)
    mail(:to => admin_email, :subject => "Bill Details", from: _email_id) if admin_email.present?
  end

  ## Bill send to customer
  def bill_details_mail_to_customer(bill)
    @bill = bill
    @customer = bill.customer
    @site_url = AppConfiguration.get_config('site_url')
    _email_id = AppConfiguration.get_config('bill_email')
    _passwrd = AppConfiguration.get_config('bill_email_passwrd')
    BillMailer.smtp_settings = { 
      :address              => 'smtp.gmail.com',
      :port                 => 587,
      :domain               => 'gmail.com',
      :user_name            => _email_id,
      :password             => _passwrd,
      :authentication       => 'plain',
      :enable_starttls_auto => true
    }
    if @customer.present?
      mail(:to => @customer.email, :subject => "Bill Details", from: _email_id) if @customer.email.present?
    end  
  end

end