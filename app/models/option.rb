class Option < ActiveRecord::Base
  
  attr_accessible :question_id, :title, :image

  has_attached_file :image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  # Model Relations
  belongs_to :question

end