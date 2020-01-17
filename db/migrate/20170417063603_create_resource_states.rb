class CreateResourceStates < ActiveRecord::Migration
  def change
    create_table :resource_states do |t|
      t.string :name
      t.text :color_code
      t.text :state_priority
      t.text :trash

      t.timestamps
    end
  end
end
