class AddFromDateToDateToResourceTargets < ActiveRecord::Migration
  def change
    add_column :resource_targets, :from_date, :date
    add_column :resource_targets, :to_date, :date
  end
end
