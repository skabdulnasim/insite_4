class ChangeColumnPreauthToIsPreauth < ActiveRecord::Migration
  def up
  	rename_column :customer_queues, :preauth, :is_preauth
  end
end
