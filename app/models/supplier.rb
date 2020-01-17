class Supplier < ActiveRecord::Base
  #self.per_page = 15
  validates :name, :presence => true
  attr_accessible :name
end
