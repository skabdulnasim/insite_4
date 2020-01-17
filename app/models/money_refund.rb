class MoneyRefund < ActiveRecord::Base
  attr_accessible :account_no, :customer_id, :ifsc_code, :order_id, :paymentmode, :refund_amount

  # Model Relations
  belongs_to :customer

  # Model Scopes
  scope :by_date_range, lambda {|from_date, upto_date|where('created_at BETWEEN ? AND ?',from_date,upto_date)}

  def self.by_date_refund_report_to_csv(money_refunds,from_datetime,to_datetime)
    CSV.generate do |csv|
      _header = ["Order Id","Refund Amount","Customer Name","Account No.","Ifsc Code"]
      csv << _header
      money_refunds.each do |refund_money|
        _row = Array.new
        _row.push(refund_money.order_id)
        _row.push(refund_money.refund_amount)
        if refund_money.customer.present?
          if refund_money.customer.customer_profile.customer_name.present?
            _row.push(refund_money.customer.customer_profile.customer_name)
          else
            _row.push("#{refund_money.customer.customer_profile.firstname} "" #{refund_money.customer.customer_profile.lastname}")
          end  
        else
          _row.push("....")
        end  
        _row.push(refund_money.account_no)
        _row.push(refund_money.ifsc_code)
        csv << _row
      end
    end
  end

end