# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../../spec_helper')


describe '/admin/rooms/new' do
  include JcCapybara

  let(:o) { mock_model(Organism, racine:'assotest') }

  before(:each) do
    assign(:organism, o)
    render
  end

  it "page should have a a title and a firm" do
    page.should have_content 'Nouvel organisme'
    page.all('form').should have(1).form 
  end

end