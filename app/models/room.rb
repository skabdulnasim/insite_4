class Room < ActiveRecord::Base
  attr_accessible :is_trashed, :name, :unit_id
  belongs_to :unit

  scope :unit_rooms, lambda {|unit_id| where(["unit_id = ?", unit_id])}
  scope :non_trashed, lambda { where(["is_trashed = ?",false]) }


end
