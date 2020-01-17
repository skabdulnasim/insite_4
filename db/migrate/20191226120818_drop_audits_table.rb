class DropAuditsTable < ActiveRecord::Migration
  def up
  	drop_table :audits
  end
end
