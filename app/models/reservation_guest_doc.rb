class ReservationGuestDoc < ActiveRecord::Base
  attr_accessible :doc_type, :reservation_guest_id, :doc_type_id, :content_type, :file_name, :doc_file_data, :doc_file

  # Paperclip gem
  has_attached_file :doc_file, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :doc_file, :content_type => /\Aimage\/.*\Z/

  # Model Relations
  belongs_to :reservation_guest
  belongs_to :doc_type
  _doc_type = %w(picture voter_card aadher_card driving_licence pan_card passport visa)

  # Setter to set file name
  def file_name=(file_name)
    @file_name = file_name
  end  
  # # Setter to set content type
  def content_type=(content_type)
    @content_type = content_type
  end  

  # # Setter to set doc_file
  def doc_file_data=(doc_file_data)
    StringIO.open(Base64.decode64(doc_file_data)) do |data|
      data.class.class_eval { attr_accessor :original_filename, :content_type }
      data.original_filename = @file_name
      data.content_type = @content_type
      self.doc_file = data
    end
  end
end