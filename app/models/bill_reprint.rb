class BillReprint < ActiveRecord::Base
  attr_accessible	:bill_id, :recorded_at, :reprint_reason, :user_id
  belongs_to		:bill
  belongs_to    :user
  after_create	:update_bill_reprint

  validates 		:bill_id, :presence => true
  validates 		:reprint_reason, :presence => true
  validates 		:user_id, :presence => true
  
  def update_bill_reprint
  	# _reprint_count=self.bill.reprint_count+1
  	self.bill.update_column(:reprint_count, self.bill.reprint_count+1)
  end
end
