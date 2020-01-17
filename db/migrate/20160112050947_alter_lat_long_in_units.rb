class AlterLatLongInUnits < ActiveRecord::Migration
  def up
    execute 'ALTER TABLE units ALTER COLUMN latitude TYPE float USING (latitude::float)'
    execute 'ALTER TABLE units ALTER COLUMN longitude TYPE float USING (longitude::float)'
  end

  def down
  end
end
