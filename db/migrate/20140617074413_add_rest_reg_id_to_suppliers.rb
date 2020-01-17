class AddRestRegIdToSuppliers < ActiveRecord::Migration
  def change
    add_column :suppliers, :rest_reg_no, :text
  end
end
