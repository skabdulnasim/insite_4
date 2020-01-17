class PurchaseOrderStepsController < ApplicationController
	include Wicked::Wizard
	
	steps :po_confirmation

	before_filter :set_store, :set_smart_po

	def show
    render_wizard
  end

  private

  def set_store
    @store = Store.find(params[:store_id])
  end

  def set_smart_po
    @smart_po = SmartPo.find(params[:smart_po_id])
  end
end