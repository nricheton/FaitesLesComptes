# -*- encoding : utf-8 -*-

require 'spec_helper'

describe Admin::SubscriptionsController do
  include SpecControllerHelper
  
  let(:masks) {[mock_model(Mask, complete?:true), mock_model(Mask, complete?:false)]}
  
  before(:each) do
    minimal_instances
    sign_in(@cu)
    @o.stub(:subscriptions).and_return @a = double(Arel) 
    @o.stub_chain(:periods, :opened, :order, :first, :start_date, :year).and_return 2013
    @o.stub(:masks).and_return masks
  end
  
  describe "GET new" do
    before(:each) do
      @a.stub(:new).and_return mock_model(Subscription).as_new_record
    end
    
    it "assigns a new subscription as @subscription" do
      @a.should_receive(:new).and_return mock_model(Subscription).as_new_record
      get :new, {organism_id:@o.to_param}, valid_session
      assigns(:subscription).should be_a_new(Subscription)  
    end
    
    it 'rend le template new' do
      
      get :new, {organism_id:@o.to_param}, valid_session
      response.should render_template('new')
    end
    
    context 'pas de masque complet' do
      
      before(:each) do
        @o.stub(:masks).and_return [mock_model(Mask, complete?:false), mock_model(Mask, complete?:false)]
        request.env["HTTP_REFERER"] = 'origine'
      end
      
      it 'remplit un flash notice d avertissement' do
        get :new, {organism_id:@o.to_param}, valid_session
        flash[:notice].should == 'Vous n\'avez pas de guide de saisie permettant de générer une écriture périodique'
      end
      
      it 'redirige vers back' do
        get :new, {organism_id:@o.to_param}, valid_session
        response.should redirect_to 'origine'
      end
      
      
    end
  end
  
  describe 'POST create' do
    
    def valid_attributes
      {'title'=>'nouvel abonnement', 'day'=>'7', 'mask_id'=>'1', 'permanent'=>'true'}
    end
    
    def prepared_attributes
      pattr = valid_attributes
      pattr.delete('permanent')
      pattr
    end
    
    it 'crée un nouvel abonnement' do
      Subscription.should_receive(:new).with(prepared_attributes).and_return(@sub = mock_model(Subscription).as_new_record)
      @sub.stub(:save).and_return true
      post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
    end
    
   
      
    it 'doit recevoir prepare_params' do
      Subscription.stub(:new).with(prepared_attributes).
        and_return(@sub = mock_model(Subscription))
      @sub.stub(:save).and_return false
      @controller.should_receive(:prepare_params).with(valid_attributes).and_return(prepared_attributes)
      post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
    end
    
    
    it 'le sauve' do
      Subscription.stub(:new).and_return(@sub = mock_model(Subscription))
      @sub.should_receive(:save).and_return true 
      post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
    end
    
    context 'la sauvegarde est valide' do
      
      it 'redirige vers la vue index' do
        Subscription.stub(:new).and_return(@sub = mock_model(Subscription, save:true))
        post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
        response.should redirect_to admin_organism_subscriptions_url(@o)
      end
      
      it 'avec un flash' do
        Subscription.any_instance.stub(:save).and_return true
        post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
        flash[:notice].should == "L'écriture périodique 'nouvel abonnement' a été créée"
      end
    end
    
    context 'la sauvegarde est invalide' do
      
      it 'rend la vue new' do
        Subscription.stub(:new).and_return(@sub = mock_model(Subscription, save:false))
        post :create, {organism_id:@o.to_param, subscription:valid_attributes}, valid_session
        response.should render_template('new')
      end
      
    end
    
  end
  
  describe 'index' do
    let(:all_sub) {[mock_model(Subscription), mock_model(Subscription)]}
    
    it 'cherche tous les abonnements' do
      @o.should_receive(:subscriptions).and_return(all_sub)
      get :index, {organism_id:@o.to_param}, valid_session
    end
    
    it 'l assigne à la variable @subs' do
      @o.stub(:subscriptions).and_return(all_sub)
      get :index, {organism_id:@o.to_param}, valid_session
      assigns[:subs].should == all_sub
    end
    
    
    it 'rend la vue index' do
      @o.stub(:subscriptions).and_return(all_sub)
      get :index, {organism_id:@o.to_param}, valid_session
      response.should render_template 'index'
    end
    
  end
  
  describe 'destroy' do
    it 'cherche le subscription' do
      Subscription.should_receive(:find).with('1').and_return(mock_model(Subscription))
      delete :destroy, {organism_id:@o.to_param, id:'1'}, valid_session
    end
    
    it 'detruit le subscription' do
      Subscription.stub(:find).and_return(@sub = mock_model(Subscription))
      @sub.should_receive(:destroy).and_return true
      delete :destroy, {organism_id:@o.to_param, id:'1'}, valid_session
    end
    
    it 'puis redirige vers index' do
      Subscription.stub(:find).and_return(@sub = mock_model(Subscription, destroy:true))
      delete :destroy, {organism_id:@o.to_param, id:'1'}, valid_session
      response.should redirect_to admin_organism_subscriptions_url(@o)
    end
  end
  
  describe 'prepare' do
    
    it 'supprime les champs date si permanent' do
      params  = {"title"=>"un test", "mask_id"=>"1",
        "day"=>"6", "permanent"=>"true", "end_date(3i)"=>"1", "end_date(2i)"=>"12", "end_date(1i)"=>"2013"}
      @controller.send(:prepare_params, params).should == {"title"=>"un test", "mask_id"=>"1", "day"=>"6"} 
    end
    
    
    
  end
  
  
  
end