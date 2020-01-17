class FeedbackOptionsController < ApplicationController
  # GET /feedback_options
  # GET /feedback_options.json
  def index
    @feedback_options = FeedbackOption.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @feedback_options }
    end
  end

  # GET /feedback_options/1
  # GET /feedback_options/1.json
  def show
    @feedback_option = FeedbackOption.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @feedback_option }
    end
  end

  # GET /feedback_options/new
  # GET /feedback_options/new.json
  def new
    @feedback_option = FeedbackOption.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @feedback_option }
    end
  end

  # GET /feedback_options/1/edit
  def edit
    @feedback_option = FeedbackOption.find(params[:id])
  end

  # POST /feedback_options
  # POST /feedback_options.json
  def create
    @feedback_option = FeedbackOption.new(feedback_option_params)

    respond_to do |format|
      if @feedback_option.save
        format.html { redirect_to @feedback_option, notice: 'Feedback option was successfully created.' }
        format.json { render json: @feedback_option, status: :created, location: @feedback_option }
      else
        format.html { render action: "new" }
        format.json { render json: @feedback_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /feedback_options/1
  # PATCH/PUT /feedback_options/1.json
  def update
    @feedback_option = FeedbackOption.find(params[:id])

    respond_to do |format|
      if @feedback_option.update_attributes(feedback_option_params)
        format.html { redirect_to @feedback_option, notice: 'Feedback option was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @feedback_option.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /feedback_options/1
  # DELETE /feedback_options/1.json
  def destroy
    @feedback_option = FeedbackOption.find(params[:id])
    @feedback_option.destroy

    respond_to do |format|
      format.html { redirect_to feedback_options_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def feedback_option_params
      params.require(:feedback_option).permit(:option_title)
    end
end
