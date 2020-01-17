class UpiMerchant < ActiveRecord::Base
  attr_accessible :am, :cu, :mam, :mc, :pa, :pn, :ref_url, :tid, :tn, :tr

  validates :pa, presence: true
  validates :pn, presence: true
  validates :mc, presence: true

end
