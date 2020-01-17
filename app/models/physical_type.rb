class PhysicalType < ActiveRecord::Base
  attr_accessible :name
  paginates_per 10
end
