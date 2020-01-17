class PaytmSecuritiesController < ApplicationController

  before_filter :authenticate

  def index
  	if current_user.users_role.role.name == "owner" 
	  	PaytmSecurity.first.present? ? @paytm_security = PaytmSecurity.order('id asc').first : @paytm_security = PaytmSecurity.new
		else
			redirect_to root_url, alert: 'You are not authorized user.' 
  	end
  end

  def show
  	@paytm_security = PaytmSecurity.find(params[:id])

  	respond_to do |format|
  		format.html
  		format.json { render json: @paytm_security }
  	end
  end

  def new
  	@paytm_security = PaytmSecurity.new
  end

  def edit
  	@paytm_security = PaytmSecurity.find(params[:id])
  end

  def create
  	@paytm_security = PaytmSecurity.new(params[:paytm_security])

  	respond_to do |format|
	  	if @paytm_security.save
	  		format.html { redirect_to paytm_securities_path, notice: 'Paytm Security was created.' }	
	  		format.json { render json: @paytm_security, status: :created, location: @paytm_security }
	  	else
	  		format.html { render action: "new" }
	  		format.json { render json: @paytm_security.errors, status: :unprocessable_entity}
			end
		end
  end

  def update
  	@paytm_security_key = PaytmSecurity.find(params[:id])

    session[:paytm_value] = @paytm_security_key

    session[:paytm_update_value] = params[:paytm_security]  
    @otp_obj = Otp.new()
    @otp_obj.phone_number = current_user.profile.contact_no
    @otp_obj.save
    @otp_obj.generate_pin
    @otp_obj.send_pin
    redirect_to check_otp_paytm_securities_path
  end

  def destroy
  	@paytm_security = PaytmSecurity.find(params[:id])
		@paytm_security.destroy

  	respond_to do |format|
  		format.html { redirect_to paytm_securities_url }
  		format.json { head :no_content }
  	end
  end

  def check_otp
    _phone_no = current_user.profile.contact_no
    @fetch_otp = Otp.find_by_phone_number(_phone_no)

    paytm_key = session[:paytm_value]

    paytm_update_key = session[:paytm_update_value]

    if params[:otp_value].present?
      if @fetch_otp.otp == params[:otp_value]
        paytm_key.update_attributes(paytm_update_key)
        redirect_to paytm_securities_path, notice: 'Paytm security key was successfully updated.'
        @fetch_otp.destroy
      else
        redirect_to check_otp_paytm_securities_path, alert: 'Otp was not correct.'
      end
    end
	end


  def regenerate_otp
    _phone_no = current_user.profile.contact_no
    @fetch_otp = Otp.find_by_phone_number(_phone_no)

    if @fetch_otp.present?
      @fetch_otp.destroy
      @otp_obj = Otp.new()
      @otp_obj.phone_number = current_user.profile.contact_no
      @otp_obj.save
      @otp_obj.generate_pin
      @otp_obj.send_pin
      redirect_to check_otp_paytm_securities_path, notice: 'New otp is generated.'
    else
      redirect_to check_otp_paytm_securities_path, alert: 'Click on update button and generate otp first.'
    end
  end


  private

  def paytm_security
  	params.require(:paytm_security).permit(:channel_id, :industry_type_id, :mid, :paytm_marchant_key, :paytm_url, :website)
  end

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == "foo" && password == "bar"
    end
  end

end



