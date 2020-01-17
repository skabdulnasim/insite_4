class AddChecksumToBillSplits < ActiveRecord::Migration
  def change
    add_column :bill_splits, :checksum, :string
  end
end
