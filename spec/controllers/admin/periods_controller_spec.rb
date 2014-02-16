# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::PeriodsController do
   include SpecControllerHelper

  def valid_params
    {'start_date'=>Date.today.beginning_of_year.to_formatted_s(:db), 'close_date'=>Date.today.end_of_year.to_formatted_s(:db)}
  end

   before(:each) do
     minimal_instances
   end

  describe 'GET index' do
    before(:each) do
       @o.stub(:periods).and_return [mock_model(Period), mock_model(Period)]

    end

    it 'renden index template' do
      get :index, {organism_id:@o.id}, valid_session
      response.should render_template(:index)
    end
  end

  describe 'POST create' do

    context 'quand il n y a pas d exercice' do

    before(:each) do
      @o.stub(:periods).and_return(@a = double(Arel, :find_by_id=>nil))
      @a.stub('any?').and_return false 
    end

    it 'rend vue index si tout est OK' do
      @a.should_receive(:new).with(valid_params).and_return mock_model(Period, :save=>true, 'previous_period?'=>false).as_new_record
      post :create, {organism_id:@o.id, :period=>valid_params}, valid_session
      response.should redirect_to admin_organism_periods_url(@o)
    end

    it 'rend la vue edit si erreur dans la sauvegarde' do
      @a.should_receive(:new).with(valid_params).and_return mock_model(Period, :save=>false).as_new_record
      post :create, {organism_id:@o.id, :period=>valid_params}, valid_session
      response.should render_template :new
    end

    end

    context 'quand il y a daje un exercice' do

      before(:each) do
        @o.stub(:periods).and_return(@a = double(Arel, :find_by_id=>nil))
        @a.stub('any?').and_return true
        @a.stub(:last).and_return(mock_model(Period, :close_date=>Date.today))
      end

      it 'le nouvel exercice doit avoir la date de départ remplie' do
        @a.stub(:new).with(valid_params).and_return(@new_period = (mock_model(Period, :save=>true, 'previous_period?'=>false).as_new_record))
        @new_period.should_receive(:start_date=).with(Date.today + 1 )
        post :create, {organism_id:@o.id, :period=>valid_params}, valid_session
      end


    end
  end

  describe 'DELETE destroy' do


    it "destroys the requested period" do
      Period.should_receive(:find).with(@p.to_param).and_return(@p)
      delete :destroy, {organism_id:@o.to_param, :id=>@p.to_param}, valid_session

    end

    it "redirects to the period list" do
      Period.should_receive(:find).with(@p.to_param).and_return(@p)
      delete :destroy, {organism_id:@o.to_param, :id=>@p.to_param}, valid_session
      response.should redirect_to(admin_organism_periods_url(@o))
    end
  end

  describe 'POST close' do

    it 'affiche un flash de succes' do
      @p.should_receive(:close).and_return true
      post :close, {organism_id:@o.to_param, id:@p.to_param}, valid_session
      flash[:notice].should == "L'exercice est maintenant clos"
      response.should redirect_to admin_organism_periods_url(@o)
    end

    it 'affiche ou un flash d\'erreur et réaffiche index' do
      @p.should_receive(:close).and_return false
      @p.stub(:exercice).and_return('Exercice 2013')
      post :close, {organism_id:@o.to_param, id:@p.to_param}, valid_session
      flash[:alert].should == "Exercice 2013 ne peut être clos : \n"
      response.should render_template(:index)
    end

    it 'le flash alert donne l explication' do
      @p.stub(:close).and_return false
      @p.stub(:exercice).and_return('Exercice 2013')
      @p.errors.add(:close, 'message d erreur')
      post :close, {organism_id:@o.to_param, id:@p.to_param}, valid_session
      flash[:alert].should == "Exercice 2013 ne peut être clos : \n- message d erreur\n"
    end

  end

 
  describe 'GET new' do

    context "check the rendering" do

     before(:each) do
       @o.stub_chain(:periods, :new).and_return mock_model(Period)
     end

    it "controller name should be period" do
      get :new , {:organism_id=>@o.id} , valid_session 
      controller.controller_name.should == 'periods'
    end
  
    it "render new template" do
      get :new , {:organism_id=>@o.id} , valid_session
      response.should render_template(:new) 
    end

      end

    context "when no period, build the new period" do
      before(:each) do
       @o.stub(:periods).and_return @a = double(Arel)
       @a.stub(:any?).and_return false
       @a.stub(:empty?).and_return(!(@a.any?))
      end

      it "with start_date equal to beginning_of_year" do
        @a.should_receive(:new).with(start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year).and_return @p
        get :new , {:organism_id=>@o.id} ,  {user:@cu.id, org_db:'assotest'}
        assigns[:period].start_date.should == Date.today.beginning_of_year
      end

      it 'with close_date equal to end_of_year' do
        @a.should_receive(:new).with(start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year).and_return @p
         get :new , {:organism_id=>@o.id} ,  {user:@cu.id, org_db:'assotest'}
        assigns[:period].close_date.should == Date.today.end_of_year
      end

    end

    

    context "with a previous period" do

      def arguments
        b = Date.today.beginning_of_year.years_since(1)
        e = b.end_of_year
        {start_date:b, close_date:e}
      end

      before(:each) do
        @o.stub(:periods).and_return @a = double(Arel)
        @a.stub(:any?).and_return true
        @a.stub(:empty?).and_return(!(@a.any?))
        @a.stub_chain(:last, :close_date).and_return @p.close_date
        @a.stub(:find_by_id).and_return(@p)
      end
  
      it 'disable_start_date should be true' do
        @a.should_receive(:new).with(arguments).and_return mock_model(Period)
        get :new , {:organism_id=>@o.id} , valid_session
        assigns[:disable_start_date].should == true
      end

      it "begin_year is this year" do
        @a.should_receive(:new).with(arguments).and_return mock_model(Period)
        get :new , {:organism_id=>@o.id} ,  valid_session
        assigns[:begin_year].should == (Date.today.year + 1)
      end

      it "end_year is limited to 2 years" do
        @a.should_receive(:new).with(arguments).and_return mock_model(Period)
        get :new , {:organism_id=>@o.id} , valid_session
        assigns[:end_year].should == (Date.today.year + 3)
      end
    end

  end
end

