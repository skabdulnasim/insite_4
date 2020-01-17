class BillDiscount < ActiveRecord::Base
  attr_accessible :bill_id, :discount_amount, :remarks, :is_merchant_discount, :title, :rate

  ### => Model Relations
  belongs_to :bill, inverse_of: :bill_discounts

  ### => Model validations
  validates :discount_amount, :presence => true

  before_validation :set_discount_amount
  after_create :update_bill
  #MOdel Scope
  scope :is_merchant_discount, lambda {where("is_merchant_discount = ?",'true')}

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('is_merchant_discount')
        self.is_merchant_discount = 'true'
      end
    end
  end

  private

  def set_discount_amount
    _current_discount = self.bill.bill_discounts.sum :discount_amount
    if (self.discount_amount + _current_discount) > self.bill.bill_amount_with_tax
      self.discount_amount = self.bill.bill_amount_with_tax - _current_discount
    end
  end

  def update_bill
    _total_discount = self.bill.bill_discounts.sum :discount_amount
    raise "Discount amount can not be greater than bill amount" if _total_discount > self.bill.bill_amount_with_tax
    self.bill.update_column(:discount, _total_discount)
  end
end