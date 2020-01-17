class UnitAdvertisement < ActiveRecord::Base

  # accessable attributes
  attr_accessible :advertisement_id	, :unit_id

  # class validations
  validates :unit_id, :presence => true
  validates :advertisement_id, :presence => true

  # class relations
  belongs_to :unit
  belongs_to :advertisement
    
  def self.save_unit_advertisement(advertisement_id	, unit_ids)
    prev = self.where('advertisement_id =?', advertisement_id)
    prev.destroy_all if prev.present?
  	unit_ids.each do |unit_id|
  	  UnitAdvertisement.create(:advertisement_id	 => advertisement_id	, :unit_id => unit_id)
	  end
  end
end
