class AddDenominationIdToCashInDescription < ActiveRecord::Migration
  def change
    add_column :cash_in_descriptions, :denomination_id, :integer
  end
end
