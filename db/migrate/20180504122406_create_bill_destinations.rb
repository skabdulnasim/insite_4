class CreateBillDestinations < ActiveRecord::Migration
  def change
    create_table :bill_destinations do |t|
      t.text :name
      t.text :bill_header
      t.text :bill_footer

      t.timestamps
    end
  end
end
