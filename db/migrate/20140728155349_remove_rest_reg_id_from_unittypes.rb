class RemoveRestRegIdFromUnittypes < ActiveRecord::Migration
  def up
    remove_column :unittypes, :rest_reg_no
  end
end
