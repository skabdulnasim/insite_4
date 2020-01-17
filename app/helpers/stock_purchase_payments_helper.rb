module StockPurchasePaymentsHelper
	def get_payment_status(object,options={})
    options[:unpaid]    ||= 'Unpaid'
    options[:paid]      ||= 'Paid'
    
    if object.payment_status == 'unpaid'
      content_tag(:span, options[:unpaid], :class => 'm-label orange')
    elsif object.payment_status == 'paid'
      content_tag(:span, options[:paid], :class => 'm-label green')  
    end
  end  
end
