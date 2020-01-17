class BeneficiariesController < ApplicationController
	layout "material"
	def index
  end

  def new
  	@beneficiaries = Beneficiary.new
  	@resource = Resource.find(params[:resource_id])
  end
  def edit
  	@beneficiaries = Beneficiary.find(params[:id])
  	@resource_id = @beneficiaries.resource_id
  end

  def create
  	@beneficiaries = Beneficiary.new(params[:beneficiary])
		@beneficiaries.resource_id = params[:resource_id]
		@res = Resource.find(params[:resource_id])
		respond_to do |format|
			if @beneficiaries.save
				format.html {redirect_to resource_path(@res), notice: 'Beneficiaries successfully created.'}
			else
				format.html {render action: "new"}
			end
		end
		@beneficiaries.save
  end

  def update
		@beneficiaries = Beneficiary.find(params[:id])
		respond_to do |format|
			if @beneficiaries.update_attributes(params[:beneficiary])
				format.html {redirect_to resource_path(@beneficiaries.resource_id), notice: 'Beneficiaries was successfully updated.'}
			else
				format.html {render :edit}
			end 
		end
  end

  def destroy
  	@beneficiaries = Beneficiary.find(params[:id])
  	_resource_id = @beneficiaries.resource_id
  	@beneficiaries.destroy

  	respond_to do |format|
  		format.html {redirect_to resource_path(_resource_id), notice: 'Beneficiaries was successfully deleted.'}
  	end
  end

  private
  def set_params
  	params.require(:beneficiaries).permit(:account_number, :bank_name, :branch, :beneficiary_type, :payment_mode, :ifsc, :name, :pan_no, :beneficiary_percentage)
  end
end
