class RenameTypeInCards < ActiveRecord::Migration
  def up
    rename_column :cards, :type, :card_type
  end

  def down
  end
end
