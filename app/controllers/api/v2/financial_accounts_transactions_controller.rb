module Api
  module V2
    class FinancialAccountsTransactionsController < ApplicationController
      before_filter :authenticate_user_with_token! ,only: [:debit]
      ### => API Documentation (APIPIE) for 'create' action
      api :POST, '/api/v2/financial_accounts_transactions', "API to generate a financial account transaction."
      param :email, String, :required => true, :desc => "Email ID of user, who is sending request."
      param :device_id, String, :required => true, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :financial_accounts_transaction, Hash, :required => true, :desc => <<-EOS
          ==== A sample parameter value is given below
            {
              "amount": "2000",
              "device_id": "YOTTO05",
              "purpose": "purpose of the transaction",
              "remarks": "Payment Note",
              "transaction_type": "credit",
              "consumer_id": "16",
              "consumer_type": "user",
              "financial_account_id":2,
              "fat_payments_attributes":[
                {
                  "fat_paymentmode_type":"FatCash",
                  "fat_paymentmode_attributes":{
                    "amount":"500"
                  }
                },
                {
                  "fat_paymentmode_type":"FatCard",
                  "fat_paymentmode_attributes":{
                    "amount":"500",
                    "bank":"SBI",
                    "card_no":"1234",
                    "card_type":"Debit",
                    "cvv":"1234",
                    "merchandiser":"ABC",
                    "name_on_card":"Kalyan",
                    "valid_upto":"2024-3-31"
                  }
                },
                {
                  "fat_paymentmode_type":"FatBank",
                  "fat_paymentmode_attributes":{
                    "amount":"500",
                    "bank_name":"SBI",
                    "identity":"ABS12334RTU",
                    "mode":"NEFT/RTGS"
                  }
                },
                {
                  "fat_paymentmode_type":"FatCheque",
                  "fat_paymentmode_attributes":{
                    "amount":"500",
                    "bank_name":"SBI",
                    "cheque_no":"1234098765",
                    "clearnce_date":"2019-07-12"
                  }
                }
              ]   
            }
        EOS
      formats ['json']

      def create
        ActiveRecord::Base.transaction do
          params[:financial_accounts_transaction][:fat_payments_attributes].each do |f_p|
            credit_to_transaction(finalcial_params(f_p))
          end
          @financial_account = FinancialAccount.find(params[:financial_accounts_transaction][:financial_account_id])
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
      end

      def credit_to_transaction(financial_accounts_transaction_param)
        @financial_account_transaction = FinancialAccountTransaction.new(financial_accounts_transaction_param)
        if @financial_account_transaction.save
          @financial_account_transaction.reload
        else  
          @validation_errors = error_messages_for(@financial_account_transaction)
        end
      end

      def debit
        financial_account_debit_transaction = FinancialAccountTransaction.new(financial_transaction_debit_params())
        if financial_account_debit_transaction.save
          financial_account_debit_transaction.reload
          puts current_user.unit.inspect
          financial_account_id = current_user.unit.financial_account.id if current_user.present?
          if financial_account_id.present?
            credit_to_transaction(financial_transaction_outlet_credit_params(financial_account_id))
          else
             @validation_errors = error_messages_for(financial_account_debit_transaction)
          end
        else
          @validation_errors = error_messages_for(financial_account_debit_transaction)
        end
      end

      def debit_from_transaction()
        financial_account_debit_transaction = FinancialAccountTransaction.new(financial_transaction_debit_params())
        if financial_account_debit_transaction.save
          financial_account_debit_transaction.reload
          financial_account_id = current_user.unit.financial_account.id if current_user.present?
          if financial_account_id.present?
            credit_to_transaction(financial_transaction_outlet_credit_params(financial_account_id))
          else
             @validation_errors = error_messages_for(financial_account)
          end
        else
          @validation_errors = error_messages_for(financial_account_debit_transaction)
        end
      end

      private
      
      def finalcial_params(f_p)
        {
          "amount"                  => f_p["fat_paymentmode_attributes"]["amount"],
          "device_id"               => params[:financial_accounts_transaction][:device_id],
          "purpose"                 => params[:financial_accounts_transaction][:purpose],
          "remarks"                 => params[:financial_accounts_transaction][:remarks],
          "transaction_type"        => params[:financial_accounts_transaction][:transaction_type],
          "consumer_id"             => params[:financial_accounts_transaction][:consumer_id],
          "consumer_type"           => params[:financial_accounts_transaction][:consumer_type],
          "transaction_entity_type" => params[:financial_accounts_transaction][:transaction_entity_type],
          "transaction_entity_id"   => params[:financial_accounts_transaction][:transaction_entity_id],
          "financial_account_id"    => params[:financial_accounts_transaction][:financial_account_id],
          "recorded_at"             => params[:financial_accounts_transaction][:recorded_at],
          "fat_paymentmode_type"    => f_p["fat_paymentmode_type"],
          "fat_paymentmode_attributes" => f_p["fat_paymentmode_attributes"]
        }
      end
      def financial_transaction_outlet_credit_params(financial_account_id)
        {
        "amount"                  => params[:financial_accounts_transaction][:amount],
        "device_id"               => params[:financial_accounts_transaction][:device_id],
        "purpose"                 => params[:financial_accounts_transaction][:purpose],
        "remarks"                 => params[:financial_accounts_transaction][:remarks],
        "transaction_type"        => "credit", 
        "consumer_id"             => params[:financial_accounts_transaction][:consumer_id],
        "consumer_type"           => params[:financial_accounts_transaction][:consumer_type],
        "transaction_entity_type" => params[:financial_accounts_transaction][:transaction_entity_type],
        "transaction_entity_id"   => params[:financial_accounts_transaction][:transaction_entity_id],
        "financial_account_id"    => financial_account_id,
        "fat_paymentmode_type"    => "internal" #this field might need to be changed
        }
      end
      def financial_transaction_debit_params()
        {
        "amount"                  => params[:financial_accounts_transaction][:amount],
        "device_id"               => params[:financial_accounts_transaction][:device_id],
        "purpose"                 => params[:financial_accounts_transaction][:purpose],
        "remarks"                 => params[:financial_accounts_transaction][:remarks],
        "transaction_type"        => "debit", 
        "consumer_id"             => params[:financial_accounts_transaction][:consumer_id],
        "consumer_type"           => params[:financial_accounts_transaction][:consumer_type],
        "transaction_entity_type" => params[:financial_accounts_transaction][:transaction_entity_type],
        "transaction_entity_id"   => params[:financial_accounts_transaction][:transaction_entity_id],
        "financial_account_id"    => params[:financial_accounts_transaction][:financial_account_id],
        "fat_paymentmode_type"    => "internal" #this field might need to be changed
        }
      end
    end
  end
end