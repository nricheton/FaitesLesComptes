# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::RestoresController do

  describe 'GET new' do

    it 'render new' do
      get :new
      response.should render_template('new')
    end 
    
  end

  describe 'POST rebuild' do
    before(:each) do
      @file_name = 'spec/test_compta2.yml'
      File.open(@file_name,'r')  { |f| @datas = YAML.load(f) }
    end

    it 'when compta_restore is a success' do
      Admin::RestoresController.any_instance.stub(:read_datas_from_tmp_file).and_return nil
      File.stub(:delete).and_return nil
      Restore::ComptaRestorer.any_instance.should_receive(:compta_restore).and_return(true)
      Restore::ComptaRestorer.any_instance.stub(:datas).and_return({:organism=> mock_model(Organism, title: 'SUCCES') })
      assigns[:datas] = @datas
      post :rebuild, :file_name=>@file_name 
      flash[:notice].should == 'Importation de l\'organisme SUCCES effectuée'
    end

  end

  describe 'POST create' do
    before(:each) do
       
      @file_name = 'spec/test_compta2.yml'
      @file_name.stub(:original_filename).and_return(@file_name)
      @file_name.stub(:tempfile).and_return(@file= File.open(@file_name, 'r'))
    end
#
    after(:each) do
      @file.close
    end

    it 'should assign @just_filename with the basename' do
      post :create, :file_upload=>@file_name
      assigns[:just_filename].should == 'test_compta2.yml'
    end

    it "should render the view confirm" do
      post :create, :file_upload=>@file_name
      response.should render_template(:confirm)
    end

   
    context "the file is malformatted" do
      before(:each) do
        @file_name = 'spec/invalid_test_compta.yml'
        @file_name.stub(:original_filename).and_return(@file_name)
        @file_name.stub(:tempfile).and_return(@file= File.open(@file_name, 'r'))
    end

      it 'archive should have errors' do 
         post :create, :file_upload=>@file_name
         flash[:alert].should == "Lecture des données impossible. Erreur à la ligne 15, colonne 2"
      end

      it 'should rerender new' do
         post :create, :file_upload=>@file_name
         response.should render_template(:new)  
      end
    end
    
    context "the extension is not correct" do
      
    before(:each) do 
      @file_name = './eliminer/test.xml'
      @file_name.stub(:original_filename).and_return(@file_name)
    end

    it 'should flash an alert' do
      post :create, :file_upload=>@file_name
      flash[:alert].should == "Erreur : l'extension du fichier ne correspond pas.\n"
    end

      it 'should rerender new' do
        post :create, :file_upload=>@file_name
        response.should render_template(:new) 
      end

    end
  end
end
