class ChangeColumnNameToNewsEvent < ActiveRecord::Migration
  def up
  	rename_column :news_events, :valid_form, :valid_from
  end

  def down
  end
end
