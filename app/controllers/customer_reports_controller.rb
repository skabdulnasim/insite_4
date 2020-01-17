class CustomerReportsController < ApplicationController
	layout "material"
  
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details
  before_filter :set_timerange, only: [:by_date_customer_details]


  def index
    @units = Unit.by_unittype(3)
    respond_to do |format|
      format.html
    end
  end

  def customer_details
    @customers = Customer.order("id asc")
    smart_listing_create :customer_details, @customers, partial: "customer_reports/customer_details"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data customer_details_to_csv(@customers), filename: "customer-details.csv" } 
    end
  end

  def by_date_customer_details
    customer_ids = Array.new()
    @unit_id = params[:unit_id].present? ? params[:unit_id] : current_user.unit_id
    @customer_ids = Bill.select("DISTINCT(customer_id)").unit_bills(@unit_id).by_recorded_at(@from_datetime,@to_datetime).valid_bill
    @customer_ids.map { |customer| customer_ids.push customer.customer_id if customer.customer_id!= nil}
    @customers = Customer.set_id(customer_ids)
    smart_listing_create :by_date_customer_details, @customers, partial: "customer_reports/by_date_customer_details"
    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.csv { send_data by_date_customer_details_to_csv(@customers,@unit_id,@from_datetime,@to_datetime), filename: "by-date-customer-details.csv" } 
    end
  end

  private
  def set_module_details
    @module_id = "reports"
    @module_title = "Sales Report"
  end 

  def customer_details_to_csv(customers)
    CSV.generate do |csv|

      csv << ["Customer Name","Phone No", "Address", "Total Orders Count", "Total Bill Amount", "Last Visiting Date"]
      customers.each do |object|
        if object.customer_profile.customer_name.present?
          customer_name = object.customer_profile.customer_name
        else
          customer_name = "#{object.try(:customer_profile).try(:firstname)} #{object.try(:customer_profile).try(:lastname)}"
        end  
        if object.customer_profile.address.present? 
          addres = object.customer_profile.address
        elsif object.addresses.present?
          addres= object.addresses.first.delivery_address
        else
          addres= '-' 
        end
        ord_count = get_orders_count_of_customer(object)  
        total_bill_amount = get_total_bill_amount(object) 
        if object.bills.present?
          date_time = object.bills.last.recorded_at.strftime("%d-%m-%Y, %I:%M %p")  
        else
          date_time = "Not Visiting Yet"
        end  
        csv << ["#{customer_name}", "#{object.mobile_no}", "#{addres}", "#{ord_count}", "#{total_bill_amount}","#{date_time}"]
      end
    end
  end

  def by_date_customer_details_to_csv(customers,unit_id,from_datetime,to_datetime)
    CSV.generate do |csv|

      csv << ["Customer Name","Phone No", "Email","Address","Total Bill Amount(#{currency})"]
      customers.each do |object|
        total_bill_amount = get_total_bill_amount_by_date(object,from_datetime,to_datetime,unit_id)
        if total_bill_amount > 0
          if object.customer_profile.customer_name.present?
            customer_name = object.customer_profile.customer_name
          else
            customer_name = "#{object.try(:customer_profile).try(:firstname)} #{object.try(:customer_profile).try(:lastname)}"
          end  
          if object.customer_profile.address.present? 
            addres = object.customer_profile.address
          elsif object.addresses.present?
            addres= object.addresses.first.delivery_address
          else
            addres= '-' 
          end
          if object.email.present?  
            email = object.email 
          else
            email = '-' 
          end  
          total_bill_amount = get_total_bill_amount_by_date(object,from_datetime,to_datetime,unit_id)
          csv << ["#{customer_name}", "#{object.mobile_no}","#{email}", "#{addres}", "#{total_bill_amount}"]
        end  
      end
    end

  end

end
