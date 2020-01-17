class AddAvailabilityTypeToResourceType < ActiveRecord::Migration
  def change
    add_column :resource_types, :availability_type, :string
  end
end
