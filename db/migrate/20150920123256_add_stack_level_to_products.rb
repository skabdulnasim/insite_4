class AddStackLevelToProducts < ActiveRecord::Migration
  def change
    add_column :products, :stack_level, :integer
  end
end
