class ImportedBelsController < ApplicationController
  
  before_filter  :find_bank_account
  
  def index
    @imported_bels = @bank_account.imported_bels.order(:date, :position)
    flash[:notice] = 'Aucune ligne importée en attente' if @imported_bels.empty?
  end
  
  def update
  @imported_bel = ImportedBel.find params[:id]

  respond_to do |format|
    if @imported_bel.update_attributes(params[:imported_bel])
      format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
      format.json { respond_with_bip(@imported_bel) }
    else
      format.html { render :action => "edit" }
      format.json { respond_with_bip(@imported_bel) }
    end
  end
end
  
  private

  def find_bank_account
    @bank_account = BankAccount.find(params[:bank_account_id])
  end
end