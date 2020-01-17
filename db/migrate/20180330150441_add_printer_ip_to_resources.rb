class AddPrinterIpToResources < ActiveRecord::Migration
  def change
    add_column :resources, :printer_id, :integer
  end
end
