class ChangeTagGroupIdInUnitProducts < ActiveRecord::Migration
  def up
    if column_exists? :unit_products, :tax_group_id
      rename_column :unit_products, :tax_group_id, :input_tax_group_id
    end    
  end

  def down
  end
end
