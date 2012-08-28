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

describe Admin::CashesController do
  include SpecControllerHelper

  before(:each) do
    minimal_instances
    @ca = mock_model(Cash)
    @o.stub(:cashes).and_return @a = double(Arel)
  end

  # This should return the minimal set of attributes required to create a valid
  # @ca. As you add validations to @ca, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {"name"=>'Magasin', "organism_id"=>@o.id.to_s}
  end

  describe "GET index" do

    it "assigns all cashes as @cashes" do
      @a.stub(:all).and_return [@ca]
      get :index, {:organism_id=>@o.id.to_s}, valid_session
      assigns(:cashes).should == [@ca]
    end

  end

  describe "GET show" do
    it "assigns the requested ca as @ca" do
      @a.stub(:find).with(@ca.id.to_s).and_return @ca
      get :show, {:organism_id=>@o.id.to_s, :id => @ca.id}, valid_session
      assigns(:cash).should == @ca
    end
  end

  describe "GET new" do
    it "assigns a new ca as @ca" do
      @a.should_receive(:new).and_return mock_model(Cash).as_new_record
      get :new,  {:organism_id=>@o.id.to_s}, valid_session
      assigns(:cash).should be_a_new(Cash)      
    end
  end

  describe "GET edit" do 
    it "assigns the requested ca as @ca" do
      @a.stub(:find).with(@ca.id.to_s).and_return @ca
      get :edit, {organism_id:@o.id, :id => @ca.id}, valid_session
      assigns(:cash).should == @ca
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new @ca" do
        @a.should_receive(:new).with(valid_attributes).and_return(@c = mock_model(Cash).as_new_record)
        @c.should_receive(:save)
        post :create,{ :organism_id=>@o.id.to_s, :cash => valid_attributes}, valid_session
       
      end

      it "assigns a newly created @ca as @@ca" do
        @a.stub(:new).and_return(@c = mock_model(Cash).as_new_record)
        @c.stub(:save).and_return true
        post :create, {:organism_id=>@o.id.to_s, :cash => valid_attributes}, valid_session
        assigns(:cash).should == @c
        
      end

      it "redirects to index @ca" do
        @a.stub(:new).and_return(@c = mock_model(Cash))
        @c.stub(:save).and_return true
        post :create, {:organism_id=>@o.id.to_s,  :cash => valid_attributes}, valid_session
        response.should redirect_to(admin_organism_cashes_url(@o))
      end 
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved @ca as @@ca" do
        @a.stub(:new).and_return(@c = mock_model(Cash).as_new_record)
        @c.stub(:save).and_return false
        post :create, {:organism_id=>@o.id.to_s,  :cash => {}}, valid_session
        assigns(:cash).should be_a_new(Cash)
      end

      it "re-renders the 'new' template" do
        @a.stub(:new).and_return(@c = mock_model(Cash).as_new_record)
        @c.stub(:save).and_return false
        post :create,{:organism_id=>@o.id.to_s,  :cash => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested @ca" do
        @a.stub(:find).with(@ca.id.to_s).and_return @ca
        @ca.should_receive(:update_attributes).with({'these' => 'params'})
        put :update,{:organism_id=>@o.id.to_s,  :id => @ca.id, :cash => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested @ca as @@ca" do
        @a.stub(:find).with(@ca.id.to_s).and_return @ca
        @ca.stub(:update_attributes).and_return true
        put :update,{:organism_id=>@o.id.to_s,  :id => @ca.id, :cash => valid_attributes}, valid_session
        assigns(:cash).should eq(@ca)
      end

      it "redirects to index" do
        @a.stub(:find).with(@ca.id.to_s).and_return @ca
        @ca.stub(:update_attributes).and_return true
        put :update, {:organism_id=>@o.id.to_s, :id => @ca.id, :cash => valid_attributes}, valid_session
        response.should redirect_to(admin_organism_cashes_url(@o))
      end
    end

    describe "with invalid params" do
      it "assigns the @ca as @@ca" do
        @a.stub(:find).with(@ca.id.to_s).and_return @ca
        @ca.stub(:update_attributes).and_return false
        put :update, {:organism_id=>@o.id.to_s, :id => @ca.id.to_s, :cash => {}}, valid_session
        assigns(:cash).should eq(@ca)
      end

      it "re-renders the 'edit' template" do
        @a.stub(:find).with(@ca.id.to_s).and_return @ca
        @ca.stub(:update_attributes).and_return false
        Cash.any_instance.stub(:save).and_return(false)
        put :update,{:organism_id=>@o.id.to_s,  :id => @ca.id.to_s, :cash => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested @ca" do
      @a.stub(:find).with(@ca.id.to_s).and_return @ca
      @ca.should_receive(:destroy)
      delete :destroy,{:organism_id=>@o.id.to_s,  :id => @ca.id}, valid_session
      
    end 

    it "redirects to the cashes list" do
      @a.stub(:find).with(@ca.id.to_s).and_return @ca
      @ca.should_receive(:destroy)
      delete :destroy,{:organism_id=>@o.id.to_s,  :id => @ca.id}, valid_session
      response.should redirect_to(admin_organism_cashes_url(@o))
    end
  end 

end
