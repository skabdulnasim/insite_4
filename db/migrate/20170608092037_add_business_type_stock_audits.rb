class AddBusinessTypeStockAudits < ActiveRecord::Migration
  def up
  	add_column :stock_audits, :business_type, :string
  end
end
