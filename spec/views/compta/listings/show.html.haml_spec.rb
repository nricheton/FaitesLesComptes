# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')

 
describe 'compta/listings/show' do 
  include JcCapybara

  let(:ar) {double(Arel)}
  let(:a) {mock_model(Account, long_name:'605 compte de test', compta_lines:ar)}
  let(:p) {mock_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)}
  let(:l) {Compta::Listing.new( account_id:a.id, from_date:Date.today.beginning_of_year, to_date:Date.today.end_of_year)}
  let(:line) {mock_model(Line, line_date:Date.today, narration:'ligne test', debit:0, nature_id:1, destination_id:1)}
  let(:as) {double(Arel,
      order:(1.upto(10).collect {|i| mock_model(Account,
            number:"#{i}", title:"Compte test #{i}",
          long_name:"#{i} - Compte test #{i}")}) )}

  before(:each) do
    
    l.stub(:account).and_return a 
    a.stub(:period).and_return p

    p.stub(:accounts).and_return as
    ar.stub(:listing).and_return ar
    l.stub(:cumulated_debit_before).with(p.start_date).and_return 5
    l.stub(:cumulated_credit_before).with(p.start_date).and_return 0
    l.stub(:sold_before).with(p.start_date).and_return -5
    l.stub(:total_debit).and_return 105
    l.stub(:total_credit).and_return 0
    l.stub(:cumulated_debit_at).with(p.close_date).and_return 105
    l.stub(:cumulated_credit_at).with(p.close_date).and_return 0
    assign(:listing, l)
    assign(:period, p)
    assign(:account, a)
  end
 
  it 'should render' do
    render 
  end

  context 'render' do
    before(:each) do
      render
    end

    it 'doit mettre en titre le numéro et le nom du compte' do
      page.find('.champ > h3').should have_content('Ecritures du compte')
      page.find('.champ > h3').should have_content('605 compte de test')
    end

    it 'avec les dates demandées' do
      page.find('.champ > h3').should have_content("Du 1er janvier #{Date.today.year} au 31 décembre #{Date.today.year}")
    end
  end
end
