class AddReasonToCashIn < ActiveRecord::Migration
  def change
    add_column :cash_ins, :reason, :string
  end
end
