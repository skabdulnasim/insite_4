class AddRemarksToBills < ActiveRecord::Migration
  def change
    unless column_exists? :bills, :remarks
      add_column :bills, :remarks, :text
    end
    unless column_exists? :order_details, :remarks
      add_column :order_details, :remarks, :text
    end    
  end
end
