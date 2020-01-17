class CreateCustomerTags < ActiveRecord::Migration
  def change
    create_table :customer_tags do |t|
      t.integer :customer_id
      t.integer :tag_id

      t.timestamps
    end
  end
end
