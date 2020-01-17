class ReportPreference < ActiveRecord::Base
  attr_accessible :allowed_attributes, :report_key, :unit_id
  
  # => Model relations
  belongs_to  :unit

  # => Model scopes
  scope :by_key,  lambda {|report_key|where(["report_key=?", report_key])}
  scope :by_unit, lambda {|unit_id|where(["unit_id=?", unit_id])}  
end
