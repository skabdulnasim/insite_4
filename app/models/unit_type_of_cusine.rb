class UnitTypeOfCusine < ActiveRecord::Base
  attr_accessible :type_of_cuisine_id, :unit_id

  # class relations
  belongs_to :unit
  belongs_to :type_of_cuisine

  def self.save_unit_cusine(current_unit, cuisine_types)
  	prev = self.where('unit_id =?', current_unit)
    prev.destroy_all if prev.present?
    if cuisine_types.present?
	  	cuisine_types.each do |cuisine_type|
	  	  UnitTypeOfCusine.create(:type_of_cuisine_id => cuisine_type, :unit_id => current_unit)
	  	end  
		end
  end
end
