class Advertisement < ActiveRecord::Base

  # accessable attributes
  attr_accessible :name, :description, :valid_from, :valid_till, :position, :repeating,:menu_card_id
  
  # class validations
  validates :name, :presence => true

  # class relations
  belongs_to :menu_card
  has_many :unit_advertisements, :dependent => :destroy
  has_many :units, through: :unit_advertisements
  has_many :advertisement_galleries, :dependent => :destroy
end
