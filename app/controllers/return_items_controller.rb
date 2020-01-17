class ReturnItemsController < ApplicationController
  load_and_authorize_resource :except => [:show_stores, :add_return_item_to_stock]
  layout "material"

  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper

  before_filter :set_module_details

  def index
    @return_items = ReturnItem.where("store_id = ?", params[:store_id])
    smart_listing_create :return_items, @return_items, partial: "return_items/item_smartlist",default_sort: {created_at: "desc"}
    respond_to do |format|
      format.html # show.html.erb
      format.js
    end
  end

  def create
    begin
      ActiveRecord::Base.transaction do
        return_item = ReturnItem.add_return_items(params[:bill_id],params[:order_detail_id],params[:price],params[:product_id],params[:quantity],params[:remarks],params[:unit_id],params[:store_id],params[:deliverable_id],params[:deliverable_type],params[:return_price],"","",params[:stock_status])
        puts return_item.errors.full_messages
        respond_to do |format|
          format.json { render json: return_item, notice: "Item Returned Successfully" }
        end
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render json: e.message.to_s, alert: "Item Not Returned" }
      end
    end
  end

  def add_item_to_stock
    begin
      ActiveRecord::Base.transaction do
        _unit = ProductUnit.where("basic_inventory_unit = ?", params[:product_unit])
        _stock = Stock.save_stock(params[:product_id],params[:store_id],params[:price],params[:available_stock],params[:stock_transaction_id],params[:stock_transaction_type],params[:stock_credit],params[:stock_debit],params[:expiry_date],params[:sku],nil)
        _stock_defination = StockDefination.save_stock_defination(_stock.id,params[:weight],_unit[0].id,params[:making_cost],params[:sell_price],params[:wastage],params[:sku],"")
        if params[:change_status].present?
          return_item = ReturnItem.find(params[:stock_transaction_id])
          return_item.update_attributes(:added_to_stock => true)
        end
        respond_to do |format|
          format.json { render json: _stock, notice: "Item added to Stock Successfully." }
        end
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render json: e.message.to_s, alert: "Not added to stock" }
      end
    end
  end

  # Api for Return Item Add to stock (combination of create and add_item_to_stock)
  def add_return_item_to_stock
    begin
      ActiveRecord::Base.transaction do
        return_items = ActiveSupport::JSON.decode(params[:return_items_attributes])
        return_items['item_details'].each do |item|
          order_deatil = OrderDetail.find(item['order_detail_id'])
          return_item = ReturnItem.add_return_items(return_items['bill_id'],item['order_detail_id'],item['price_without_tax'],item['product_id'],item['quantity'],return_items['remarks'],return_items['unit_id'],return_items['return_store_id'],return_items['deliverable_id'],return_items['deliverable_type'],item['return_price'],return_items['is_refandable'],return_items['cashback_mode'],return_items['stock_status'],return_items['device_id'],return_items['user_id'],return_items['refund_mode'],return_items['refund_status'])  
          # if item['add_to_stock'] == "true"
          #   _unit = ProductBasicUnit.where("short_name = ?", item['product_unit'])
          #   _stock = Stock.save_stock(item['product_id'],item['store_id'],item['price_without_tax'],item['quantity'],return_item.id,"return_item",item['quantity'],0,nil,item['sku'],nil)
          #   _stock_defination = StockDefination.save_stock_defination(_stock.id,item[:weight],_unit[0].id,item[:making_cost],item[:sell_price],item[:wastage],item[:sku],return_items['remarks'])
          #   return_item = ReturnItem.find(return_item.id)
          #   return_item.update_attributes(:added_to_stock => true)
          # end
          #return_item = ReturnItem.find(return_item.id)
          #return_item.update_attributes(:added_to_stock => true)
          if return_items['is_refandable'] == 'yes'
            ReturnItem.refund_money return_item, return_items['account_no'], return_items['ifsc_code']
          end
        end
        respond_to do |format|
          format.json { render json: { :message => "Item returned Successfully.", status: :ok }}
        end
      end
    rescue Exception => e
      respond_to do |format|
        format.json { render json: e.message.to_s, alert: "Not added to stock" }
      end      
    end
  end

  def show_stores
    # stores = Store.includes(unit: :unittype).where("store_type = ?", "return_store")
    _unit_id = params[:unit_id].present? ? params[:unit_id] : @current_user.unit_id
    stores = Store.includes(unit: :unittype).where("store_type = ? and unit_id = ?", "return_store", _unit_id)
    stores_array = []
    stores.each do |store|
      stores_hash = {}
      stores_hash[:address]         = store.address
      stores_hash[:contact_number]  = store.contact_number
      stores_hash[:id]              = store.id
      stores_hash[:name]            = store.name
      stores_hash[:pincode]         = store.pincode
      stores_hash[:store_image]     = store.store_image
      stores_hash[:store_priority]  = store.store_priority
      stores_hash[:store_type]      = store.store_type
      stores_hash[:unit_id]         = store.unit_id
      stores_hash[:unit_name]       = store.unit.unit_name
      stores_hash[:unit_type]       = store.unit.unittype.unit_type_name
      stores_array.push stores_hash
    end

    respond_to do |format|
      format.json { render json: stores_array }
    end
  end

  private
    def set_module_details
      @module_id = "inventory"
      @module_title = "Inventory"
    end
end
