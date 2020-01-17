module CashHandlingHelper
	def get_unit_cash_data(unit_id,from_datetime,to_datetime)
    cash_data = Pay.get_unit_cash_data(unit_id,from_datetime,to_datetime)
  end
  def get_transaction_type(object,options={})
  	options[:cash_in]    ||= 'Cash In'
    options[:cash_out]   ||= 'Cash Out'
    if object.CashIn?
      content_tag(:span, options[:cash_in], :class => 'm-label blue')
    elsif object.CashOut?
      content_tag(:span, options[:cash_out], :class => 'm-label orange')
    end
  end
end
