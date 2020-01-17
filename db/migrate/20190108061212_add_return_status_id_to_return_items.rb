class AddReturnStatusIdToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :return_status_id, :integer
  end
end
