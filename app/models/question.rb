class Question < ActiveRecord::Base
  attr_accessible :title, :question_type, :image, :options_attributes, :option_type, :status
  has_attached_file :image, :styles => { :medium => "250x250>", :thumb => "60x60>" }, :default_url => "/images/:style/missing.png"
  validates_attachment_content_type :image, :content_type => /\Aimage\/.*\Z/
  # Model Relations
  has_many :options
  has_many :units, through: :question_units
  has_many :question_units
  OPTION_TYPE = %w( CheckBox RadioButton Input Spinner)
  QUESTION_TYPE = %w( Inspection Feedback )
  accepts_nested_attributes_for :options, allow_destroy: true

  #Model Scope
  scope :active_mode, lambda { where(["status=?",'enable'])}
  scope :by_question_type, lambda{|question_type| where(["question_type=?",question_type])}

end