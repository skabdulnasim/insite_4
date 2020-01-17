class UnitAtmosphere < ActiveRecord::Base
  attr_accessible :atmosphere_id, :unit_id

  belongs_to :unit
  belongs_to :atmosphere

  def self.save_unit_atmosphere(current_unit, atmospheres)
  	prev = self.where('unit_id =?', current_unit)
    prev.destroy_all if prev.present?
    if atmospheres.present?
	  	atmospheres.each do |atmosphere|
	  	  UnitAtmosphere.create(:atmosphere_id => atmosphere, :unit_id => current_unit)
	  	end  
		end
  end
end
