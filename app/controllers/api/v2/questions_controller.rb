module Api
  module V2
    class QuestionsController < ApplicationController
      load_and_authorize_resource

      ### => API Documentation (APIPIE) for 'index' action
      api :GET, '/api/v2/questions', "List of all questions."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :unit_id, String, :required => true, :desc => "Questions of this unit"
      param :question_type, String, :required => false, :desc => "if you want filter by question_type", :meta => "`question_type` value must be Inspection or Feedback"
      param :page, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results"
      param :count, String, :required => false, :desc => "If `page` parameter is present in request, this API will response with pagination and by default it will return 20 results. If you want to define the number of results per page, you can do so by adding `count` parameter in your request.", :meta => "`count` parameter is dependent on `page` parameter"   
      ### => 'index' API Defination
      def index
        _per  = params[:count] || 20
        @unit = Unit.find(params[:unit_id])
        @question_units = @unit.question_units.active_question
        @question_units = @question_units.by_question_type(params[:question_type]) if params[:question_type].present?
        @count = @question_units.count
        @questions = @questions.page(params[:page]).per(_per) if params[:page].present?
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      # ### => API Documentation (APIPIE) for 'show' action
      # api :GET, '/api/v2/questions/:id', "Question Details."
      # param :email, String, :required => false, :desc => "Email ID of user, who is sending the request."
      # param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      # ### => 'show' API Defination
      # def show
      #   @question = Question.find(params[:id])
      #   rescue Exception => @error
      #   @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      # end

      private

    end
  end
end
