class Zone < ActiveRecord::Base
  attr_accessible :descriptions, :name, :status
  belongs_to :area
  belongs_to :user
  has_many :bits
  scope :not_allocated_in_area, lambda{where(["area_id IS NULL"])}
  scope :find_by_zone_id, lambda{|id|where(["id=?", id])}
  scope :by_unit_id, lambda {|unit_id|where(["unit_id=?", unit_id])}
  scope :by_unit_list, lambda{|unit_arr|where(["unit_id IN(?)",unit_arr])}
  def self.save_area_to_zone(area_id,zone_ids)
  	zone_ids.each do |zone_id|
  		self.find(zone_id).update_attribute(:area_id,area_id)
  	end
  end

  def self.update_zone_for_area(old_zones,new_zones,area_id)
  	old_zones.each do |old_zone|
  		self.find(old_zone).update_attribute(:area_id,nil)
  	end
  	new_zones.each do |new_zone|
  		self.find(new_zone).update_attribute(:area_id,area_id)
  	end
  end
  def self.zone_name_like(searcing_text)
    if searcing_text.present?
      where("lower(name) LIKE ?", "%#{searcing_text.downcase}%")
    else
      all
    end
  end
end
