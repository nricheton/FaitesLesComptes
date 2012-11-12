# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c| 
 # c.filter = {:wip=> true }
#  c.exclusion_filter = {:js=> true }
end

# spec request for testing admin bank_accounts 

describe 'vue bank_accounts index' do  
  include OrganismFixture 
  
  
  before(:each) do  

    create_user
    create_minimal_organism
    login_as('quidam')
  end

  describe 'new bank_account' do
    before(:each) do
      visit new_admin_organism_bank_account_path(@o)
    end


    it "affiche la page new" do
      current_url.should match new_admin_organism_bank_account_path(@o)
      page.should have_content("Nouveau compte bancaire")
      all('form div.control-group').should have(3).elements # name, number et comment
      
    end

    it 'remplir correctement le formulaire cree une nouvelle ligne' do
      
      fill_in 'bank_account[name]', :with=>'Crédit Bancaire'
      fill_in 'bank_account[number]', :with=>'12456321AZ'
      click_button "Créer le compte" # le compte'
      current_url.should match admin_organism_bank_accounts_path(@o)
      all('tbody tr').should have(2).rows
      
    end

    context 'remplir incorrectement le formulaire' do
    it 'test uniqueness organism, name, number' do
      
      fill_in 'bank_account[name]', :with=>@ba.name
      fill_in 'bank_account[number]', :with=>@ba.number
      click_button "Créer le compte" # le compte'
      page.should have_content('déjà utilisé')
      @o.should have(1).bank_accounts
    end 

    it  'test presence name' do
      visit new_admin_organism_bank_account_path(@o)
      fill_in 'bank_account[name]', :with=>@ba.name
      click_button "Créer le compte" # le compte'
      page.should have_content('obligatoire')
    end

    end


  end
 
  describe 'index'  do

   

    it 'on peut le choisir dans la vue index pour le modifier' do
      visit admin_organism_bank_accounts_path(@o)
      click_link "icon_modifier_bank_account_#{@ba.id.to_s}"
      current_url.should match(edit_admin_organism_bank_account_path(@o,@ba)) 
    end

  end

  describe 'edit' do

    it 'On peut changer les deux autres champs et revenir à la vue index' do
      visit edit_admin_organism_bank_account_path(@o, @ba)
      fill_in 'bank_account[name]', :with=>'DebiX'
      click_button 'Enregistrer'
      current_url.should match admin_organism_bank_accounts_path(@o)
      find('tbody tr td').text.should == 'DebiX'

      
    end

  end


end

