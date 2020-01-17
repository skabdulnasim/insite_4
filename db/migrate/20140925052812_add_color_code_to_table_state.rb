class AddColorCodeToTableState < ActiveRecord::Migration
  def change
    add_column :table_states, :color_code, :text
  end
end
