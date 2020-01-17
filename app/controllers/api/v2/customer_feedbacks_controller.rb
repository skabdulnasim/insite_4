module Api
  module V2
    class CustomerFeedbacksController < ApplicationController
      ### => API Documentation (APIPIE) for 'index' action
      api :POST, '/api/v2/customer_feedbacks', "Api to generate a customer_feedbacks."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending the request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 instead)."
      param :customer_feedback, Hash, :required => true, :desc => <<-EOS

          ==== A sample parameter value is given below
            {
              "unit_id": "3",
              "email": "gobinda@gmail.com",
              "name": "Gobinda Manna",
              "phone": "9674442296",
              "customer_feedback_answers_attributes": [
                {
                  "feedback_id": "1",
                  "feedback_option_id": "1"
                }
              ]
            }
        EOS
      formats ['json']

      def create
        @customer_feedback = CustomerFeedback.new(params[:customer_feedback])
        @customer_feedback.save
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      private

    end
  end
end
