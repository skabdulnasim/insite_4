class NewsEvent < ActiveRecord::Base
  attr_accessible :description, :name, :valid_from, :valid_till, :position, :repeating
  
  validates :name, :presence => true

  # class relations
  has_many :unit_news_events
  has_many :units, through: :unit_news_events
  has_many :news_event_galleries, :dependent => :destroy				
end
