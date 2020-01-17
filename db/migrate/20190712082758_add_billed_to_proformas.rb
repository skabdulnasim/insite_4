class AddBilledToProformas < ActiveRecord::Migration
  def change
    add_column :proformas, :billed, :integer
  end
end
