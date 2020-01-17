module Api
	module V2
		class CheckInformationsController < ApplicationController
			#before_filter :authenticate_user_with_token!,only: [:index,:create]

			### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/check_informations', "List of all reservations check informations. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"
      # param :unit_id, String, :required => false, :desc => "Filter reservations of an unit"
      # param :reservation_date, String, :required => false, :desc => "This parameter can be used to get results this date."
      # param :slot_ids, String, :required => false, :desc => "Filter response by slots."   
      # param :reservation_id, String, :required => false, :desc => "Filter response by reservation."    
      # param :resource_id, String, :required => false, :desc => "Filter response by resource."      
      # param :trash, String, :required => false, :desc => "The value of trash param is 0 or 1."
      # param :Customer_id, String, :required => false, :desc => "Id of the customer"
			def index
				ActiveRecord::Base.transaction do
	        _per = params[:count] || 20
	        @check_infos = CheckInformation.order("id desc")
	        # @check_infos = @check_infos.by_unit(params[:unit_id]) if params[:unit_id].present?
	        # @check_infos = @check_infos.by_customer(params[:Customer_id]) if params[:Customer_id].present?
	        # @check_infos = @check_infos.by_resource(params[:resource_id]) if params[:resource_id].present?
	        # @check_infos = @check_infos.set_slot_in(params[:slot_ids]) if params[:slot_ids].present?
	        # @check_infos = @check_infos.by_date(params[:reservation_date]) if params[:reservation_date].present?
	        # @check_infos = @check_infos.by_id(params[:id_filter]) if params[:id_filter].present?
	        # @check_infos = @check_infos.not_trash(params[:trash]) if params[:trash].present?
	        @count = @check_infos.count
	        @check_infos = @check_infos.page(params[:page]).per(_per) if params[:page].present?
      	end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception  
      end

      ### => API Documentation (APIPIE) for 'update' action
      api :PUT, '/api/v2/check_informations/1', "API to update a check_information. (Authorization header required for authentication)"
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :check_information, Hash, :required => true, :desc => <<-EOS

      ==== A sample parameter value is given below
				{
					"check_in_datetime":"2019-09-10",
					"status":"checked_in",
					"reservation_guests_attributes":[{
						"address":"Kolkata",
						"email":"abdul@yottolabs.com",
						"firstname":"Abdul",
						"lastname":"Nasim",
						"mobile_no":"9475635421",
						"reservation_guest_docs_attributes":[{
							"doc_type_id": "1",
							"content_type":"image\/jpeg",
							"file_name":"test.jpeg",
							"doc_file_data":"\/9j\/4AAQSkZJRgABAQAAAQABAAD\/2wBDAAEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEB\nAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH\/2wBDAQEBAQEBAQEBAQEBAQEBAQEBAQEB\nAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQEBAQH\/wAARCADAAMADASIA\nAhEBAxEB\/8QAHwAAAQUBAQEBAQEAAAAAAAAAAAECAwQFBgcICQoL\/8QAtRAAAgEDAwIEAwUFBAQA\nAAF9AQIDAAQRBRIhMUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3\nODk6Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZmqKjpKWm\np6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx8vP09fb3+Pn6\/8QAHwEA\nAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL\/8QAtREAAgECBAQDBAcFBAQAAQJ3AAECAxEEBSEx\nBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAVYnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElK\nU1RVVldYWVpjZGVmZ2hpanN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3\nuLm6wsPExcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6\/9oADAMBAAIRAxEAPwD\/AD\/6\n+of2Sv2NP2jv24vixpHwa\/Zt+HWr+PPF2pyR+cLO2uTpejWbSpFJqmuX8Ntciw0+3Lq007RuVUk7\nDhjR+xp+yV8Wf24v2jfh1+zb8GtIk1Txf471e2sxN5crWejaWbm3hvtc1SSOOU2+n2Kzxmedl2oX\nQEkkmv8AX9\/4Jkf8EyP2fP8AgmJ+z7oXwl+Eug2N34vu7GwuPiX8TLiwt4vEXjfxDFb7Z7i4nVWl\ng06GR5msrEzzGAzTk3EgfgA\/nR\/4J\/f8GfP7PvgDRNF8Z\/t5ePdV+KvjaRLe7uvhx4Ilj0XwbpEx\n2vJp99q9wmrN4jjVgY3f+ztPyA3yZJFf0kfBj\/glF\/wTi\/Z+trKD4Vfsi\/CPw\/Pp5ia21UeGrWXW\nPMixsmlvkjg8ybKhi\/lLlsnHNfoRRQBBa2tvY20NnZwx29tbxpDBBEu2OKJAQkca5+VVBwB2HfJJ\nqeiigAooooAKKKKACiiigAooooAKKKKACiiigAqC5tbe9tp7O7hjuLa5jaG4glXdHNE4IeORc\/Mr\nA4I9MckjNT0qqzEKoLEkAADnqQO\/t\/LJOckA\/Pf4yf8ABKH\/AIJx\/tBW99b\/ABT\/AGRPhH4iuNRL\nm41X\/hGrWLWfNlMm6aG9eOcxzEszB\/KbDAHB5z\/OR+3\/AP8ABnN8BPH2g6541\/YP8ear8K\/G6JNe\nWnw38bSx634P1ebbO6afZatbppLeGomZVjWT+z9RIVl\/dHZ839sVhYCBfMlAMhAwOy8np19Ovfns\nMnU\/z\/P3\/wA5PJ5yAf4Vf7W\/7GP7R\/7DfxZ1j4NftJ\/DnV\/Afi3S5JPI+2W1z\/ZWtWSzSxR6pod\/\nNbWwv7C48otDOI0LKCSgHJ+W6\/2xv+CoP\/BL39nr\/gp\/+z14i+E\/xY8P2Np4xtbG\/ufhr8Srawt5\nfEXgvxFJbssN1azMqyzWM8kdub6xE8P2gQwf6RGUO7\/Hd\/bN\/ZH+LX7DX7R\/xH\/Zs+M+kSaX4v8A\nAWr3Fn53lyrZa1pQurqCw13S5JI4zcafqC27tBMF2sUYAnaxIB\/eV\/wZ8f8ABP8A0XwD+z94+\/by\n8Z6Iknjb4p6rL4H+G91eWy+fpHg7Ro1uNYvrCWRN4i8SNqemFmjZV\/0CP5nODX9qVfnt\/wAEoPgz\nbfs\/f8E4P2RfhVDYf2dceHvhH4aGrW5i8uU6zNbKl9NOm1T50n2eHeWG7oCSRuP6E0AFFFFABRRR\nQAUUUUAFFFFABRRRQAUUUUAFFFFABRRT40eVgiAsxIAAHuR7+n6jqQaAERGdgqAliQAAOTyR6+36\njqTXSWFisC75ADIR19OTwOOmQfrxwQGJfY2KWyFmw0rdWxwBluAD09Tz3GeQM3\/8\/wA\/f\/OTyecg\nB\/n+fv8A5yeTzkoooAK\/iO\/4PGP+CfGiePPgB4E\/b28F6HFH41+FurQ+CfiNdWduv2nWvB2tRy3G\nl32oSxx7zB4XbStQMbSsyj+05MMmDu\/txr86f+CtfwXtf2gv+Cbf7Xfwqm07+07rxH8I\/EsWkW4j\n8yVNYW2lSyngXY586MySbCo3DccHINAH2va2ttY20NnZwR21tbxrFBBCgSKKJd21I0HCquTgDpk9\ny2Z6KKACiiigAooooA5rxn4kg8G+D\/E3i26hkuLfw5o19q80EQ\/ezR2cMshjjGD8zFFHQ4B7k1\/D\nX8Xf+Cz37dvjn4geJNc8IfFO6+HnhqXUrpND8LeH0uILfTtPjuJ1ginkF8ouLgJtEk3lRbjj92ME\nV\/cv4r1TwtpPh7VLnxnqOl6Z4dNpNFqtzrFxFb2AtHSRZhO8rBfLKBiw54xwSCT\/ACafHH9gb\/gl\nLr3xQ8Q6j4R\/b08JfDe01bUZ7pvCIay1yy0q5nnmaSCzvU1nShHboxwkItvkwRuYsSP6O+j1i+Bc\nFiuJJ8ZcLYvPJ1KWCWW4yHDWM4iwmDhCVZ4uhPD4XCYt4etXcqNSNaVJ3pxlT9pBN8\/4h4yYbizE\n0Mmjwzn+HyuFOpiXjcLLO8Nk2IxEpOmsPWjWr4nDqtSpJVIype0VpzjLllZtfnP\/AMPbf+CiH\/Rx\nnin\/AL\/3P\/ydR\/w9t\/4KIf8ARxnin\/v\/AHP\/AMnV+rvw8\/4IOfs8fFvSv7a+GX7aNn420zCn7Z4f\n8NW19GobJXfs8VlgSOen1ycEeh\/8Q4Pgn\/o5PWf\/AAhl\/wDmor+gq3iP9GfDVZ0MTk+TYevSly1K\nNfgHE0a1OSsuWpTqZPGcHpqpK+++8vx2jwT454inGth8wzOvSkk4VaPF1CpTmrxScZwzKUZLTdSa\n211bPxf\/AOHtv\/BRD\/o4zxT\/AN\/7n\/5Oo\/4e2\/8ABRD\/AKOM8U\/9\/wC5\/wDk6v2g\/wCIcHwT\/wBH\nJ6z\/AOEMv\/zUVkaz\/wAG4GifYJ\/7A\/aWvRqG0+QL\/wABhrZn+fAcjxWCoJC7m5wp6Z65w8Tfovzl\nGLy\/h6CbS558D11CN9LyayiTS93V201vfVu3wL48Ri39azh8qvZcVUnJ2tsnmKu\/dWl77LdyPx2\/\n4e2\/8FEP+jjPFP8A3\/uf\/k6j\/h7b\/wAFEP8Ao4zxT\/3\/ALn\/AOTq6L9rf\/gkt+1f+yVp2oeLtT0S\n2+Ifw6sNz3HjPwhHcXA0+FfMbzdZ04QuNOQou\/d9sm\/jHGwk\/mDng9cjOR0OQSCCOoPHTnr9C"
						}]
					}]
				}

        EOS

        formats ['json']
      error :code => "'status' : 'error'", :desc => "-- If status is error in response, then something went wrong with the request. To get error details, check 'messages' in response"
      description <<-EOS
        EOS
      example '
      Success Response (PUT Request: http://silvershine.lvh.me:3000/api/v2/check_informations/1?device_id=YOTTO05&email=mantri@silvershines.com)

        {
			    "status": "ok",
			    "messages": {
			        "simple_message": "Check information successfully update",
			        "internal_message": "Check information successfully update"
			    },
			    "data": {
			        "id": 4,
			        "check_in_datetime": "2019-09-10T00:00:00+05:30",
			        "check_out_datetime": null,
			        "status": "checked_in",
			        "reservation": {
			            "id": 18,
			            "reservation_date": null,
			            "customer_id": 1,
			            "resource_id": 7,
			            "created_at": "2019-09-11T16:34:03+05:30",
			            "pax": 3,
			            "trash": 0,
			            "confirm_reservation_cancel": 0,
			            "customer_queue_id": 1,
			            "user_id": 16,
			            "device_id": "YOTTO05",
			            "status": "Allocated",
			            "source": "Direct",
			            "start_time": "02-04-2016, 11:30 AM",
			            "end_time": "02-04-2016, 12:30 PM",
			            "customer": {
			                "id": 1,
			                "email": "asif1@gmail.com",
			                "mobile_no": "008759932239",
			                "customer_unique_id": null,
			                "name": "Virat Sharma",
			                "custmer_profile": {
			                    "id": 1,
			                    "firstname": "Virat",
			                    "lastname": "Sharma",
			                    "address": "Kolkata",
			                    "age": "25",
			                    "anniversary": "8",
			                    "contact_no": "8759932239",
			                    "dob": "18.02.1991",
			                    "gender": "M"
			                },
			                "addresses": [
			                    {
			                        "id": 2,
			                        "landmark": "Sector-V",
			                        "city": "Kolkata",
			                        "state": "West Bengal",
			                        "pincode": "700102",
			                        "contact_no": "1001001001",
			                        "latitude": "41.4141172",
			                        "longitude": "-73.3035651"
			                    }
			                ]
			            },
			            "unit": {
			                "id": 7,
			                "unit_name": "Silver Shines Mktd. by SSJ Ventures                        TIN No: 29661287227",
			                "address": " 2nd floor mantri square, malleshwaram , bangalore",
			                "landmark": "SSJ VENTURE, S36,",
			                "locality": "Hennur Bande,HBR Layout",
			                "pincode": "560043",
			                "city": "Bengaluru",
			                "state": "Karnataka",
			                "country": "India",
			                "time_zone": "Kolkata",
			                "latitude": 12.9916302,
			                "longitude": 77.5711719,
			                "phone": "9900406398",
			                "section": {
			                    "id": 20,
			                    "name": "aaaa",
			                    "section_type": "dinein",
			                    "dinein_menu_card": {
			                        "id": 30,
			                        "name": "Reservation_menu",
			                        "master_menu_id": null,
			                        "scope": "inhouse",
			                        "updated_at": "2019-09-11T15:28:02+05:30"
			                    }
			                }
			            },
			            "resource": {
			                "id": 7,
			                "name": "Guest Room No2",
			                "resource_type": "doctor",
			                "resource_properties": {
			                    "age": "18"
			                },
			                "resource_image": "/system/resources/resource_images/000/000/007/original/room-inside.jpg?1567501687",
			                "capacity": 10,
			                "price": 2750,
			                "currency": "Rs"
			            }
			        },
			        "reservation_guests": [
			            {
			                "id": 1,
			                "address": "Kolkata",
			                "email": "abdul@yottolabs.com",
			                "firstname": "Abdul",
			                "lastname": "Nasim",
			                "mobile_no": "9475635421",
			                "reservation_guest_docs": [
			                    {
			                        "id": 1,
			                        "doc_type": "image"
			                    }
			                ]
			            },
			            {
			                "id": 2,
			                "address": "Kolkata",
			                "email": "abdul@yottolabs.com",
			                "firstname": "Abdul",
			                "lastname": "Nasim",
			                "mobile_no": "9475635421",
			                "reservation_guest_docs": [
			                    {
			                        "id": 2,
			                        "doc_type": "image"
			                    }
			                ]
			            },
			            {
			                "id": 3,
			                "address": "Kolkata",
			                "email": "abdul@yottolabs.com",
			                "firstname": "Abdul",
			                "lastname": "Nasim",
			                "mobile_no": "9475635421",
			                "reservation_guest_docs": [
			                    {
			                        "id": 3,
			                        "doc_type": "image"
			                    }
			                ]
			            },
			            {
			                "id": 4,
			                "address": "Kolkata",
			                "email": "abdul@yottolabs.com",
			                "firstname": "Abdul",
			                "lastname": "Nasim",
			                "mobile_no": "9475635421",
			                "reservation_guest_docs": [
			                    {
			                        "id": 4,
			                        "doc_type": "image"
			                    }
			                ]
			            },
			            {
			                "id": 5,
			                "address": "Kolkata",
			                "email": "abdul@yottolabs.com",
			                "firstname": "Abdul",
			                "lastname": "Nasim",
			                "mobile_no": "9475635421",
			                "reservation_guest_docs": [
			                    {
			                        "id": 5,
			                        "doc_type": "image"
			                    }
			                ]
			            }
			        ]
			    }
			}
      '
			def update
				ActiveRecord::Base.transaction do
          @check_info = CheckInformation.find(params[:id]) 
          @check_info.update_attributes(params[:check_information]) if params[:check_information].present?
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? 
			end

			def show
				ActiveRecord::Base.transaction do
					@check_info = CheckInformation.find(params[:id])
				end
				rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
			end
		end
	end
end