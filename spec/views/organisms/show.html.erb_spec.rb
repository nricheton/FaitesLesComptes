# coding: utf-8

require 'spec_helper' 


describe "organisms/show" do 
  


let(:o) {stub_model(Organism) }
let(:ibook) {stub_model(IncomeBook, :title=>'Recettes') }
let(:obook) { stub_model(OutcomeBook, title: 'Dépenses')}
let(:p2012) {stub_model(Period, start_date: Date.civil(2012,01,01), close_date: Date.civil(2012,12,31))}
let(:p2011) {stub_model(Period, start_date: Date.civil(2011,01,01), close_date: Date.civil(2011,12,31)) }
let(:sect) {stub_model(Sector, name:'Unique', query_monthly_datas:{'11-2012'=>'10.20', '12-2012'=>'15.25'})}

before(:each) do
  CheckDeposit.stub(:nb_to_pick).and_return 0
    assign(:organism, o)
    o.stub(:periods).and_return([p2011,p2012])
    o.stub(:find_period).and_return(p2012)
    p2012.stub(:previous_period?).and_return(true)
    p2012.stub(:previous_period).and_return(p2011)
    ibook.stub(:organism).and_return(o)
    obook.stub(:organism).and_return(o)
    ibook.stub_chain(:organism, :all).and_return([p2011, p2012])
    obook.stub_chain(:organism, :all).and_return([p2011, p2012])
    assign(:books, [ibook,obook])
    assign(:period, p2012 )
    assign(:paves, [ibook,obook,sect])
    # assign(:p2011, p2011 )
    o.stub_chain(:destinations, :all).and_return(%w(lille dunkerque))
   end

  # TODO revoir complètement car probablement totalement false positive

  it "renders show organism with graphics" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "#book_#{ibook.id}" do
     assert_select ".legend", '2011;2012'
    end
  end

  it "renders show organism with graphics" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "#book_#{ibook.id}" do
     assert_select ".legend", '2011;2012'
    end
  end

  context 'when active period is p2011' do

    before(:each) do
      assign(:period, p2011)
       p2011.stub(:previous_period?).and_return(false)
    end

     it "renders show organism with only a one year graphic" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "#book_#{ibook.id}" do
     assert_select ".legend", '2011'
    end
  end

  


  end
end

