# -*- encoding : utf-8 -*-

class BankAccountsController < ApplicationController

  

  # GET /bank_accounts
  # GET /bank_accounts.json
  def index
    @bank_accounts = @organism.bank_accounts.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @bank_accounts }
    end
  end

 
#
#
#  def new_line
#    @bank_account = BankAccount.find(params[:id])
#    @line = Line.new(bank_account_id:@bank_account.id)
#  end



 

  
end
