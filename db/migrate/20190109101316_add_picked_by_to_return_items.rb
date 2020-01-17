class AddPickedByToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :picked_by, :integer
  end
end
