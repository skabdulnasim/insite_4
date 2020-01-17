class ThirdpartyCallback < ActiveRecord::Base
  attr_accessible :callback_type, :data

  after_create :after_callback_placed

  scope :filter_by_callback_type,              lambda {|callback_type|where(["callback_type=?", callback_type])}

  private
  def after_callback_placed
    self.data = self.data.tr('”','"')
    self.data = self.data.tr('“','"')
  end
end
