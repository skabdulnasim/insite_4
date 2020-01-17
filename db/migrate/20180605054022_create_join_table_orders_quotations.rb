class CreateJoinTableOrdersQuotations < ActiveRecord::Migration
  def change
    create_table :orders_quotations, :id=>false do |t|
      t.references :order, :null => false
      t.references :quotation, :null => false
    end
  end
end
