class AddSuffixPrefixToBills < ActiveRecord::Migration
  def change
    add_column :bills, :suffix, :string
    add_column :bills, :prefix, :string
  end
end
