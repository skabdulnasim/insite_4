class CustomerWallet < ActiveRecord::Base
  attr_accessible :available_amount, :credited_amount, :customer_id, :debited_amount, :expiry_date, :return_item_id
  belongs_to :customer
  belongs_to :return_item
  has_one :payment, as: :paymentmode
end
