class CreateUpiMerchants < ActiveRecord::Migration
  def change
    create_table :upi_merchants do |t|
      t.string :pa
      t.string :pn
      t.string :mc
      t.string :tid
      t.string :tr
      t.string :tn
      t.float :am
      t.string :cu
      t.string :ref_url
      t.float :mam

      t.timestamps
    end
  end
end
