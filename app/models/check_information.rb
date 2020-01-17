class CheckInformation < ActiveRecord::Base
  attr_accessible :check_in_datetime, :check_out_datetime, :reservation_id, :status, :reservation_guests_attributes

  belongs_to :reservation
  has_many :reservation_guests
  _status = %w(pending checked_in checked_out)

  accepts_nested_attributes_for :reservation_guests
  #Model callback
  after_update :update_resources, if:->{self.status=="checked_out"}
  after_save :update_reservation_details

  def update_resources
    _reservation = self.reservation
    self.reservation.reservation_details.each do |reservation_detail|
  	 Resource.update_resource_state(1,_reservation.unit_id,reservation_detail.resource_id,_reservation.user_id,_reservation.device_id)
    end
  end

  def update_reservation_details
    self.reservation.update_column(:state, self.status)
    _reservation_details = self.reservation.reservation_details
    _reservation_details.each do |reservation_detail|
      reservation_detail.update_column(:state, self.status)
    end
  end

end