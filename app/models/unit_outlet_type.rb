class UnitOutletType < ActiveRecord::Base
  attr_accessible :outlet_type_id, :unit_id

  belongs_to :unit
  belongs_to :outlet_type

  def self.save_unit_outlet(current_unit, outlet_types)
  	prev = self.where('unit_id =?', current_unit)
    prev.destroy_all if prev.present?
    if outlet_types.present?
	  	outlet_types.each do |outlet_type|
	  	  UnitOutletType.create(:outlet_type_id => outlet_type, :unit_id => current_unit)
	  	end  
		end
  end
end
