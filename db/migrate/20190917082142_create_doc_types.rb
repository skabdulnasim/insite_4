class CreateDocTypes < ActiveRecord::Migration
  def change
    create_table :doc_types do |t|
      t.string :title

      t.timestamps
    end
  end
end
