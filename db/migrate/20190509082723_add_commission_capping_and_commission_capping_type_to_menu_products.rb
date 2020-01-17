class AddCommissionCappingAndCommissionCappingTypeToMenuProducts < ActiveRecord::Migration
  def change
    add_column :menu_products, :commission_capping, :float
    add_column :menu_products, :commission_capping_type, :string
  end
end
