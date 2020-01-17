class TableState < ActiveRecord::Base
  attr_accessible :name, :color_code, :state_priority,:trash
  has_many :tables
end
