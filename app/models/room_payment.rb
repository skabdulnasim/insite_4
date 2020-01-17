class RoomPayment < ActiveRecord::Base
  attr_accessible :amount, :room_name, :room_id

  # => Model relations
  has_one :payment, as: :paymentmode
  belongs_to :room

  # => Model validations
  validates :room_id, presence: true
  validates :amount, presence: true
  before_validation :set_extra_attributes

  private

  def set_extra_attributes
    _room = Room.find(self.room_id)
    self.room_name = _room.name
  end  
end
