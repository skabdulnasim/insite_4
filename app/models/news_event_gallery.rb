class NewsEventGallery < ActiveRecord::Base
  attr_accessible :news_event_id, :news_event_image

  # class validations
  validates :news_event_id, :presence => true
  validates :news_event_image, :presence => true

  # class relations
  belongs_to :news_event

  has_attached_file :news_event_image, 
    :path => ":rails_root/public/system/images/:id/:style/:filename",
    :url => "/system/images/:id/:style/:filename", 
    :styles => { :large => "500x300>", :medium => "250x450>", :thumb => "60x60>" }, 
    :default_url => "/images/:style/product.png"
  validates_attachment_content_type :news_event_image, :content_type => /\Aimage\/.*\Z/


  def self.save_multiple_images(news_event_id, params_avatars)
    params_avatars.each do |params_avatar|
      NewsEventGallery.create(:news_event_image => params_avatar, :news_event_id => news_event_id)
    end
  end

  def self.delete_single_images(news_event_gallery_id)
    advertisement_gallery = NewsEventGallery.find(advertisement_gallery_id).destroy
  end

  def news_event_image_url
    news_event_image.url(:large)
  end
end
