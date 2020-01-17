class Beneficiary < ActiveRecord::Base
  attr_accessible :account_number, :bank_name, :ifsc, :name, :resource_id,:payment_mode,:branch,:beneficiary_type,:pan_no,:status, :beneficiary_percentage
  belongs_to :resource

  # => Model validations
  validates :account_number,  :presence => true
  validates :bank_name,            :presence => true
  validates :ifsc,     :presence => true
  validates :name,  :presence => true
  validates :payment_mode,     :presence => true
  validates :branch,  :presence => true
  validates :beneficiary_type,            :presence => true

  scope :by_resource_id, lambda{|resource_id|where(["resource_id=?",resource_id])}
end
