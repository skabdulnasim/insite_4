class CreateDealMakerDeals < ActiveRecord::Migration
  def change
    create_table :deal_maker_deals do |t|
      t.string :name
      t.string :description
      t.string :status
      t.timestamp :start_time
      t.timestamp :end_time

      t.timestamps
    end
  end
end
