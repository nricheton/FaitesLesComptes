# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |c|
  # c.filter = {:wip=>true}
end

# on utilise Admin::PeriodsController mais le but de cette spec est de faire les tests
# des actions before_filter de application_controller
describe Admin::PeriodsController do
  include SpecControllerHelper
  let(:cu) {mock_model(User, 'up_to_date?'=>true)}
  let(:o) {mock_model(Organism)}
  let(:r1) {mock_model(Room)}
  let(:r2) {mock_model(Room)}
  let(:p) {mock_model(Period)}

  
  describe 'before_filters' do

    

    context 'signed' do


      before(:each) do
        sign_in(cu)
        cu.stub_chain(:rooms, :count).and_return 2
      end


      describe 'find_organism'  do
      
        it 'pas d organisme si pas de session de org_db' do
          get :index, { :action=>'admin/rooms'}
          assigns(:organism).should == nil
        end

        it 'si session[:org_db, cherche la chambre et assigne @organism' do
          cu.should_receive(:rooms).and_return(@ar = double(Arel))
          @ar.should_receive(:find_by_database_name).with('bonjour').and_return(r1)
          r1.stub(:connect_to_organism).and_return true
          Organism.should_receive(:first).and_return(@o = double(Organism))
          @o.stub_chain(:periods, 'empty?').and_return true
          get :index, {}, {org_db:'bonjour'}
          assigns(:organism).should == @o
        end

        it 'si plusieurs organismes renvoie vers admin_rooms' do
          cu.stub_chain(:rooms, :count).and_return 2
          get :index, { :action=>'admin/rooms'}
          assigns(:organism).should == nil
          response.should redirect_to admin_rooms_url
        end
      end


      describe 'current_period' do
      
        before(:each) do
          Organism.stub(:first).and_return o
        end
      
        it 'rien sans organisme' do
          get :index, {}
          assigns(:period).should be_nil
        end



    
        it 'look for period when there is no session period' do
            
          cu.stub_chain(:rooms, :find_by_database_name).and_return(r1)
          r1.stub(:connect_to_organism)
          # 3 fois : 1 pour periods.empty?
          # 1 pour period.last
          o.should_receive(:periods).exactly(3).times.and_return(@a = double(Arel))
          @a.stub(:empty?).and_return(false)
          @a.should_receive(:last).and_return(p)
          get :index, {}, {user:cu.id, org_db:SCHEMA_TEST}
          assigns(:period).should == p
          session[:period].should == p.id
        end

        it 'look for period from session when there is one (current_period)' do

          cu.stub_chain(:rooms, :find_by_database_name).and_return(r1)
          r1.stub(:connect_to_organism)
          o.should_receive(:periods).exactly(2).times.and_return(@a=double(Arel))
          @a.should_receive(:find_by_id).with(p.id).and_return p
          get :index,{}, {user:cu.id, org_db:SCHEMA_TEST, period:p.id}
          assigns(:period).should == p
          session[:period].should == p.id
        end

      end

      describe 'sign_out' do

        it 'renvoie vers la page bye quand on se déloggue' do
          pending 'à faire'

        end
      end
      
      describe 'filename' do
        
        let(:obj) {double(Object, title:'Bilan')}
        let(:dat) { I18n.l(Date.today, format:'%d-%b-%Y').gsub('.', '') }
        
        before(:each) do
          cu.stub_chain(:rooms, :find_by_database_name).and_return(r1)
          r1.stub(:connect_to_organism)
          Organism.stub(:first).and_return o
          o.stub(:periods).and_return []
          o.stub(:title).and_return 'Asso Test'
        end
        
        it 'renvoie le titre, le nom de l organisme et la date plus l extension' do
          get :index, {}, {user:cu.id, org_db:SCHEMA_TEST}
          @controller.export_filename(obj, :pdf).should == "Bilan Asso Test #{dat}.pdf"
        end
        
        it 'ou avec le dernier item de la classe de l objet si pas de titre' do
          obje = double(Object)
          get :index, {}, {user:cu.id, org_db:SCHEMA_TEST}
          @controller.export_filename(obje, :pdf).should == "Mock Asso Test #{dat}.pdf"
        end
        
        it 'on peut imposer le titre' do
          get :index, {}, {user:cu.id, org_db:SCHEMA_TEST}
          @controller.export_filename(obj, :pdf, 'TITRE').should == "TITRE Asso Test #{dat}.pdf"
        end
        
        
      end


    

    end
  end
  
end
