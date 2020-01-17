class AddIsTrashedToTables < ActiveRecord::Migration
  def change
    add_column :tables, :is_trashed, :boolean, default: false    
    add_column :sections, :is_trashed, :boolean, default: false    
    add_column :sorts, :is_trashed, :boolean, default: false    
    unless column_exists? :units, :is_trashed
      add_column :units, :is_trashed, :boolean, default: false    
    end
    add_column :unittypes, :is_trashed, :boolean, default: false    
    add_column :stores, :is_trashed, :boolean, default: false    
    add_column :vehicles, :is_trashed, :boolean, default: false    
    add_column :users, :is_trashed, :boolean, default: false    
    add_column :app_configurations, :is_trashed, :boolean, default: false    
    add_column :tax_classes, :is_trashed, :boolean, default: false    
  end
end
