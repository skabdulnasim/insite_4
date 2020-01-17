class CreateReasonCodes < ActiveRecord::Migration
  def change
    create_table :reason_codes do |t|
      t.integer :master_model_id
      t.string :name
      t.text :code
      t.boolean :status

      t.timestamps
    end
  end
end
