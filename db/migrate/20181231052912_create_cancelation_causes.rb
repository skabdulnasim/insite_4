class CreateCancelationCauses < ActiveRecord::Migration
  def change
    create_table :cancelation_causes do |t|
      t.string :title
      t.references :cancelation_policy
      t.timestamps
    end
  end
end
