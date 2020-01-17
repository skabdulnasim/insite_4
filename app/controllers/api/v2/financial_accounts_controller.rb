module Api
  module V2
    class FinancialAccountsController < ApplicationController

    	### => API Documentation (APIPIE) for 'show' action
      api :GET, '/api/v2/financial_accounts/:id', "API to fetch a account with its transaction history."
      param :device_id, String, :required => false, :desc => "ID of registered device (If its a request from portal send YOTTO05 as default device ID)."
      param :email, String, :required => false, :desc => "Register user email"
      formats ['json']
    	
    	def show
    		_per = params[:count] || 10
        @financial_account = FinancialAccount.find(params[:id])
        if @financial_account.present?
          @account_transactions = @financial_account.financial_account_transactions.order("id desc")
          @account_transactions_count = @account_transactions.count
        	@account_transactions = @account_transactions.page(params[:page]).per(_per) if params[:page].present?
        else
        	@account_transactions_count = 0
        end
        rescue Exception => @error
        @log = Rscratch::Exception.log(@error,request) if @error.present? # Log exception
    	end

   	end
  end
end