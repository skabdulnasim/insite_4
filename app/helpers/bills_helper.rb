module BillsHelper
  def get_order_details_from_order(order_id)
    _order_details = OrderDetail.where("order_id = ?", order_id)
  end  

  def get_bill_status(object,options={})
    options[:unpaid]    ||= 'Unpaid'
    options[:paid]      ||= 'Paid'
    options[:void]      ||= 'Void'
    options[:no_charge] ||= 'No Charge'
    options[:cod]       ||= 'COD'
    options[:boh]       ||= 'BOH'
    options[:cancled]    ||= 'CANCLED'
    if object.unpaid?
      content_tag(:span, options[:unpaid], :class => 'm-label orange')
    elsif object.paid?
      content_tag(:span, options[:paid], :class => 'm-label green')  
    elsif object.void?
      content_tag(:span, options[:void], :class => 'm-label red') 
    elsif object.no_charge?
      content_tag(:span, options[:no_charge], :class => 'm-label grey')      
    elsif object.cod?
      content_tag(:span, options[:cod], :class => 'm-label blue')         
    elsif object.boh?
      content_tag(:span, options[:boh], :class => 'm-label pink')   
    elsif object.cancled?
      content_tag(:span, options[:cancled], :class => 'm-label black')            
    end
  end

  def show_bill_delivery_name(object)
    if ['Address','Customer'].include?(object.deliverable_type)
      content_tag(:span, "#{object.deliverable_type}")
    elsif ['Resource'].include?(object.deliverable_type)
      content_tag(:span,"#{object.resource_type}: #{object.deliverable.name}")
    else  
      content_tag(:span, "#{object.deliverable_type}: #{object.deliverable.name}")
    end
  end

  def show_bill_settlement_amount(object)
    if object.settlement.present? && object.settlement.split_settlements.present?
      settlement_amount = object.settlement.split_settlements.map{ |e| e.bill_split_ammount }.sum
    elsif object.settlement.present? && object.settlement.split_settlements.empty?
      settlement_amount = object.settlement.bill_amount
    else
      settlement_amount = '_'  
    end  
  end

  def get_payment_status(bill,options={})
    bill_settlement = bill.settlement
    options[:unpaid]    ||= "#{currency} #{bill.grand_total} to be collected on delivery."
    options[:void]      ||= 'Void bill, payment not required.'
    options[:noch]      ||= 'No charge bill, payment not required.'
    if bill.void?
      concat(content_tag(:span, options[:void], :class => 'red-text'))
    elsif bill.no_charge?
      concat(content_tag(:span, options[:noch], :class => 'red-text'))
    elsif bill_settlement.present? and bill_settlement.status == 'paid'
      concat(content_tag(:h6, "Bill paid on #{bill_settlement.created_at.strftime('%d-%m-%Y, %I:%M %p')}", :class => 'grey-text'))
      bill_settlement.payments.each do |pay|
        concat(content_tag(:h5, "#{currency} #{pay.paymentmode.amount} paid through #{pay.paymentmode_type}", :class => 'teal-text'))
      end
    else
      concat(content_tag(:span, options[:unpaid], :class => 'grey-text'))
    end
  end

  def get_todays_settlement_data(unit_id,from_datetime,to_datetime)
    settlement_data = Bill.get_unit_settlement_data(unit_id,from_datetime,to_datetime)
  end

  def get_paymentmod_details
    @distinct_payment_mode = Payment.select(:paymentmode_type).uniq
    @distinct_payment_mode.each do |payment|
      concat (content_tag(:ol, class: ["collection-item","checkbox","margin-t-b-2", "padding-r-none","padding-l-none"], :style => "-webkit-user-drag: none;") {
        concat (radio_button_tag('paymentmode', payment.paymentmode_type, false, :id => "paymentmode_#{payment.paymentmode_type}", :class=>"filled-in payment-mode-type" ))
        concat (label_tag("paymentmode_#{payment.paymentmode_type}", payment.paymentmode_type.humanize))
        if payment.paymentmode_type == "ThirdPartyPayment"
          concat (content_tag(:div, class: ["third-party-payment"], :style => "display: none;"){
            ThirdPartyPaymentOption.all.each do |thirdparty|
              concat (content_tag(:ol, class: ["collection-item","checkbox","margin-t-b-2", "padding-r-none"], :style => "-webkit-user-drag: none; padding-left: 15px;") {
                concat (check_box_tag('third_party_id[]', thirdparty.id, false, :id => "third_party_#{thirdparty.id}", :class=>"filled-in payment-mode-options" ))          
                concat (label_tag("third_party_#{thirdparty.id}",thirdparty.name.humanize)) 
              })
            end
          })
        end
        if payment.paymentmode_type == "CouponPayment"
          concat (content_tag(:div, class: ["coupon-payment"], :style => "display: none;"){
            Coupon.all.each do |coupon|
              concat (content_tag(:ol, class: ["collection-item","checkbox","margin-t-b-2", "padding-r-none"], :style => "-webkit-user-drag: none; padding-left: 15px;") {
                concat (check_box_tag('coupon_id[]', coupon.id, false, :id => "coupon_#{coupon.id}", :class=>"filled-in payment-mode-options" ))          
                concat (label_tag("coupon_#{coupon.id}",coupon.name.humanize)) 
              })
            end
          })
        end   
      })  
    end  
  end

  def age(dob)
    dob = dob.present? ? dob : Date.today
    now = Date.today
    months = (now.year * 12 + now.month) - (dob.year * 12 + dob.month)
    readable_age(months / 12, months % 12) 
  end

  def readable_age(years, months)
    # for under 1 year olds
    if years == 0
      return months > 1 ? months.to_s + " months" : months.to_s + " month"  
    # Only for years  
    elsif months == 0
      return years > 1 ? years.to_s + " years" : years.to_s + " year"   

    # for 1 year olds
    elsif years == 1
      return months > 1 ? years.to_s + " year and " + months.to_s + " months" : years.to_s + " year and " + months.to_s + " month" 

    # for older than 1
    else
      return months > 1 ? years.to_s + " years and " + months.to_s + " months" : years.to_s + " years and " + months.to_s + " month"
    end
  end
  
end
