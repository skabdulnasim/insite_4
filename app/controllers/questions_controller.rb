class QuestionsController < ApplicationController
  layout "material"
  include SmartListing::Helper::ControllerExtensions
  helper  SmartListing::Helper
  include ApplicationHelper

  before_filter :set_module_details
  # GET /questions
  # GET /questions.json
  def index
    @questions = Question.all
    smart_listing_create :questions, @questions, partial: "questions/questions_smartlist", default_sort: {created_at: "desc"}

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @questions }
      format.js
    end
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
    @question = Question.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @question }
    end
  end

  # GET /questions/new
  # GET /questions/new.json
  def new
    @question = Question.new
    @option = @question.options.build

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @question }
    end
  end

  # GET /questions/1/edit
  def edit
    @question = Question.find(params[:id])
  end

  # POST /questions
  # POST /questions.json
  def create
    begin
      raise "Question must be allocated to one outlet." unless params[:unit_ids].present?
      ActiveRecord::Base.transaction do
        @question = Question.new(params[:question])

        respond_to do |format|
          if @question.save
            QuestionUnit.save_unit_questions(@question.id, params['unit_ids']) if params[:unit_ids].present?
            format.html { redirect_to @question, notice: 'Question was successfully created.' }
            format.json { render json: @question, status: :created, location: @question }
          else
            format.html { render action: "new" }
            format.json { render json: @question.errors, status: :unprocessable_entity }
          end
        end
      end
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_question_path, alert: e.message.to_s
    end
  end


  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    begin
      raise "Question must be allocated to one outlet." unless params[:unit_ids].present?
      ActiveRecord::Base.transaction do
        @question = Question.find(params[:id])

        respond_to do |format|
          if @question.update_attributes(params[:question])
            QuestionUnit.save_unit_questions(@question.id, params['unit_ids']) if params[:unit_ids].present?
            format.html { redirect_to @question, notice: 'Question was successfully updated.' }
            format.json { head :no_content }
          else
            format.html { render action: "edit" }
            format.json { render json: @question.errors, status: :unprocessable_entity }
          end
        end
      end  
    rescue Exception => e
      Rscratch::Exception.log e,request
      redirect_to new_question_path, alert: e.message.to_s
    end    
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question = Question.find(params[:id])
    @question.destroy

    respond_to do |format|
      format.html { redirect_to questions_url }
      format.json { head :no_content }
    end
  end

  def update_status
    @question = Question.find(params[:question_id])
    @question.update_attribute(:status,params[:question_status])
    respond_to do |format|
      format.json { render json: @question }
    end
  end

  private

    def set_module_details
      @module_id = "questions"
      @module_title = "Questions"
    end

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def question_params
      params.require(:question).permit(:title, :question_type)
    end
end
