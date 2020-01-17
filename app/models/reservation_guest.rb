class ReservationGuest < ActiveRecord::Base
  attr_accessible :address, :email, :firstname, :lastname, :mobile_no, :reservation_guest_docs_attributes

  belongs_to :check_information
  has_many :reservation_guest_docs

  accepts_nested_attributes_for :reservation_guest_docs
end
