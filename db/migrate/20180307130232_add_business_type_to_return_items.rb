class AddBusinessTypeToReturnItems < ActiveRecord::Migration
  def change
    add_column :return_items, :business_type, :string
  end
end
