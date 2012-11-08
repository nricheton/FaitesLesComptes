# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
load 'pdf_document/default.rb'
require 'pdf_document/page'

RSpec.configure do |c|
 # c.filter = {wip:true}
end

describe PdfDocument::Default do

  let(:o) {mock_model(Organism, title:'Organisme test')}
  let(:p) {mock_model(Period, organism:o,
      start_date:Date.today.beginning_of_year,
      close_date:Date.today.end_of_year,
      exercice:'Exercice 2012')}

  def valid_options
    {
      title:'PDF Document' ,
      subtitle:'Le sous titre',
      :select_method=>'compta_lines'
    }
  end

  context 'minimal_options et pas encore de source' do 

    before(:each) do
      @Default = PdfDocument::Default.new(p, nil, valid_options)
    end

    it "should exists" do
      @Default.should be_an_instance_of (PdfDocument::Default)
    end

    it 'respond_to title' do
      @Default.title.should == 'PDF Document'
    end

    it 'respond to sub_title' do
      @Default.subtitle.should == 'Le sous titre'
    end

    it 'respond to organism_name' do
      @Default.organism_name.should == 'Organisme test'
    end

    it 'respond to exercice' do
      @Default.exercice.should == 'Exercice 2012'
    end

    # le _ ci dessous symbolise un espace
    it 'give the time of creation au format 25 juillet 2012 07:54:14 ou _3 août..' do
      @Default.created_at.should match(/^(\s\d|\d{2})\s(\w|é|û)*\s\d{4}\s\d{2}:\d{2}:\d{2}$/)
    end

    it 'default from_date and to_date are from period' do
      @Default.from_date.should == p.start_date
      @Default.to_date.should == p.close_date
    end

    it 'has a default value nb_lines_per_page' do
      @Default.nb_lines_per_page.should == 22
    end





    describe 'validations' do
      it 'should have a title' do
        @Default.title =  nil
        @Default.should_not be_valid
      end

      it 'should have a select_method' do
        @Default.select_method =  nil
        @Default.should_not be_valid
      end
    end


  end

  context 'options complémentaires' do
    it 'accepts options from_date' do
      h = valid_options.merge({:from_date=>Date.today.beginning_of_month})
      @Default = PdfDocument::Default.new(p, nil, h)
      @Default.from_date.should == Date.today.beginning_of_month
    end

    it 'accepts options to_date' do
      h = valid_options.merge({:to_date=>Date.today.end_of_month})
      @Default = PdfDocument::Default.new(p,nil, h)
      @Default.to_date.should == Date.today.end_of_month
    end

    it 'accepts options nb_lines_per_page' do
      h = valid_options.merge({:nb_lines_per_page=>30})
      @Default = PdfDocument::Default.new(p,nil, h)
      @Default.nb_lines_per_page.should == 30
    end

     describe 'stamp' do
      it 'has a nil default stamp' do
        @Default = PdfDocument::Default.new(p,nil, {})
        @Default.stamp.should == nil
      end

      it 'une option peut permettre de préciser le stamp' do
        pdf = PdfDocument::Default.new(p, nil, valid_options.merge(stamp:'Provisoire'))
        pdf.stamp.should == 'Provisoire' 
      end
    end
  end

  context 'un listing sans ligne' do
    load 'lib/pdf_document/table.rb'
    let(:arel) {double(Arel, first:nil)}
    let(:source) {mock_model(Account, title:'Achats', number:'60',
        compta_lines:arel )}

    before(:each) do
      @Default = PdfDocument::Default.new(p, source, valid_options)
      @Default.set_columns  %w(writings.date writings.ref nature_id destination_id debit credit)
      @Default.set_columns_to_totalize [4,5]
    end

    it 'a quand même une page' do
      arel.stub_chain(:range_date, :count).and_return 0
      @Default.nb_pages.should == 1
    end

    it 'avec un total de 0', wip:true do
     arel.stub_chain(:joins).and_return arel
     arel.stub_chain(:select, :range_date, :offset, :limit).and_return nil
      @Default.stub(:nb_pages).and_return 1
      @Default.page(1).table_total_line.should == ['Totaux', '0.00', '0.00'] 
      @Default.page(1).table_to_report_line.should == ['Total général', '0.00', '0.00']
    end
  end

 
  context 'création des pages' do

    let(:arel) {double(Arel,  first:mock_model(ComptaLine))}
    let(:source) {mock_model(Account, title:'Achats', number:'60',
        compta_lines:arel )}

    before(:each) do
      arel.stub_chain(:range_date, :count).and_return 100
      @Default = PdfDocument::Default.new(p, source, valid_options)
    end

    it 'connaît son nombre de pages' do
      @Default.nb_pages.should == 5
    end

    it 'est capable de fournir une page pour le nb_pages' do
      1.upto(@Default.nb_pages) do |i|
        @Default.page(i).should be_an_instance_of PdfDocument::Page
      end
    end

    it 'appelé une page hors limite déclenche une erreur' do
      expect {@Default.page(6)}.to raise_error ArgumentError
      expect {@Default.page(0)}.to raise_error ArgumentError
    end

   



    it 'un doc doit pouvoir énumérer ses pages'

    it 'default select_method' do
      @Default.select_method.should == 'compta_lines'
    end

    it 'raise error si source ne repond pas à select method'

    it 'on peut modifier la select_method = ' do
      @Default.select_method = :autre
      @Default.select_method.should == :autre
    end

    # TODO ici on fait lines mais on devrait s'appuyer sur select_method
    it 'Par défaut les colonnes demandées sont celle de la classe retournée par select_method' do
      @Default.columns.should == ComptaLine.column_names
    end

    it 'on peut sélectionner les colonnes' do
      @Default.set_columns   %w(line_date ref nature_id destination_id debit credit)
      @Default.columns.should == %w(line_date ref nature_id destination_id debit credit)
    end

    it 'choisir des colonnes crée un tableau des alignements' do
      @Default.set_columns   %w(line_date ref nature_id destination_id debit credit)
      @Default.columns_alignements.should == [:left, :left,:left,:left,:right, :right]
    end

   
    describe 'les méthodes sur les colonnes' do
      it 'par défaut les colonnes utilisent le nom de la colonne' do 
        @Default.columns_methods.should == @Default.columns
      end

      it 'mais on peut définir d autres méthodes' do
        @Default.set_columns   %w(line_date ref nature_id destination_id debit credit)
        @Default.set_columns_methods([nil, nil, 'nature.name','destination.name', 'debit.to_f',nil])
        @Default.columns_methods.should == ['line_date','ref', 'nature.name','destination.name', 'debit.to_f', 'credit']
      end

      it 'raise error si columns_methods n est pas de la bonne taille'

    end

    describe 'les largeurs de colonnes' do

      before(:each) do
        @Default.set_columns   %w(line_date ref nature_id destination_id debit credit)
      end

      it 'on a une largeur de colonnes par défaut' do
        @Default.columns_widths.should == 6.times.collect {|t| 100.0/6 }
      end

      it 'on peut imposer les 6 colonnes' do
        @Default.set_columns_widths([10,20,30,10,15,15])
        @Default.columns_widths.should == [10,20,30,10,15,15]
      end

      it 'on peut n imposer que les 4 premières' do
        @Default.set_columns_widths([10,20,30,10])
        @Default.columns_widths.should == [10,20,30,10,15,15]
      end

      it 'gestion des erreurs des size'

    end

    

    describe 'gestion des totaux' do

      before(:each) do
        @Default.set_columns  %w(line_date ref nature_id destination_id debit credit)
        @Default.set_columns_widths([10,20,30,10])
      end

      it 'set avec un array vide génère une erreur' do
        expect { @Default.set_columns_to_totalize []}.to raise_error 'Le tableau des colonnes ne peut être vide'
      end

      it 'définir les colonnes permet de définir les largeurs' do
        bcw4 = @Default.columns_widths[4]
        bcw5 = @Default.columns_widths[5]
        @Default.set_columns_to_totalize [4,5]
        @Default.total_columns_widths.should == [100 - bcw4 - bcw5, bcw4, bcw5 ]
      end

      it 'définir une colonne qui n est pas la dernière' do
        bcw4 = @Default.columns_widths[4]
        bcw5 = @Default.columns_widths[5]
        @Default.set_columns_to_totalize [4]
        @Default.total_columns_widths.should == [100 - bcw4 - bcw5, bcw4 ]
      end

      it 'peut fixer la première ligne de report' do
        @Default.first_report_line = ['Soldes', 100, 20]
        @Default.first_report_line.should ==  ['Soldes', 100, 20]
      end

      it 'gestion des totaux de la page' do
        pending 'voir si fait dans la classe page'
      end

    end

    it 'peut créer un fichier pdf' do
      @Default.should respond_to(:render)
    end

    # l'action de render est testée dans la un spec de vue
  end



  
end
