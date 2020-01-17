class Day < ActiveRecord::Base
  attr_accessible :name
  has_many :menu_mappings
end
