# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

RSpec.configure do |config|
   # config.filter = {wip:true}
end

describe Compta::WritingsController do
  include SpecControllerHelper  

  before(:each) do
    minimal_instances 
    @my = MonthYear.from_date(Date.today)
    @p.stub(:all_natures_linked_to_account?).and_return true
    @p.stub(:guess_month).and_return(MonthYear.from_date(Date.today))
    @b = mock_model(Book, type:'IncomeBook')
    Book.stub(:find).and_return(@b)
  end

 
  describe "GET index"  do
    it "assigns all writings as @writings" do
      Extract::Book.should_receive(:new).with(@b, @p, @p.start_date, @p.close_date).and_return @a = double(Arel)
      @a.should_receive(:writings).and_return(@a)
            
      get :index, {book_id:@b.id, mois:'tous' }, valid_session
      assigns(:writings).should == @a
    end

    it 'quand le book-type est AnBook, c est tous par defaut' do
      @b.stub(:type).and_return 'AnBook'
      Extract::ComptaBook.any_instance.stub(:writings).and_return 'bonjour'
      get :index, {book_id:@b.id  }, valid_session
      assigns(:mois).should == 'tous'
      assigns[:an].should == nil
    end

    it 'sans params et pas d AnBook, redirige' do
       get :index, {book_id:@b.id  }, valid_session
       response.should redirect_to(compta_book_writings_url(@b, :mois=>@my.month, :an=>@my.year))
    end

    it 'avec params mois et an, wherche les writings du mois' do
      Extract::ComptaBook.should_receive(:new).with(@b, @p, Date.today.beginning_of_month, Date.today.end_of_month).and_return @a = double(Arel)
      @a.should_receive(:writings).and_return(@a)
      get :index, {book_id:@b.id,  an:Date.today.year, mois:Date.today.month}, valid_session
    end

  end

  

  describe "GET new"  do
    
    it "assigns a new writing as @writing" do
      @b.stub_chain(:writings, :new).and_return(Writing.new)
      get :new, {book_id:@b.to_param}, valid_session
      assigns(:book).should == @b
      assigns(:writing).should be_a_new(Writing)
    end

    it 'avec un flash cherche l ecriture' do
      @b.stub_chain(:writings, :new).and_return(Writing.new)
      Writing.should_receive(:find_by_id).with(10)
      get :new, {book_id:@b.to_param}, valid_session, {:previous_writing_id=>10} # envoi du flash
    end
  end

  describe "GET edit" do
    it "assigns the requested writing as @writing" do
      writing = mock_model(Writing)
      Writing.should_receive(:find).with(writing.to_param).and_return writing
      get :edit, {book_id:@b.id, :id => writing.to_param}, valid_session
      assigns(:writing).should eq(writing)
    end
  end

  describe "POST create"  do
    
    before(:each) do
      @controller.stub(:fill_author)
      @r = mock_model(Writing)
      @b.stub(:writings).and_return @a = double(Arel)
    end

   
    describe "with valid params"  do

      before(:each) do
        @a.stub(:new).with({'date_picker'=>(I18n::l Date.today.beginning_of_year)}).and_return @r
      end

      it "assigns a newly created writing as @writing" do
        @r.stub(:save).and_return(true)
        post :create, {book_id:@b.to_param, :writing => {} }, valid_session
        assigns(:writing).should be_a(Writing)
      end
      
      it 'appelle fill_author' do
        @r.stub(:save).and_return(@r)
        @controller.should_receive(:fill_author).with(@r)
        post :create, {book_id:@b.to_param, :writing => {} }, valid_session
      end

      it "redirects to the form new" do
        @r.stub(:save).and_return(@r)
        post :create, {book_id:@b.to_param, :writing => {} }, valid_session
        response.should redirect_to new_compta_book_writing_url(@b)
      end

      it 'mais redirige vers la vue index si book est A Nouveau' do
        @b.stub(:type).and_return('AnBook')
        @r.stub(:save).and_return(true)
        post :create, {book_id:@b.to_param, :writing => {} }, valid_session
        response.should redirect_to compta_book_writings_url(@b)
      end
    end

    describe "with invalid params"   do
      before(:each) do
        @a.stub(:new).and_return @r
      end

      it "assigns a newly created but unsaved writing as @writing" do
        # Trigger the behavior that occurs when invalid params are submitted
        @r.stub(:save).and_return(false)
        post :create, {book_id:@b.id, :writing => {}}, valid_session
        assigns(:writing).should == @r
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
       @r.stub(:save).and_return(false)
        post :create, {book_id:@b.id, :writing => {}}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do

    before(:each) do
      @w = mock_model(Writing, :date=>Date.today).as_null_object
      @va = {id:@w.id, book_id:@b.id, date:Date.today, narration:'Ecriture', :compta_lines_attributes=>{'0'=>{account_id:1, debit:100, credit:0},
          '1'=>{account_id:2, debit:0, credit:100}} }
      Writing.stub(:find).with(@w.to_param).and_return @w
      @controller.stub(:fill_author)
    end

    describe "with valid params" do
      it "updates the requested writing" do
     
        # Assuming there are no other writings in the database, this
        # specifies that the Writing created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        @w.should_receive(:update_attributes).with({'these' => 'params'}).and_return @w
        put :update, {book_id:@b.id, :id => @w.to_param, :writing => {'these' => 'params'}}, valid_session
      end
      
      it 'appelle fill_author' do
        @controller.should_receive(:fill_author).with(@w)
        put :update, {book_id:@b.id, :id => @w.to_param, :writing => {'these' => 'params'}}, valid_session
      end

      it "assigns the requested writing as @writing" do
        
        put :update, {book_id:@b.id, :id => @w.to_param, :writing => {'these' => 'params'}}, valid_session
        assigns(:writing).should eq(@w)
      end

      it "redirects to the writing" do
        @w.stub(:update_attributes).and_return true
        put :update, {book_id:@b.id,  :id => @w.to_param, :writing => @va}, valid_session
        response.should redirect_to compta_book_writings_url(@b, :an=>@my.year, :mois=>@my.month)
      end
    end

    describe "with invalid params"  do
      it "assigns the writing as @writing" do
        
        # Trigger the behavior that occurs when invalid params are submitted
        @w.stub(:update_attributes).and_return false
        put :update, {book_id:@b.id, :id => @w.to_param, :writing => {}}, valid_session
        assigns(:writing).should eq(@w)
      end

      it "re-renders the 'edit' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        @w.stub(:update_attributes).and_return false
        put :update, {book_id:@b.id, :id => @w.to_param, :writing => {}}, valid_session
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    
    before(:each) do
     
      @w = mock_model(Writing, :date=>Date.today)
      Writing.stub(:find).and_return(@w)
    end


    it "destroys the requested writing" do
      @w.should_receive(:destroy).and_return true
      delete :destroy, {book_id:@b.to_param, :id => @w.to_param}, valid_session
    end

    it "redirects to the writings list" do
      @w.stub(:destroy).and_return true
      delete :destroy, {book_id:@b.to_param, :id => @w.to_param}, valid_session
      response.should redirect_to(compta_book_writings_url(@b, :an=>@my.year, :mois=>@my.month ))
    end
  end


  describe 'POST lock' do

    before(:each) do

      @w = mock_model(Writing, :date=>Date.today)
      Writing.stub(:find).and_return(@w)
    end

    it 'envoie lock à l ecriture' do
    @w.should_receive(:lock)
    post :lock, {book_id:@b.to_param, :id=>@w.to_param, :mois=>@my.month, :an=>@my.year}, valid_session
    response.should redirect_to(compta_book_writings_url(@b, :an=>@my.year, :mois=>@my.month ))
  end
  end

  describe 'POST all_lock' do
    before(:each) do
      @w = mock_model(Writing, :date=>Date.today)
      Writing.stub(:find).and_return(@w)
    end

    it 'envoie lock à toutes les écritures non verrouillées' do
      Extract::ComptaBook.any_instance.stub(:writings).and_return(@ar = double(Arel))
      @ar.should_receive(:unlocked).and_return([double(:lock=>true, 'compta_editable?'=>true),double(:lock=>true, 'compta_editable?'=>true) ])
      post :all_lock, {book_id:@b.to_param}, valid_session
      response.should redirect_to compta_book_writings_url(@b)
    end
  end
  
  describe 'production du pdf', wip:true do
    
    def pdf_attributes
      {book_id:@b.to_param, an:Date.today.year.to_s, mois:Date.today.month.to_s} 
    end
    
    def merged_attributes
      {period_id:@p.id,
        from_date:Date.today.beginning_of_month, to_date:Date.today.end_of_month }
    end
    
       
    describe 'produce_pdf' do
      
      it 'lance la production du pdf' do 
        @b.stub(:export_pdf).and_return(mock_model(ExportPdf, status:'mon statut'))
        @b.stub(:create_export_pdf).and_return(mock_model(ExportPdf, status:'mon statut'))
        Jobs::ComptaBookPdfFiller.stub(:new).and_return double(Object, perform:'delayed_job')
        get :produce_pdf, pdf_attributes.merge({format:'js'}), session_attributes 
      end
      
      it 'en le mettant dans la queue' do
        @b.stub(:export_pdf)
        @b.stub(:create_export_pdf).and_return(@expdf =  mock_model(ExportPdf, status:'new'))
        Jobs::ComptaBookPdfFiller.should_receive(:new).
          with(@o.database_name, @expdf.id, merged_attributes).and_return(@gb_filler = double(Jobs::GeneralBookPdfFiller))
        Delayed::Job.should_receive(:enqueue).with @gb_filler
        get :produce_pdf, pdf_attributes.merge(format:'js'), session_attributes
      end
      
    end

    describe 'pdf_ready' do 
      it 'interroge si prêt' do
        @b.stub(:export_pdf).and_return(mock_model(ExportPdf, status:'mon statut'))
        get :pdf_ready, {:book_id=>@b.to_param, format:'js'}, session_attributes
        response.body.should == 'mon statut' 
      end
    end
   
  
    describe 'GET deliver_pdf' do 
      it 'rend le fichier' do
        @b.should_receive(:export_pdf).and_return(mock_model(ExportPdf, status:'ready'))
        get :deliver_pdf, {:book_id=>@b.to_param, format:'js'}, session_attributes
        response.content_type.should == "application/pdf" 
      end
    end
  
  end


end
