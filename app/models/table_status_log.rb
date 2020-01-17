class TableStatusLog < ActiveRecord::Base
  attr_accessible :outlet_id, :table_id, :table_state_id, :table_state_name, :user_id, :device_id
  belongs_to :table

  # => Model validations
  validates :outlet_id,       :presence => true
  validates :table_id,        :presence => true
  validates :table_state_id,  :presence => true
  validates :user_id,         :presence => true

end
