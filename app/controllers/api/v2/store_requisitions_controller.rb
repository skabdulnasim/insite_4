module Api
	module V2
		class StoreRequisitionsController < ApplicationController
			api :POST, '/api/v2/store_requisitions', "API to generate a requisitions."
			param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
			param :data, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "name":"1ST Requistion",
              "store_id":16,
              "to_store":"3",
              "unit_id":"4",
              "user_id":"5",
              "valid_from":"2019/06/12",
              "valid_till":"2019/06/27",
              "longitude":"89.9809",
              "latitude":"98.0976"
            }
            "products":[
              {
              "product_ammount":"100",
              "product_id": 632
              }
            ]  
        EOS
			def create
				ActiveRecord::Base.transaction do
					data = params[:data]
					products = params[:products]
					if !data['store_id'].nil? && !data['to_store'].nil? && !data['user_id'].nil?
						@store_requisition = StoreRequisition.new(data)
						@store_requisition[:recurring]=0
						@store_requisition[:requisition_code]="req"+(Time.now.to_i).to_s+"#{rand(1000)}"
						@store_requisition.save
						products.each do |product|
							@store_requisition_meta = @store_requisition.store_requisition_metum.build(product) if !product['product_id'].nil?
							@store_requisition_meta.save
						end
					end
				end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
			end

			api :POST, '/api/v2/store_requisitions/create_send', "API to generate a requisitions."
			param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
			param :data, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "name":"1ST Requistion",
              "store_id":16,
              "to_store":"3",
              "unit_id":"4",
              "user_id":"5",
              "valid_from":"2019/06/12",
              "valid_till":"2019/06/27",
              "longitude":"89.9809",
              "latitude":"98.0976"
            }
            "products":[
              {
              "product_ammount":"100",
              "product_id": 632
              }
            ]  
        EOS
      
			def create_send
				ActiveRecord::Base.transaction do
					data = params[:data]
					products = params[:products]
					if !data['store_id'].nil? && !data['to_store'].nil? && !data['user_id'].nil?
						@store_requisition = StoreRequisition.new(data)
						@store_requisition[:recurring]=0
						@store_requisition[:requisition_code]="req"+(Time.now.to_i).to_s+"#{rand(1000)}"
						@store_requisition.save
						products.each do |product|
							@store_requisition_meta = @store_requisition.store_requisition_metum.build(product) if !product['product_id'].nil?
							@store_requisition_meta.save
						end
						@req_log = StoreRequisitionLog.new
    				@req_log[:store_requisition_id] = @store_requisition.id
    				@req_log.save
    				_metums = StoreRequisitionMetum.set_requistion(@req_log.store_requisition_id)
		        _metums.each do |meta|  
		          @log_items = LogItem.new
		          @log_items[:log_id]               = @req_log.id
		          @log_items[:from_store_id]        = @req_log.from_store_id
		          @log_items[:store_id]             = @req_log.store_id
		          @log_items[:store_requisition_id] = @req_log.store_requisition_id
		          @log_items[:product_id]           = meta.product_id
		          @log_items[:product_ammount]      = meta.product_ammount
		          @log_items[:status]               = '1'
		          @log_items.save
		        end  
					end
				end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
			end

			## => API Documentation (APIPIE) for 'received_requisition' action
      api :GET, '/api/v2/store_requisitions/received_requisition/', "Get List of all received requisition of a store."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
			param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :store_id, String, :required => true, :desc => "Get all received requisition of corresponding store"      
      param :unit_id, String, :required => false, :desc => "Get requistion of this unit"
      param :from_store_id, String, :required => false, :desc => "Get only this store requistion"
      param :status, Array, :desc => "status: (1,2) for new and approved"
      formats ['json']
			def received_requisition
				@store = Store.find(params[:store_id])
				@store_requisition_logs = @store.store_requisition_logs
				@store_requisition_logs = @store_requisition_logs.set_status_in(params[:status]) if params[:status].present?
				@store_requisition_logs = @store_requisition_logs.by_unit(params[:unit_id]) if params[:unit_id].present?
				@store_requisition_logs = @store_requisition_logs.by_from_store_id(params[:from_store_id]) if params[:from_store_id].present?
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present?	
			end

			## => API Documentation (APIPIE) for 'send_requisition_log' action
      api :GET, '/api/v2/store_requisitions/send_requisition_log/', "Get List of all send requisition of a store."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
			param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :store_id, String, :required => true, :desc => "Get all requisition of corresponding store" 
      param :requisitions_date, String, :required => false, :desc => "fiter by date"     
      formats ['json']
			def send_requisition_log
				@store = Store.find(params[:store_id])
				@sent_requisitions = @store.sent_requisitions.desc_order
				@sent_requisitions = @sent_requisitions.by_created_at(params[:requisitions_date]) if params[:requisitions_date].present?
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present?
			end

			## => API Documentation (APIPIE) for 'received_requisition' action
      api :PUT, '/api/v2/store_requisitions/update_requisition_state/', "Update a requisition state."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
			param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :log_id, String, :required => true, :desc => "Update requistion state for corresponding log_id"      
      param :status, String, :required => true, :desc => "Update to status"      
      
      formats ['json']
			def update_requisition_state
				ActiveRecord::Base.transaction do
					@requistion_log = StoreRequisitionLog.find(params[:log_id])
					if @requistion_log.update_attribute(:status, params[:status])
						LogItem.where(:log_id =>params[:log_id]).update_all(:status => params[:status])
					end		
				end
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present?	
			end
			api :GET, '/api/v2/store_requisitions/summary_requisition/', "Requistion summery of a store."
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
			param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :requisitions_date, String, :required => false, :desc => "Requistion of this date"      
      param :store_id, String, :required => true, :desc => "requistion of this store"
      param :resources, String, :desc => "This parameter defines, how many extra resources, associated with bill will be given in response. Check allowed_resources and a sample resources parameter in metadata.", :required => false, :meta => {:allowed_resources => ["requisition_meta_details"], :example => "resources=requisition_meta_details"} 
			def summary_requisition
				@store = Store.find(params[:store_id])
				@rq_date = params[:requisitions_date].present? ? params[:requisitions_date] : Date.today
				@requestions = StoreRequisitionLog.select("COUNT(store_requisition_id) AS count, store_requisition_id").group(:store_requisition_id).store_requistion(params[:store_id]).na_requisitions.by_created_at(@rq_date)
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present?	
			end
	
			def get_summary_details
				@requisition_meta_details = LogItem.set_product_in(params[:product_id]).na_requisitions.store_requistion(params[:store_id]).by_created_at(params[:rq_date]) 
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present?	
			end

			def get_requistion_deta
				@store_id = params[:store_id]
				@log_details = StoreRequisitionLog.find(params[:log_id])
				rescue Exception => @error
				@log = Rscratch::Exception.log(@error,request) if @error.present?
			end
			
		end
	end
end