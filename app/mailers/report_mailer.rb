class ReportMailer < ActionMailer::Base
  #default from: "fd.banerjee29@gmail.com"

  def sale_summary_email(subdomain)
  	ReportMailer.smtp_settings = { 
  		:address              => 'smtp.gmail.com',
	    :port                 => 587,
	    :domain               => 'gmail.com',
	    :user_name            => 'report@yottolabs.com',
	    :password             => 'sale_report@123',
	    :authentication       => 'plain',
	    :enable_starttls_auto => true
    }
    Apartment::Database.switch(subdomain)
    if AppConfiguration.get_config_value('report_send_by_email') == 'enabled'
      @units = Unit.by_unittype(3).order("unit_name asc")
      _date = Date.today - 1.days
      @owner_email = AppConfiguration.get_config('email_for_send_sale_details')
      mail(:to => @owner_email, :subject => "#{_date} sales report", from: "report@yottolabs.com") if @owner_email.present?
    end  
  end
  
end