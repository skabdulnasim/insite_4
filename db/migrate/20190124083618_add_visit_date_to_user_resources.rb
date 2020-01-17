class AddVisitDateToUserResources < ActiveRecord::Migration
  def change
    add_column :user_resources, :visit_date, :date
  end
end
