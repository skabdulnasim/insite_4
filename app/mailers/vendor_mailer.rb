class VendorMailer < ActionMailer::Base
  #default from: "gobinda.manna67@gmail.com"
  # default :from => "example@gmail.com"

  def vendor_email(purchase_order,currency,current_user,stock_purchase='')
  	# @unit = current_user.unit.name
  	admin_email = AppConfiguration.get_config_value('admin_email')
  	admin_email_pass = AppConfiguration.get_config_value('admin_email_password')
  	@stock_purchase = stock_purchase
  	if !admin_email.nil?
  		puts "not nil"
	  	VendorMailer.smtp_settings = { 
	  		:address              => 'smtp.gmail.com',
		    :port                 => 587,
		    :domain               => 'gmail.com',
		    :user_name            => admin_email,
		    :password             => admin_email_pass,
		    :authentication       => 'plain',
		    :enable_starttls_auto => true
	    }
	  	@purchase_order = purchase_order
	  	@currency = currency
	  	@current_user = current_user
	  	@cc_emails = AppConfiguration.get_config('cc_emails')
	  	mail(to: @purchase_order.vendor.email, cc: @cc_emails, subject: 'purchase order created sucessfully', from: admin_email) if @purchase_order.vendor.email.present?
  	else
  		puts "nil"
  	end
  end

  def vendor_smart_po_email(smart_po,currency,current_user)
  	admin_email = AppConfiguration.get_config_value('admin_email')
  	admin_email_pass = AppConfiguration.get_config_value('admin_email_password')
  	if !admin_email.nil?
	  	VendorMailer.smtp_settings = { 
	  		:address              => 'smtp.gmail.com',
		    :port                 => 587,
		    :domain               => 'gmail.com',
		    :user_name            => admin_email,
		    :password             => admin_email_pass,
		    :authentication       => 'plain',
		    :enable_starttls_auto => true
	    }
	  	@smart_po = smart_po
	  	@currency = currency
	  	@current_user = current_user
	  	@cc_emails = AppConfiguration.get_config('cc_emails')
	  	mail(to: @smart_po.purchase_orders.first.vendor.email, cc: @cc_emails, subject: 'purchase order created sucessfully', from: admin_email) if @smart_po.purchase_orders.first.vendor.email.present?
  	else
  		puts "nil"
  	end
  end

end
