class AddServiceTypeToTableReservations < ActiveRecord::Migration
  def change
    add_column :table_reservations, :service_type, :string
  end
end
