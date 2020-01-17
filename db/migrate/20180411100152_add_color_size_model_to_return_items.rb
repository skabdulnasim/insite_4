class AddColorSizeModelToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :size, :string
    add_column :return_items, :model_number, :string
  end
end
