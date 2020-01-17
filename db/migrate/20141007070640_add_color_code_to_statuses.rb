class AddColorCodeToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :color_code, :text
  end
end
