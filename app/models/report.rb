class Report < ActiveRecord::Base
  attr_accessible :name, :report_selectors, :report_criteria, :aggregation_functions

  belongs_to :report_folder
  
  API_KEY       = 'Q2JRePQw7py'
  MobileNo      = '919933648398'
  SenderID      = 'YOTTOL'
  message       = 'Thank you for your order with Yottolabs, Kolkata. Your Order ID is # "#{self.id}". Please give us 30 min to serve you fresh and hot food.'
  Message       = URI.encode(message)
  ServiceName   = 'TEMPLATE_BASED'
  API_BASE_URL  = "smsapi.24x7sms.com/api_2.0/SendSMS.aspx?APIKEY="

  def self.get_model_info(report_folder_id)
    _rel_names = ReportFolder.select("master_model,related_models").where(:id=>report_folder_id).first
    
    _model_collection = Hash.new
    _model_collection[_rel_names.master_model.pluralize]=_rel_names.master_model.to_s.classify.constantize.columns.map{|d| {:name => d.name,:type => d.sql_type}}
    
    if _rel_names.related_models.present?
       _rel_names.related_models.each do |related_model|
       _model_collection[related_model.pluralize]=related_model.to_s.pluralize.classify.constantize.columns.map{|d| {:name => d.name,:type => d.sql_type}}
      end
    end
    return _model_collection
  end
  
    
  def generate_report(report_aggregation=nil)
    report_relation        = self.report_folder.related_models
    selectors              = self.report_selectors
    selector_group         = self.group_attribute
    selectors_aggregation  = self.aggregation_functions
    if report_aggregation.present?
      select_attributes,order_attribute,group_attribute  = aggregate_att_settings(report_aggregation)
    elsif selectors_aggregation.present? && selector_group.present?
      select_attributes,order_attribute,group_attribute  = group_att_settings(selectors_aggregation,selector_group)
    else
      select_attributes,order_attribute,group_attribute  = select_att_settings(selectors)
    end
    report_relation        = report_relation.select {|entry| selectors.include?entry }
    master_model           = self.report_folder.master_model
    data = master_model.to_s.classify.constantize\
    .joins(report_relation.map {|keys| keys.to_sym}) \
    .where(self.report_criteria) \
    .select(select_attributes).order(order_attribute) \
    .group(group_attribute)
    return data
  end
  
  def aggregation_attributes
    @report_agg_data = []
    @report_aggregations = self.aggregation_functions.split(',')
    @report_aggregations.each do |report_aggregation|
      @report_agg_data.push('label' => report_aggregation, 'values' => self.generate_report(report_aggregation))
    end
    return @report_agg_data
  end
  
  def self.bill_wise_report(params)
    @unit_detail_options = Unit.where('id=?',params[:unit_id]).first.unit_detail.options
    if params[:from_date].present?
      _from_datetime = params[:from_date].to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _from_datetime ||= params[:from_date].to_date.beginning_of_day
      _to_datetime = params[:to_date].to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _to_datetime ||= params[:to_date].to_date.end_of_day
    else
      _from_datetime = params[:date].to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _from_datetime ||= params[:date].to_date.beginning_of_day
      _to_datetime = params[:date].to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _to_datetime ||= params[:date].to_date.end_of_day
    end  
    
    _data = Bill.unit_bills(params[:unit_id]).by_recorded_at(_from_datetime,_to_datetime)
    returnData = {}
    bills_arr = Array.new
    total_sale = 0
    total_card_sale = 0
    total_cash_sale = 0
    other_sale = 0
    paid = 0
    unpaid = 0
    cod = 0
    void = 0
    nc = 0
    total_pax = 0
    total_billed_amount = 0
    apc = 0
    section_bill = 0
    table_bill = 0
    take_away_bill = 0
    _data.each do |data|
      total_billed_amount += data['grand_total']
      if data.settlement.present?
        payments = data.settlement.payments
        payments.each do |payment|
          total_sale += payment.paymentmode['amount']
          if payment['paymentmode_type'] == "Cash"
            total_cash_sale += payment.paymentmode['amount'] 
          elsif payment['paymentmode_type'] == "Card"
            total_card_sale += payment.paymentmode['amount']
          else
            other_sale += payment.paymentmode['amount']
          end
        end
      end
      if data['status'] == "paid"
        paid += data['grand_total']  
      elsif data['status'] == "unpaid"
        unpaid += data['grand_total']
      elsif data['status'] == "cod"
        cod += data['grand_total']  
      elsif data['status'] == "void"
        void += data['grand_total']
      else
        nc += data['grand_total']
      end
      if data['deliverable_type'] == 'Section'
        section_bill += data['grand_total']
      elsif data['deliverable_type'] == 'Resource' && data['resource_type'] == 'table'
        table_bill += data['grand_total']  
        total_pax += data['pax']
        apc = table_bill/total_pax
      else
        take_away_bill += data['grand_total']        
      end  
        
      bills_hash = {}
      bills_hash[:bill_id]      = data['id']
      bills_hash[:bill_serial]  = data['serial_no']
      bills_hash[:bill_amount]  = data['grand_total']
      bills_hash[:created_time] = data['created_at'].strftime("%d/%m/%Y %I:%M %p")
      bills_hash[:recorded_time] = data['recorded_at'].strftime("%d/%m/%Y %I:%M %p")
      bills_hash[:source]       = data.orders.first['source']
      bills_arr.push bills_hash
    end
    returnData[:total_bills]     = bills_arr.length
    returnData[:total_billed]    = total_billed_amount.round(2)
    returnData[:total_settled]   = total_sale.round(2)
    returnData[:total_unsettled] = (unpaid + cod).round(2)
    returnData[:total_card_sale] = total_card_sale.round(2)
    returnData[:total_cash_sale] = total_cash_sale.round(2)
    returnData[:other_sale]      = other_sale.round(2)
    returnData[:nc]              = nc.round(2)
    returnData[:paid]            = paid.round(2)
    returnData[:unpaid]          = unpaid.round(2)
    returnData[:cod]             = cod.round(2)
    returnData[:void]            = void.round(2)
    returnData[:total_pax]       = total_pax 
    returnData[:apc]             = apc.round(2)
    returnData[:section_bill]    = section_bill.round(2)
    returnData[:table_bill]      = table_bill.round(2)
    returnData[:take_away_bill]  = take_away_bill.round(2)
    returnData[:all_bills]       = bills_arr
    return returnData
  end

  def self.category_wise_report(params)
    @unit = Unit.find(params[:unit_id])
    @unit_detail_options = @unit.unit_detail.options
    menu_cards = @unit.menu_cards.where(:trash=>nil, :mode=>1)
    category_sales = Array.new
    if params[:from_date].present?
      _from_datetime = params[:from_date].to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _from_datetime ||= params[:from_date].to_date.beginning_of_day
      _to_datetime = params[:to_date].to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _to_datetime ||= params[:to_date].to_date.end_of_day
    else
      _from_datetime = params[:date].to_date.beginning_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _from_datetime ||= params[:date].to_date.beginning_of_day
      _to_datetime = params[:date].to_date.end_of_day+@unit_detail_options[:day_closing_time].to_i.hours
      _to_datetime ||= params[:date].to_date.end_of_day
    end  
    order_id_for_bill = Bill.unit_bills(params[:unit_id]).by_recorded_at(_from_datetime,_to_datetime).valid_bill.map{|bill| bill.orders.map{|order| order.id}}.flatten
    _menu_products = menu_cards.map{|menu_card| menu_card.menu_products.map{|m_p| m_p.id}}.flatten
    category_sales = OrderDetail.where(:order_id =>order_id_for_bill,:trash=>0).where(:menu_product_id=>_menu_products).group("menu_product_id,product_name,product_id").select("product_id,product_name,menu_product_id,SUM(unit_price_without_tax * quantity) as total_sale, SUM(quantity) as quantity").order('menu_product_id')
    
    return category_sales
  end

  def self.send_email
    @accounts = Account.all
    @accounts.each do |account|
      ReportMailer.sale_summary_email(account.subdomain).deliver
    end 
  end 

  def self.send_bill_summary_sms
    Apartment::Database.switch('silvershine')
    unit = Unit.find(7)
    unit_detail_options = unit.unit_detail.options if unit.unit_detail.present?
    _open_to = unit_detail_options[:open_to]
    _closing_hour = unit_detail_options.present? ? unit_detail_options[:day_closing_time].to_i : (0).to_i
    _closing_time = _closing_hour
    _current_hour = Time.current.hour
    puts "_closing_time"
    puts Time.parse(_open_to)
    #puts _open_to
    puts "_current_hour"
    puts _closing_time
    #puts (_open_to.to_time - _closing_time.hours).to_datetime
    puts "utc"
    puts Time.parse(_open_to).strftime("%H:%M")
    # @accounts = Account.all
    # @accounts.each do |account|
    #   Apartment::Database.switch(account.subdomain)
    #   units  = Unit.by_unittype(3)
    #   unit = Unit.find(7)
    #   _current_hour = Time.current.hour
    #   unit_detail_options = unit.unit_detail.options if unit.unit_detail.present?
    #   _closing_hour = unit_detail_options.present? ? unit_detail_options[:day_closing_time].to_i : (0).to_i
    #   _closing_time = _closing_hour.hours
    #   # units.each do |unit|
    #   #   _current_hour = Time.current.hour
    #   #   unit_detail_options = unit.unit_detail.options if unit.unit_detail.present?
    #   #   _closing_hour = unit_detail_options.present? ? unit_detail_options[:day_closing_time].to_i : (0).to_i
    #   #   _closing_time = _closing_hour.hours
    #   #   # #mobile_no = '8420242804'
    #   #   # unit_name = 'test'
    #   #   # _Currency = 'Rs'
    #   #   # bill_amount = 123
    #   #   # if mobile_no.present? 
    #   #   #   puts mobile_no
    #   #   #   sms_sender_id = AppConfiguration.get_config('sms_sender_id') != '' ? AppConfiguration.get_config('sms_sender_id') : SenderID
    #   #   #   mobile_no = "91#{mobile_no}"
    #   #   #   message = 'Thank you for your order with us '+unit_name+'. Your Bill amount is '+_Currency+'.'+bill_amount.to_s+'. Please visit us again.'
    #   #   #   message   = URI.encode(message)   
    #   #   #   uri = "http://#{API_BASE_URL}#{API_KEY}&MobileNo=#{mobile_no}&SenderID=#{sms_sender_id}&Message=#{message}&ServiceName=#{ServiceName}"   
    #   #   #   uri = URI.parse(uri)    
    #   #   #   rest_response = Net::HTTP.get_response(uri)   
    #   #   #   puts rest_response.body 
    #   #   # end
    #   # end  
    # end 
  end

private
  def group_att_settings(selectors_aggregation,selector_group)
    
    select_attributes      = selectors_aggregation.split(',')
    select_attributes      = select_attributes.map {|keys| keys += ' AS '+ keys.gsub( ',', '_' ).gsub('.','_').gsub('(','_').gsub(')','')}
    
    if self.order_attribute.present? && self.order_attribute != selector_group
      select_attributes    = self.order_attribute+','+selector_group+','+select_attributes.join(',')
      order_attribute      = self.order_attribute 
      group_attribute      = selector_group+','+self.order_attribute
    elsif self.order_attribute.present? && self.order_attribute == selector_group
      select_attributes    = selector_group+','+select_attributes.join(',')
      order_attribute      = self.order_attribute 
      group_attribute      = selector_group
      
    else
      select_attributes    = selector_group+','+select_attributes.join(',')
      order_attribute      = ''
      group_attribute      = selector_group
    end

    return select_attributes,order_attribute,group_attribute
  end 
  
  def aggregate_att_settings(report_aggregation)
    select_attributes    = report_aggregation
    order_attribute      = ''
    group_attribute      = ''
    return select_attributes,order_attribute,group_attribute
  end  
  def select_att_settings(selectors)
    select_attributes    = selectors#.split(',').map { |e| e += ' AS '+ e.gsub( '.', '_' ) }
    order_attribute      = self.order_attribute if self.order_attribute.present?
    group_attribute      = ''
    return select_attributes,order_attribute,group_attribute
  end 
  
end
