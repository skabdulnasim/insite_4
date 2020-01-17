class AddProformaIdToBills < ActiveRecord::Migration
  def change
    add_column :bills, :proforma_id, :integer
  end
end
