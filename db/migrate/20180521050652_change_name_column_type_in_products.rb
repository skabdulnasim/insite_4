class ChangeNameColumnTypeInProducts < ActiveRecord::Migration
  def change
  	change_column :products, :name, :text
  end
end
