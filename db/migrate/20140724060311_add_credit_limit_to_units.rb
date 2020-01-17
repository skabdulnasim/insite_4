class AddCreditLimitToUnits < ActiveRecord::Migration
  def change
    add_column :units, :credit_limit, :text
  end
end
