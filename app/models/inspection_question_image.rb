class InspectionQuestionImage < ActiveRecord::Base
  attr_accessible :content_type,:file_name,:data_image, :image, :inspection_question_id
  # Paperclip gem
  has_attached_file :image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/

  # Model association
  belongs_to	:inspection_question

  # Setter to set file name
  def file_name=(file_name)
    @file_name = file_name
  end  
  # # Setter to set content type
  def content_type=(content_type)
    @content_type = content_type
  end  

  # # Setter to set image
  def data_image=(data_image)
    StringIO.open(Base64.decode64(data_image)) do |data|
      data.class.class_eval { attr_accessor :original_filename, :content_type }
      data.original_filename = @file_name
      data.content_type = @content_type
      self.image = data
    end
  end
end
