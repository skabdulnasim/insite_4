class RenameFromDateToFromDateTime < ActiveRecord::Migration
  def up
  	rename_column :customer_queues, :from_date, :from_date_time
  end

  def down
  end
end
