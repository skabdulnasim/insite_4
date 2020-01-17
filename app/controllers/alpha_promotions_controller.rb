class AlphaPromotionsController < ApplicationController
  # GET /alpha_promotions
  # GET /alpha_promotions.json
  layout "material"
  def index
    @alpha_promotions   = AlphaPromotion.all
    @unit_promotions    = AlphaPromotion.active
    @unit_promotions    = Unit.find(params[:unit_id]).alpha_promotions.active if params[:unit_id].present?
    @unit_promotions    = @unit_promotions.by_code(params[:promo_code]) if params[:promo_code].present?
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @unit_promotions }
    end
  end

  # GET /alpha_promotions/1
  # GET /alpha_promotions/1.json
  def show
    @alpha_promotion = AlphaPromotion.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @alpha_promotion }
    end
  end

  # GET /alpha_promotions/new
  # GET /alpha_promotions/new.json
  def new
    @units = Unit.all
    @alpha_promotion = AlphaPromotion.new
    puts @alpha_promotion.inspect
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @alpha_promotion }
    end
  end

  # GET /alpha_promotions/1/edit
  def edit
    @alpha_promotion = AlphaPromotion.find(params[:id])
    #@rule = @alpha_promotion.build_rule
  end

  # POST /alpha_promotions
  # POST /alpha_promotions.json
  def create
    params[:alpha_promotion][:unit_ids] = params[:alpha_promotion][:unit_ids].present? ? params[:alpha_promotion][:unit_ids] : current_user.unit_id
    @alpha_promotion = AlphaPromotion.new(params[:alpha_promotion])

    respond_to do |format|
      if @alpha_promotion.save
        format.html { redirect_to alpha_promotions_path, notice: 'Alpha promotion was successfully created.' }
        format.json { render json: @alpha_promotion, status: :created, location: @alpha_promotion }
      else
        format.html { render action: "new" }
        format.json { render json: @alpha_promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /alpha_promotions/1
  # PATCH/PUT /alpha_promotions/1.json
  def update
    params[:alpha_promotion][:unit_ids] ||= []
    @alpha_promotion = AlphaPromotion.find(params[:id])

    respond_to do |format|
      if @alpha_promotion.update_attributes(params[:alpha_promotion])
        format.html { redirect_to alpha_promotions_path, notice: 'Alpha promotion was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @alpha_promotion.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /alpha_promotions/1
  # DELETE /alpha_promotions/1.json
  def destroy
    @alpha_promotion = AlphaPromotion.find(params[:id])
    @alpha_promotion.destroy

    respond_to do |format|
      format.html { redirect_to alpha_promotions_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def alpha_promotion_params
      params.require(:alpha_promotion).permit(:description, :promo_code, :promo_type, :promo_value, :status, :valid_from, :valid_till, :scope, :unit_ids, :promo_user, :count)
    end
end
