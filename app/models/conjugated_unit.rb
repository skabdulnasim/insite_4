class ConjugatedUnit < ActiveRecord::Base
	attr_accessible :conjugated_name
	belongs_to :product
end	