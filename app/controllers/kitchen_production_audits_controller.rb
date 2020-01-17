class KitchenProductionAuditsController < ApplicationController
	load_and_authorize_resource
  layout "material"

	before_filter :set_module_details
	before_filter :set_store, only: [:new,:update_audit, :show,:approve_audit]

  def new
  	@products = @store.kitchen_production_audits.not_audited
  end

  def show
    @pro_audits = @store.kitchen_production_audits.set_audit_id(params[:audit_id])
  end

  def update_audit
    begin
      raise 'No products selected for this audit.' unless !params[:checked_products].nil?
      _audit_id = Time.now.to_i + rand(100)
      ActiveRecord::Base.transaction do
	      params[:checked_products].each do |object|
	      	_audit = KitchenProductionAudit.find(object)
	      	_audit.update_attribute(:procured_qty,params["quantity_#{object}"])
	      	_audit.update_attribute(:remarks,params["remarks_#{object}"])
	      	_audit.update_attribute(:status,'2')
	      	_audit.update_attribute(:audit_id,_audit_id)
	      end
    	end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to store_path(@store), notice: "Error occured! "+e.message.to_s
      return false
    else
      redirect_to store_path(@store), notice: "Production audit process was successfully initiated."
    end
  end

  def approve_audit
    begin
      _product_audits = @store.kitchen_production_audits.set_audit_id(params[:audit_id])
      _product_audits.each do |aps|
        aps.update_attribute(:status,params[:status])
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to store_path(@store), notice: "Error occured! "+e.message.to_s
      return false
    else
      redirect_to store_path(@store), notice: "Production audit status was successfully updated."
    end
  end

  private

	def set_module_details
    @module_id = "inventory"
    @module_title = "Inventory"
  end

	def set_store
      @store = Store.find(params[:store_id])
  end
end
