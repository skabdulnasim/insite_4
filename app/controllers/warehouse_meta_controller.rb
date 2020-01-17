class WarehouseMetaController < ApplicationController
	
	def index
	end
	
	def new
	end
	
	def create
		store = Store.find(params[:store_id])
		_row_index = WarehouseMetum.select(:row_unique_id).last
		if _row_index.present?
			_row_index =  _row_index.row_unique_id.to_i + 1
		else
			_row_index = 1
		end
		(1..params[:row].to_i).each do
			warehouse_row = store.warehouse_meta.create(:row_unique_id=>_row_index.to_s.rjust(3,"0"))
			_rack_index = 1
			(1..params[:rack].to_i).each do
				_bin_index = 1
				warehouse_rack = warehouse_row.warehouse_racks.create
				warehouse_rack.update_attributes(:rack_unique_id=>warehouse_row.row_unique_id+_rack_index.to_s.rjust(3,"0"),:row_unique_id=>warehouse_row.row_unique_id)
				_rack_index += 1
				(1..params[:shelf].to_i).each do 
					bin = warehouse_rack.bins.create
					bin.update_attributes(:bin_unique_id=>warehouse_rack.rack_unique_id+_bin_index.to_s.rjust(3,"0"),:rack_unique_id=>warehouse_rack.rack_unique_id, :status=>"available")
					_bin_index += 1
				end
			end	
			_row_index += 1
		end
		redirect_to :back, notice: "Wearehouse data added successfully"
	end
	
	def show
	end
	def destroy
		_warehouse_meta = WarehouseMetum.find(params[:id])
		if _warehouse_meta.destroy
			redirect_to :back
		end
	end

	def racks
		bins = Bin.where("warehouse_rack_id=?",params[:id]).select([:id,:bin_unique_id,:status]).order("id ASC")
		respond_to do |format|
			format.json {render json:{data:bins}}
		end
	end

end
