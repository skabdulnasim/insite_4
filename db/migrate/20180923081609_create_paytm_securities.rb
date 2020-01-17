class CreatePaytmSecurities < ActiveRecord::Migration
  def change
    create_table :paytm_securities do |t|
      t.string :paytm_marchant_key
      t.string :website
      t.string :mid
      t.string :industry_type_id
      t.string :channel_id
      t.string :paytm_url

      t.timestamps
    end
  end
end
