class UnitNewsEvent < ActiveRecord::Base
  attr_accessible :news_event_id, :unit_id

  # class validations
  validates :unit_id, :presence => true
  validates :news_event_id, :presence => true

  # class relations
  belongs_to :unit
  belongs_to :news_event
    
  def self.save_unit_news(news_event_id, unit_ids)
    prev = self.where('news_event_id =?', news_event_id)
    prev.destroy_all if prev.present?
  	unit_ids.each do |unit_id|
  	  UnitNewsEvent.create(:news_event_id => news_event_id, :unit_id => unit_id)
	end
  end
end
