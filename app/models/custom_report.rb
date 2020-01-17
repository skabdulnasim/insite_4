class CustomReport < ActiveRecord::Base
  belongs_to :report_folder
  attr_accessible :name, :query
end
