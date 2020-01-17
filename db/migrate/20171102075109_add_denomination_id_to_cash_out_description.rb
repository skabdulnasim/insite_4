class AddDenominationIdToCashOutDescription < ActiveRecord::Migration
  def change
    add_column :cash_out_descriptions, :denomination_id, :integer
  end
end
