class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :mobile_no
      t.string :gstin
      t.string :business_type

      t.timestamps
    end
  end
end
