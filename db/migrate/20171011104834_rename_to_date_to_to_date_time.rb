class RenameToDateToToDateTime < ActiveRecord::Migration
  def up
  	rename_column :customer_queues, :to_date, :to_date_time
  end

  def down
  end
end
