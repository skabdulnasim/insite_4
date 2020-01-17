class RemoveBasicIdFromSimoOutputProduct < ActiveRecord::Migration
  def up
    remove_column :simo_output_products, :basic_id
  end

  def down
    add_column :simo_output_products, :basic_id, :integer
  end
end
