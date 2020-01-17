class TableSwapLog < ActiveRecord::Base
  attr_accessible :device_id, :new_table_id, :old_table_id, :order_id, :user_id, :old_table_state_before_update, :new_table_state_before_update
end
