class Chair < ActiveRecord::Base
  attr_accessible :angle, :table_id
  belongs_to :table
end
