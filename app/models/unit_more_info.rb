class UnitMoreInfo < ActiveRecord::Base
  attr_accessible :more_info_id, :unit_id

  belongs_to :unit
  belongs_to :more_info

  def self.save_unit_more_info(current_unit, more_infos)
  	prev = self.where('unit_id =?', current_unit)
    prev.destroy_all if prev.present?
    if more_infos.present?
	  	more_infos.each do |more_info|
	  	  UnitMoreInfo.create(:more_info_id => more_info, :unit_id => current_unit)
	  	end  
		end
  end
end
