# -*- encoding : utf-8 -*-

require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass. 
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message. 

RSpec.configure do |c|
  #  c.filter = {:wip=> true }
end

describe Admin::RoomsController do
  include SpecControllerHelper 
 
  
  before(:each) do
    minimal_instances
    # minimal instance donne @cu pour current_user et @r comme room
    @cu.stub('up_to_date?').and_return true
  end

 
  describe "GET index" do
    
    it "assigns all rooms as @rs" do
      @cu.stub(:rooms).and_return(@a = double(Arel, :map=>[], :count=>2))
      get :index
      assigns(:rooms).should == @a
    end

    it 'renders template index' do
      @cu.stub(:rooms).and_return(@a = double(Arel, :map=>[], :count=>2))
      get :index 
      response.should render_template('index')
    end

    it 'si toutes les roome sont en phase n affiche pas de flash' do
      @cu.should_receive(:rooms).and_return([mock_model(Room, :relative_version=>:same_migration)])
      get :index
      flash[:alert].should == nil
    end

    describe 'contrôle des flash' do
      
      before(:each) do
        @cu.stub(:rooms).and_return([mock_model(Room)])
        @cu.stub('up_to_date?').and_return false
      end

      it 'si une room est en retard affiche un flash' do
        @cu.stub(:status).and_return([:late_migration])
        get :index,{}
        flash[:alert].should == 'Une base au moins est en retard par rapport à la version de votre programme, migrer la base correspondante'
      end

      it 'si une room est en avance, affiche un flash' do
        @cu.stub(:status).and_return([:advance_migration])
        get :index,{}
        flash[:alert].should == 'Une base au moins est en avance par rapport à la version de votre programme, passer à la version adaptée'
      end

      it 'si une base n existe pas ' do
        @cu.stub(:status).and_return([:no_base])
        get :index,{}
        flash[:alert].should == 'Un fichier correspondant à une base n\'a pu être trouvée ; vous devriez effacer l\'enregistrement correspondant'
      end

    end
  end

  describe "GET show" do

    before(:each) do
      @cu.stub_chain(:rooms, :find).and_return @r
    end

    it "assigns the requested room as @r" do
      @cu.should_receive(:rooms).and_return(@a = double(Arel))
      @a.should_receive(:find).with(@r.to_param).and_return(@r)
      get :show, {:id => @r.to_param}
      assigns(:room).should eq(@r)
      
    end

    it 'redirige vers l organisme correspondant' do
      get :show, {:id => @r.to_param}
      response.should redirect_to(admin_organism_url(@o))
    end
  end

  
  describe "DELETE destroy" do
    before(:each) do
      @cu.stub_chain(:rooms, :find).and_return(@r)
      @r.stub(:database_name).and_return(SCHEMA_TEST)
      @r.stub(:organism).and_return(@organism=mock_model(Organism))
      @r.stub(:owner).and_return @cu
    end

    it 'renvoie vers rooms index' do
      @r.stub(:destroy).and_return true
      delete :destroy,{:id => @r.to_param}
      response.should redirect_to admin_rooms_url
    end

    it 'crée un flash sur suppression échoue' do
      @r.stub(:destroy).and_return false
      delete :destroy,{:id => @r.to_param}
      flash[:alert].should == "Une erreur s'est produite; la base #{SCHEMA_TEST} n'a pas été supprimée"
      response.should redirect_to admin_organism_url(@organism)
    end
    
    it 'met à jour le cache pour la liste des organismes' do
      @r.stub(:destroy).and_return true
      @controller.should_receive(:clear_org_cache) 
      delete :destroy,{:id => @r.to_param}
    end

    
  end

  describe 'GET new' do

    it 'rend le formulaire' do
      get :new, {}, valid_session
      response.should render_template :new
    end
  end

  describe 'POST create', wip:true do
    before(:each) do
      Room.any_instance.stub(:database_name).and_return SCHEMA_TEST
    end
    
    it 'appelle build_a_new_room' do
      @controller.should_receive(:build_a_new_room)
      post :create, {'room'=>{'title'=>'Bizarre', 'racine'=>'assotest', status:'Association'}}, valid_session
    end

    context 'quand build_a_new_room a tout bien fait' do 

      before(:each) do
        @controller.stub(:build_a_new_room).and_return true
        Room.any_instance.stub(:organism).and_return @o
      end

      it 'redirige vers la création d un exercice' do
        
        post :create, {'room'=>{'title'=>'Bizarre', 'racine'=>'assotest', status:'Association'}}, valid_session
        response.should redirect_to new_admin_organism_period_url(@o)
      end
  
    end
    context 'quand build new room échoue' do
      
       before(:each) do
        @controller.stub(:build_a_new_room).and_return false
        
      end

      it 'rend la vue new'  do
        post :create, {'room'=>{'title'=>'Bizarre', 'racine'=>'assotest', status:'Association'}}, valid_session
        response.should render_template :new
      end
 
    end
  
  # TODO faire les tests de build_new_room  
    
  end 


end
