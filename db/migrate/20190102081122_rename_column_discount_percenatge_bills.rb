class RenameColumnDiscountPercenatgeBills < ActiveRecord::Migration
  def up
  	rename_column :bills, :discount_percenatge, :bill_discount_percentage
  end
end
