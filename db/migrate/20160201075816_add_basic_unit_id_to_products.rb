class AddBasicUnitIdToProducts < ActiveRecord::Migration
  def change
    add_column :products, :basic_unit_id, :integer
    # Product.where('basic_unit=?', 'Kg').update_all(basic_unit_id: 1)
    # Product.where('basic_unit=?', 'lt').update_all(basic_unit_id: 2)
    # Product.where('basic_unit=?', 'Pc').update_all(basic_unit_id: 3)
  end
end
