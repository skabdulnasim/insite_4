class AddPositionToNewsEvents < ActiveRecord::Migration
  def change
    add_column :news_events, :position, :string
    add_column :news_events, :repeating, :integer
  end
end
