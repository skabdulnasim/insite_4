class MoreInfo < ActiveRecord::Base
  attr_accessible :name
  has_many :unit_more_infos, dependent: :destroy
  has_many :units, through: :unit_more_infos
end
