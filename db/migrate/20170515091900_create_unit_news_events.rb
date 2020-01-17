class CreateUnitNewsEvents < ActiveRecord::Migration
  def change
    create_table :unit_news_events do |t|
      t.integer :unit_id
      t.integer :news_event_id

      t.timestamps
    end
  end
end
