class ThirdpartyConfiguration < ActiveRecord::Base
	belongs_to :section

  attr_accessible :section_id, :api_key, :api_url, :api_username, :is_product_desc, :is_product_image, :status, :thirdparty

  validates_uniqueness_of :section_id, :scope => :thirdparty, :message => "Already exist"

  THIRDPARTY = %w(urban_piper zoamto)
end
