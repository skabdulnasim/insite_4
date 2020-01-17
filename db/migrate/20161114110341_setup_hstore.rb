class SetupHstore < ActiveRecord::Migration
  def self.up
    execute "CREATE EXTENSION IF NOT EXISTS hstore WITH SCHEMA pg_catalog"
  end

  def self.down
    execute "DROP EXTENSION IF EXISTS hstore"
  end
end
