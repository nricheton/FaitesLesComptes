# coding: utf-8

require 'spec_helper'



describe 'bank_extract_lines' do

  include OrganismFixtureBis
  
  def bank_extract_test
    @be = @ba.bank_extracts.create!(begin_date:Date.today.beginning_of_month, end_date:Date.today.end_of_month,
      begin_sold:10, :total_debit=>12.25, :total_credit=>50)

    @d7 = create_outcome_writing(7)
    @d29 = create_outcome_writing(29)

    @be.bank_extract_lines.new(:compta_line_id=>@d7.support_line.id)
    @be.bank_extract_lines.new(:compta_line_id=>@d29.support_line.id)
    @be.save!
  end

  before(:each) do
    use_test_user
    login_as('quidam')
    use_test_organism 
    bank_extract_test
   # visit admin_room_path(@r)    
 
  end
  
  after(:each) do
    BankExtract.delete_all 
  end

  context 'on part du bank_extract' do


    before(:each) do
      visit bank_account_bank_extracts_path(@ba)
    end

    it 'cliquer sur afficher affiche les lignes' do
      
      within('table') do
        click_link('Afficher') 
      end
      current_path.should == bank_extract_bank_extract_lines_path(@be)
      
    end

  end

 

end
