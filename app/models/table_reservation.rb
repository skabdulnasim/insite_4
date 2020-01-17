class TableReservation < ActiveRecord::Base
  
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :contact_no, :customer_name, :from_time, :head_count, :remarks, :reservation_date,:unit_id, :status, :to_time, :timeslot,:section_id,:service_type
  has_many :table_reservation_meta, dependent: :destroy
  belongs_to :section
  
  validates_presence_of :contact_no,:customer_name,:reservation_date,:from_time,:to_time
  #validates_inclusion_of :head_count, in: 1..20
  validates_length_of :contact_no, :minimum => 8, :maximum => 10

  scope :get_date_by_date_unit_id, ->(date,unit_id) {where(:reservation_date =>date,:unit_id => unit_id)}
  scope :status_update, ->(reservation_id) {where(:id=>reservation_id).update_all(:status=>"2")}
  scope :update_reservation, ->(reservation_id,to_time,from_time) {where(:id=>reservation_id).update_all(:status=>"6",:to_time=>Time.zone.parse(from_time).to_time.strftime("%d:%M:%S"),:from_time=>Time.zone.parse(to_time).to_time.strftime("%d:%M:%S"))}

=begin
def self.update_reservation(reservation_id,to_time,from_time)
    where(:id=>reservation_id).update_all(:status=>"1",:to_time=>Time.zone.parse(from_time).to_time.strftime("%d:%M:%S"),:from_time=>Time.zone.parse(to_time).to_time.strftime("%d:%M:%S"))
  end
=end


  def self.get_on_date_reservation_from_time(id,date)
    tmp_from_time = where(:reservation_date =>date,:id => id).select('from_time')
    tmp_from_time.each do |e|
      return Time.zone.parse(e.from_time.to_s).to_time.strftime("%H").to_i
    end
  end

  def self.get_on_date_reservation_to_time(id,date)
    tmp_to_time = where(:reservation_date =>date,:id => id).select('to_time')
    tmp_to_time.each do |e|
      return Time.zone.parse(e.to_time.to_s).to_time.strftime("%H").to_i
    end
  end

  def self.create_reservation(name,date,service_type,from_time,to_time,unit_id,contact_no,status)
    new(:customer_name => name,:reservation_date => date,:from_time=>from_time,:to_time=>to_time,:unit_id=>unit_id,:contact_no=>contact_no,:status=>status,:service_type=>service_type)
  end
  
  def self.get_resturant_time_slot(unit_id)
    _unit_details = UnitDetail.set_unit(unit_id).first
    _unit_details = JSON.parse(_unit_details.options)
    resturant_time_slot = _unit_details["resturant_time_slot"].to_i
    return resturant_time_slot
  end

  def self.get_customers(unit_id)
    where(:unit_id => unit_id)
  end

  def self.get_open_time(unit_id)
    _unit_details = UnitDetail.set_unit(unit_id).first
    _unit_details = _unit_details.options
    open_from = _unit_details[:open_from]
    open_time = Time.zone.parse(open_from.to_s).to_time.strftime("%H").to_i
    return open_time
  end

  def self.get_closed_time(unit_id)
    _unit_details = UnitDetail.set_unit(unit_id).first
    _unit_details = _unit_details.options
    open_to = _unit_details[:open_to]
    closed_time = Time.zone.parse(open_to.to_s).to_time.strftime("%H").to_i
    return closed_time
  end
end