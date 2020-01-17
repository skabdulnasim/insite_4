class TypeOfCuisine < ActiveRecord::Base
  attr_accessible :name

  has_many :unit_type_of_cusines, dependent: :destroy
  has_many :units, through: :unit_type_of_cusines
  
end
