class RequisitionScheduler
  #require 'requisition_management'
  #include RequisitionManagement
  include Sidekiq::Worker
  def perform(data)
    RequisitionManagement::save_requisition_store_stocks(data['id'])
  end
end
