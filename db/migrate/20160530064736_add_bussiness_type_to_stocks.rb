class AddBussinessTypeToStocks < ActiveRecord::Migration
  def change
    add_column :stocks, :bussiness_type, :string
  end
end
