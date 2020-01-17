class AddIconToLabels < ActiveRecord::Migration
  def change
  	add_attachment :labels, :icon
  end
end
