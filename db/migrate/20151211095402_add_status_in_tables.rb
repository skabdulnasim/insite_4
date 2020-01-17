class AddStatusInTables < ActiveRecord::Migration
  def up
    add_column :tables, :status, :string, default: "enabled"
  end

  def down
  end
end
