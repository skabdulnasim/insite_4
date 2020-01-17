class TableReservationsController < ApplicationController
  
  before_filter :get_current_user, only: [:create,:index,:new,:table_meta_create,:reservation_list,:capacity_checking,:time_checking,:edit]
 

  # GET /table_reservations
  # GET /table_reservations.json
  def index
    table_reservations = TableReservation.where(:unit_id => @current_user.unit_id)
    @reservations_by_date = table_reservations.group_by { |i| i.reservation_date.to_date }
    @date = params[:date] ? DateTime.parse(params[:date]).to_date : Date.today
    @unit_name = Unit.find(@current_user.unit_id)
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @table_reservations }
    end
  end


  # GET /table_reservations/new
  # GET /table_reservations/new.json
  def new
    @table_reservation = TableReservation.new
    @unit_name = Unit.find(@current_user.unit_id)
    @sections = Section.where(:unit_id => @current_user.unit_id])
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @table_reservation }
    end
  end

  # GET /table_reservations/1/edi

  # POST /table_reservations
  # POST /table_reservations.json
  def create
    if params[:table_id].present?
      begin
        table_id = JSON.parse(params[:table_id])
        table_reservation = TableReservation.new(reservation_params)
        table_reservation.save
        table_id.each do |t|
          table_meta = TableReservationMetum.new(:table_reservation_id =>table_reservation.id,:table_id =>t)
          table_meta.save
        end 
      rescue ActiveRecord::StatementInvalid => e
        puts e
      end
    else
      begin
        @table_reservation = TableReservation.new(reservation_params)
        @table_reservation.save
      rescue ActiveRecord::StatementInvalid => e
        puts e
      end
    end
    respond_to do |format|
      format.html { redirect_to table_reservations_path }
      format.json { render json: @table_reservation, status: :created, location: @table_reservation }
    end
  end
  
  def edit
    @table_reservation = TableReservation.find(params[:id])
    @sections = Section.where(:unit_id => @current_user.unit_id)
    @unit_name = Unit.find(@current_user.unit_id)
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @table_reservation }
    end
  end

  def update
    @table_reservation = TableReservation.find(params[:id])
    respond_to do |format|
      if @table_reservation.update_attributes(update_status)
        format.html { redirect_to table_reservations_path, notice: 'Table was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @table_reservation.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @table_reservation = TableReservation.find(params[:id])
    @table_reservation.destroy
    #@table = Table.where(:id => params[:table_id]).update_all(:reservation_status => "2")
    respond_to do |format|
      format.json { head :no_content }
    end
  end

  def get_tables_list
    @array = Table.where(:section_id =>params[:section_id])#TableReservation.table_customer_list(params[:section_id])
    respond_to do |format|
      format.html #
      format.json { render json: @array.to_json(:include => [:table_reservation_meta=>{:include=>:table_reservation}])}#to_json(:include => :table_reservation_meta)} #to_json(:include => :table_reservation_meta)
    end
  end

  def meta_data_create_cust_view
    begin
      @table_meta = TableReservationMetum.save_meta_data(params[:reservation_id],JSON.parse(params[:table_id]))
      @table_reservation_status = TableReservation.status_update(params[:reservation_id])
    rescue Exception => e
      puts e
    end 
    respond_to do |format|
      format.html #
      format.json { render json: @table_meta}
    end
  end

  def meta_data_create_table_view
    begin
      @table_meta = TableReservationMetum.save_meta_data(params[:table_reservation_id],JSON.parse(params[:table_id]))
      @update_reservation_status = TableReservation.update_reservation(params[:table_reservation_id],params[:to_time],params[:from_time])
    rescue Exception => e
      puts e
    end
    respond_to do |format|
      format.html #
      format.json { render json: @table_meta}
    end
  end

  def reservation_list 
    @reservation_on_current_daytime = TableReservation.where(:unit_id => @current_user.unit_id,:reservation_date =>Date.today,:from_time=>Time.now.to_formatted_s(:time),:status=>nil).count
    @table_reservation = TableReservation.new
    @table_reservations = TableReservation.get_date_by_date_unit_id(params[:date],@current_user.unit_id)
    @date = params[:date] ? DateTime.parse(params[:date]).to_date : Date.today
    @unit_name = Unit.find(@current_user.unit_id)
    @sections = Section.unit_sections(@current_user.unit_id)
    @open_time = TableReservation.get_open_time(@current_user.unit_id)
    @closed_time = TableReservation.get_closed_time(@current_user.unit_id)
    respond_to do |format|
      format.html #
      format.json { render json: @reservation_list}
    end
  end


  #>>>>>>>>>>>>>>>>> API-PIE START >>>>>>>>>>>>>>>>>#
    api :POST, 'table_reservations/table_reservation_create', "Customer details of table reservation create"
    param :name, String, :desc => "Customer Name", :required => true
    param :date, String, :desc => "Reservation Date", :required => true
    param :service_type, String, :desc => "Service Type", :required => true
    param :from_time, String, :desc => "Time From Customer Want Booking", :required => true
    param :to_time, String, :desc => "Time To Customer Untill Booked", :required => true
    param :phone_no, String, :desc => "Phone Number Of Customer", :required => true
    param :unit_id, String, :desc => "Unit ID", :required => true
    #param :section, String, :desc => "Section ID", :required => true
    param :status, String, :desc => "Section ID", :required => true
    description "URL : http://dev.selfordering.com/table_reservations/table_reservation_create/?device_id=YOTTO05"
    formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#

  def table_reservation_create    
    @table_reservation = TableReservation.create_reservation(params[:name],params[:date],params[:service_type],params[:from_time],params[:to_time],params[:unit_id],params[:phone_no],params[:status])
    if @table_reservation.save
      @massage = { :status => "ok", :message => "Customer successfully Created!" }
      respond_to do |format|
        format.json { render json: @massage}
      end
    else
      @massage_error = { :status => "null", :message => "Customer Not Created!" }
      respond_to do |format|
        format.json { render json: @massage_error}
      end
    end
  end

  #>>>>>>>>>>>>>>>>> API-PIE START >>>>>>>>>>>>>>>>>#
    api :GET, 'table_reservations/customer_details.json', "Customer details of table reservation"
    error :code => 404, :desc => "Record not Found"
    param :unit_id, String, :desc => "Unit ID", :required => true
    #param :section_id, String, :desc => "Section ID", :required => true
    description ""
    formats ['json']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#

  def customer_details
    @customers = TableReservation.get_customers(params[:unit_id])
    respond_to do |format|
      format.html
      format.json { render json: @customers.to_json(:include => :table_reservation_meta)}
    end
  end

  #>>>>>>>>>>>>>>>>> API-PIE START >>>>>>>>>>>>>>>>>#
    
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#

  def allot_table
    table_ids = JSON.parse(params[:table_customer_pair])
    table_ids.each do |table_id|
      @table = TableReservationMetum.create(:table_reservation_id=>table_id['customer_id'],:table_id=>table_id['table_id'])
      @table_up = TableReservation.where(:id=>table_id['customer_id']).update_all(:status=>"2")
      @table.save
    end
    @massage = { :status => "ok", :message => "Successfully Alloted!" }
    respond_to do |format|
      format.html
      format.json { render json: @massage}
    end
  end

  private

    def reservation_params
      params.require(:table_reservation).permit(:from_time,:to_time,:customer_name,:head_count,:reservation_date,:unit_id,:section_id,:contact_no,:status)
    end

  private
    def update_status
      params.require(:table_reservation).permit(:status)
    end

end