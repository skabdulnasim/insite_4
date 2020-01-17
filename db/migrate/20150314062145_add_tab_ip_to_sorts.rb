class AddTabIpToSorts < ActiveRecord::Migration
  def change
    add_column :sorts, :tab_ip, :text
  end
end
