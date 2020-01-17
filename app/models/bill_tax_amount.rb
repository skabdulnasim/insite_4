class BillTaxAmount < ActiveRecord::Base
  attr_accessible :bill_id, :tax_class_id, :tax_amount
  
  belongs_to :bill, inverse_of: :bill_tax_amounts
  belongs_to :tax_class

  validates :tax_class,   :presence => true
  validates :tax_amount,  :presence => true

  scope :by_tax_id,   lambda {|tax_id|where(["tax_class_id =(?)", tax_id])}

end
