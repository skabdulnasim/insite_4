class ProductBasicUnitsController < ApplicationController
  def new
    @product_basic_unit = ProductBasicUnit.new
    respond_to do |format|
      format.js
    end
  end

  def create
    @product_basic_unit = ProductBasicUnit.new(params[:product_basic_unit])
    respond_to do |format|
      if @product_basic_unit.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @product_basic_unit = ProductBasicUnit.find(params[:id])
    respond_to do |format|
      if @product_basic_unit.update_attributes(params[:product_basic_unit])
        format.js
      else
        format.js
      end
    end
  end

  def edit
    @product_basic_unit = ProductBasicUnit.find(params[:id])
  end

  def destroy
    @product_basic_unit = ProductBasicUnit.find(params[:id])
    @product_basic_unit.destroy

    respond_to do |format|
      format.js
    end
  end
end
