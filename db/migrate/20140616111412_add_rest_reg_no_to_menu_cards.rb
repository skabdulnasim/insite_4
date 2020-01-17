class AddRestRegNoToMenuCards < ActiveRecord::Migration
  def change
    add_column :menu_cards, :rest_reg_no, :text
  end
end
