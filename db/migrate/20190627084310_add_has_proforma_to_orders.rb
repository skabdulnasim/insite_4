class AddHasProformaToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :has_proforma, :integer
  end
end