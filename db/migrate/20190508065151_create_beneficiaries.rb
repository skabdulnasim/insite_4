class CreateBeneficiaries < ActiveRecord::Migration
  def change
    create_table :beneficiaries do |t|
    	t.integer :resource_id
      t.string :name
      t.string :bank_name
      t.integer :account_number
      t.string :branch
      t.string :ifsc
      t.string :payment_mode
      t.string :pan_no
     	t.boolean :status
      t.timestamps
    end
  end
end
