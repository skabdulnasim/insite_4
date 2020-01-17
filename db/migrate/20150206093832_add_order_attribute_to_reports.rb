class AddOrderAttributeToReports < ActiveRecord::Migration
  def change
    add_column :reports, :order_attribute, :string
  end
end
