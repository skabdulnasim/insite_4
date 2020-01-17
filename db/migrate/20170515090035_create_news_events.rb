class CreateNewsEvents < ActiveRecord::Migration
  def change
    create_table :news_events do |t|
      t.string :name
      t.text :description
      t.date :valid_form
      t.date :valid_till

      t.timestamps
    end
  end
end
