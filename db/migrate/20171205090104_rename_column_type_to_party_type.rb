class RenameColumnTypeToPartyType < ActiveRecord::Migration
  def up
  	rename_column :parties, :type, :party_type
  end
end
