class TableReservationMetum < ActiveRecord::Base
  
  include ActiveModel::ForbiddenAttributesProtection

  attr_accessible :date, :table_id, :table_reservation_id, :timeslot,:status
  validates_presence_of :table_id,:table_reservation_id
  belongs_to :table_reservation
  belongs_to :table

  scope :get_disable_table_id, ->(table_reservation_id) { where('table_reservation_id =?',table_reservation_id)}

  scope :create_alloted_tables, ->(customer_id,table_id) {create(:table_reservation_id =>customer_id,:table_id=>table_id)}

  def self.save_meta_data(reservation_id,table_id)
    table_id.each do |t|
      table_meta = new(:table_reservation_id =>reservation_id,:table_id =>t)
      table_meta.save
    end
  end

end


