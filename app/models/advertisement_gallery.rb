class AdvertisementGallery < ActiveRecord::Base

  # accessable attributes
  attr_accessible :advertisement_id, :advertisement_image

  # class validations
  validates :advertisement_id, :presence => true
  validates :advertisement_image, :presence => true

  # class relations
  belongs_to :advertisement

  has_attached_file :advertisement_image, 
    :path => ":rails_root/public/system/images/:id/:style/:filename",
    :url => "/system/images/:id/:style/:filename", 
    :styles => { :large => "500x300>", :medium => "250x450>", :thumb => "60x60>" }, 
    :default_url => "/images/:style/product.png"
  validates_attachment_content_type :advertisement_image, :content_type => /\Aimage\/.*\Z/


  def self.save_multiple_images(advertisement_id, params_avatars)
    params_avatars.each do |params_avatar|
      AdvertisementGallery.create(:advertisement_image => params_avatar, :advertisement_id => advertisement_id)
    end
  end

  def self.delete_single_images(advertisement_gallery_id)
    advertisement_gallery = AdvertisementGallery.find(advertisement_gallery_id).destroy
  end

  def advertisement_image_url
    advertisement_image.url(:large)
  end
end
