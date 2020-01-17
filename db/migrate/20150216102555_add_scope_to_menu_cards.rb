class AddScopeToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :scope, :string, :default => "inhouse"
  end
end
