class StockTransferTemplatesController < ApplicationController
  layout "material"

  before_filter :set_store, only: [:index, :details]
  before_filter :set_template, only: [:destroy, :details]
  before_filter :get_current_user, only: [:index]
  def index
    @templates = @store.stock_transfer_templates.set_type(params[:template_type])
  end

  def details
  end

  def destroy
    @template.destroy
    respond_to do |format|
      format.html { redirect_to stores_path, notice: 'Stock tansfer template was successfully deleted.' }
    end
  end

  private 

  def set_store
    @store = Store.find(params[:store_id])
  end  

  def set_template
    @template = StockTransferTemplate.find(params[:id])
  end 
end
