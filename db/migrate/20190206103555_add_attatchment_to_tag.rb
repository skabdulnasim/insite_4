class AddAttatchmentToTag < ActiveRecord::Migration
  def change
  	  	add_attachment :tags, :icon

  end
end
