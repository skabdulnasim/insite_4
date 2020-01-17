class CreateReturnCauses < ActiveRecord::Migration
  def change
    create_table :return_causes do |t|
      t.string :title
      t.references :return_policy
      t.timestamps
    end
  end
end
