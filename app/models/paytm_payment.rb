class PaytmPayment < ActiveRecord::Base
  attr_accessible :BANKNAME, :BANKTXNID, :GATEWAYNAME, :MID, :ORDERID, :PAYMENTMODE, :REFUNDAMT, :RESPCODE, :RESPMSG, :STATUS, :TXNAMOUNT, :TXNDATE, :TXNID, :TXNTYPE, :amount
  validates :TXNID, presence: true
  validates :ORDERID, presence: true
  validates :TXNAMOUNT, presence: true
  validates :TXNDATE, presence: true
  validates :MID, presence: true
  validates :amount, presence: true

  has_one :payment, as: :paymentmode
end
