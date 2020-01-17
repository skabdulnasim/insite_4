class StockTransferStepsController < ApplicationController
  include Wicked::Wizard

  steps :manage_products, :confirmation

  before_filter :set_module_details, :set_store, :set_stock_transfer, :set_reason_codes

  def show
    case step
    when :manage_products
    when :confirmation
      @tax_groups = TaxGroup.all
    end
    render_wizard
  end

  def update
    respond_to do |format|
      if @stock_transfer.update_attributes(params[:stock_transfer])
        if params[:update_transfer_products].present?
          format.html { redirect_to store_stock_transfer_steps_path(@store,@stock_transfer), notice: 'Stock transfer was successfully updated' }
          format.js
        else
          format.html { redirect_to next_wizard_path, notice: 'Stock transfer was successfully updated' }
          format.js
        end
      else
        format.html { redirect_to wizard_path }
        format.js
      end
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

  def set_stock_transfer
    @stock_transfer = StockTransfer.find(params[:stock_transfer_id])
  end

  def set_reason_codes
    @reason_codes = get_reason_codes('StockTransfer','creation')
  end
end