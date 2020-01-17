class Audit < ActiveRecord::Base
  attr_accessible :audit_status, :audit_stock, :audit_stock_id, :remark
end
