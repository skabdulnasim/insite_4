class PrintersController < ApplicationController

  # GET /printers/1/edit
  def edit
    @printer = Printer.find(params[:id])
  end

  # POST /printers
  # POST /printers.json
  def create
    respond_to do |format|
      if Printer.save_printer(params[:printer],params[:assignable_id])
        format.html { redirect_to printers_app_configurations_path, notice: 'Printer settings was successfully created.' }
        format.json { render json: @printer, status: :created, location: @printer }
      else
        format.html { redirect_to printers_app_configurations_path, notice: 'The ip is not properly formated ex (192.168.0.175).' }
        format.json { render json: @printer.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /printers/1
  # PUT /printers/1.json
  def update
    respond_to do |format|
      if Printer.save_printer(params[:printer],params[:assignable_id],params[:id])
        format.html { redirect_to printers_app_configurations_path, notice: 'Printer settings was successfully Updated.' }
        format.json { render json: @printer, status: :created, location: @printer }
      else
        format.html { redirect_to printers_app_configurations_path, notice: 'The ip is not properly formated ex (192.168.0.175).' }
        format.json { render json: @printer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /printers/1
  # DELETE /printers/1.json
  def destroy
    @printer = Printer.find(params[:id])
    @printer.destroy

    respond_to do |format|
      format.html { redirect_to printers_app_configurations_path, notice: 'The printer settings has been deleted.' }
      format.json { head :no_content }
    end
  end

  def model_data_list
    @assignable_id = "NULL"
    if(params[:printer_id] && params[:printer_id]!="NULL") 
      @printer = Printer.find(params[:printer_id])
      @assignable_id = @printer.assignable_id
    end
    
    if(params[:model_name]) 
      _model_name = params[:model_name].classify.constantize
      @model_datas = Printer.current_unit_printers(_model_name, current_user.unit_id)
    else
      @model_datas = []
    end
    puts @model_datas
    respond_to do |format|
      format.json { render json: @model_datas }
    end    
    # render layout: false
  end

  #>>>>>>>>>>>>>>>>> APIPie START >>>>>>>>>>>>>>>>>#
  api :POST, '/exchange_ip.json', "Interchange Ip of two printers."
  error :code => 401, :desc => "Unauthorized"
  param :from_printer_id, :number, :desc => "Copy ip from printer id", :required => true
  param :to_printer_id, :number, :desc => "Copy ip to printer id", :required => true
  description "URL: http://sumit.lvh.me:3000/printers/exchange_ip.json?device_id=YOTTO05&from_printer_id=1&to_printer_id=2" 
  formats ['json', 'html']
  #<<<<<<<<<<<<<<<<< API-PIE END <<<<<<<<<<<<<<<<<<#
  def exchange_ip
    _exchange = Printer.exchange_printer_ip(params[:from_printer_id], params[:to_printer_id]) 

    respond_to do |format|
      if _exchange == 0
        format.json { render json: {:error => "Printers could not be exchanged."} }
      else
        format.json { render json: _exchange }
      end
    end
  end
end
