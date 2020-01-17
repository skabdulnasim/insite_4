class DefaultAppConfigurations < ActiveRecord::Migration
  def up
    #### Default configurations
    AppConfiguration.delete_all
    AppConfiguration.create(config_key: "req_auto_adjust", config_value: "1")
    AppConfiguration.create(config_key: "purchase_order_auto_adjust", config_value: "1")
  end

  def down
  end
end
