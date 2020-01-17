class AddClearnceDateToFatCheques < ActiveRecord::Migration
  def change
    add_column :fat_cheques, :clearnce_date, :string
  end
end
