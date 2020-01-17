class AddStartDateToSlots < ActiveRecord::Migration
  def change
    add_column :slots, :start_date, :datetime
    add_column :slots, :end_date, :datetime
  end
end
