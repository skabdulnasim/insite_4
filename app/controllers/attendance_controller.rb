class AttendanceController < ApplicationController
  def index
  	@attendance = Attendance.all
  end

  def new
  	@attendance = Attendance.new
 		respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @attendance }
    end
  end

  def create
  	@attendance = Attendance.new( params[:attendance] )
    respond_to do |format|
      if @attendance.save
        format.html { redirect_to attendances_path, notice: 'Attendance done successfully.' }
        format.json { render json: @attendance, status: :created, location: @attendance }
      else
        format.html { render action: "new" }
        format.json { render json: @attendance.errors, status: :unprocessable_entity }
      end
    end  	
  end
end
