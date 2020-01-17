class CustomerProductWishlist < ActiveRecord::Base
  attr_accessible :customer_id, :menu_card_id, :menu_product_id, :product_id, :mode

  #model relation 
  belongs_to :menu_product
  belongs_to :product
  belongs_to :cusomer
  
  validates_uniqueness_of :product_id, :scope => :customer_id, :message => "already exist"

  def initialize(attributes=nil, *args)
    super
    if new_record?
      # set default values for new records only
      initialized = (attributes || {}).stringify_keys
      if !initialized.key?('menu_card_id')
        self.menu_card_id = self.menu_product.menu_card_id
      end
      if !initialized.key?('product_id')
        self.product_id = self.menu_product.product_id
      end
      if !initialized.key?('mode')
        self.mode = 0
      end
    end
  end
  #model Scope
  scope :by_customer, lambda {|customer_id|where(["customer_id=?", customer_id])}
end
