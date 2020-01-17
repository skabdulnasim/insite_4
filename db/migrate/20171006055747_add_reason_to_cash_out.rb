class AddReasonToCashOut < ActiveRecord::Migration
  def change
    add_column :cash_outs, :reason, :string
  end
end
