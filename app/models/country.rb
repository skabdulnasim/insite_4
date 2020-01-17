class Country < ActiveRecord::Base
  attr_accessible :code, :currency, :name
  has_many :denominations

  scope :by_country, lambda {|name|where(["name=?", name])}
end
