class CreateThirdpartyConfigurations < ActiveRecord::Migration
  def change
    create_table :thirdparty_configurations do |t|
      t.string :api_url
      t.string :api_username
      t.string :api_key
      t.string :thirdparty
      t.string :is_product_image
      t.string :is_product_desc
      t.string :status

      t.timestamps
    end
  end
end
