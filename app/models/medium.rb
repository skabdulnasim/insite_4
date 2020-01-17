class Medium < ActiveRecord::Base
  attr_accessible :asset_id, :asset_type, :deleted_at, :media_content_type, :media_file_name, :media_file_size, :media_updated_at, :properties
end
