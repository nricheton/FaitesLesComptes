# coding: utf-8

require 'spec_helper'

 
describe "check_deposits/index" do  
  include JcCapybara

  let(:o) {mock_model(Organism, title: 'spec cd')}
  let(:ba)  {mock_model(BankAccount, number: '124578AZ', name: 'IBAN', nickname:'Compte courant')}
  let(:cd1) {mock_model(CheckDeposit, bank_account_id: ba.id, deposit_date: Date.today - 5)}
  let(:cd2) {mock_model(CheckDeposit, bank_account_id: ba.id, deposit_date: Date.today - 20)}

  10.times do |t| 
    s=('l'+t.to_s).to_sym
    let(s) {mock_model(Line, :amount=>(t+1))}
  end

 

  before(:each) do
    [cd1, cd2].each do |cd|
      cd.stub(:bank_account).and_return(ba)
    end
    ba.stub(:to_s).and_return('124578AZ')
    cd1.stub(:pointed?).and_return(true) # la remise de chèque n° 1 est pointée
    cd2.stub(:pointed?).and_return(false)

    cd1.stub_chain(:total_checks).and_return(10)
    cd1.stub_chain(:checks, :size).and_return(5)
    cd2.stub_chain(:checks,:size).and_return(5)
    cd2.stub_chain(:total_checks).and_return(35)

    assign(:check_deposits, [cd1,cd2])
    assign(:organism, o)
    assign(:bank_account, ba)

  end

   
  describe "controle du corps" do

    before(:each) do
      render
    end

    it "affiche la légende du fieldset" do
      assert_select "h3", :text => "Compte courant : liste des remises de chèques"
    end
    
    it "affiche la table desw remises de chèques" do
      assert_select "table tbody", count: 1
    end
    
    it "affiche les lignes (ici deux)" do
      assert_select "tbody tr", count: 2
    end

    
    context "chaque ligne affiche ..." do

      it "le numéro de compte" do
        assert_select('tr:nth-child(2) td', :text=>cd2.bank_account.number)
      end
      it "la date" do
       assert_select('tr:nth-child(2) td:nth-child(2)', :text=>I18n::l(cd2.deposit_date))
      end
      
      it "le montant (formatté avec une virgule et deux décimales)" do
        assert_select('tr:nth-child(2) td:nth-child(4)', :text=>'35,00')
      end

      it "les liens pour l'affichage" do
        assert_select("tr:nth-child(2) td:nth-child(5) img[src='/assets/icones/afficher.png']")
        assert_select('tr:nth-child(2) td:nth-child(5) a[href=?]',organism_bank_account_check_deposit_path(o,ba, cd2))
      end

      

      it "le lien pour la modification" do
        assert_select('tbody tr:nth-child(2) td:nth-child(5) img[src=?]','/assets/icones/modifier.png')
        assert_select('tbody tr:nth-child(2) td:nth-child(5) a[href=?]',edit_organism_bank_account_check_deposit_path(o,ba, cd2))
      end

      it "le lien pour la suppression" do
        assert_select('tr:nth-child(2) > td:nth-child(5)  img[src=?]','/assets/icones/supprimer.png')
        assert_select('tr:nth-child(2) > td:nth-child(5) a[href=?]', organism_bank_account_check_deposit_path(o,ba, cd2))
      end

    
    end

    context "quand la remise de chèque est pointée, ie elle est reliée à une bank_extract_line" do

      it 'une seul icone' do
        assert_select('tr:nth-child(1) img', count:1)
      end

      it "le lien affichage est toujours disponible" do
        assert_select('tr:nth-child(1) td:nth-child(5) img[src= ?]' , '/assets/icones/afficher.png')
        assert_select('tr:nth-child(1) td:nth-child(5) a[href=?]', organism_bank_account_check_deposit_path(o,ba, cd1))
      end

      it "mais pas le lien modification" do
        assert_select('tr:nth-child(1) td:nth-child(6) a[href=?]',edit_organism_bank_account_check_deposit_path(o,ba, cd1), false)
      end

      it 'ni le lien suppression' do
        assert_select('tr:nth-child(1) > td:nth-child(7) a[href=?]', organism_bank_account_check_deposit_path(o,ba, cd1), false)
      end
    end



  end
end
