class ChangeDelivarableStringToText < ActiveRecord::Migration
  def change
  	change_column :bill_by_bill_sales, :deliverable, :text
  end
end
