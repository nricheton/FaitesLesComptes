# coding: utf-8

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

RSpec.configure do |config|  
  #  config.filter =  {wip:true}
end


describe Account do   
  include OrganismFixtureBis  
  
  def valid_attributes
    {number:'6011',
      title:'Titre du compte',
    }
  end
  
  def valid_account
    acc = Account.new(valid_attributes)
    acc.period_id = 1
    acc
  end
   

  describe 'validations' do
      
    subject {valid_account}
      
    it "should be valid"  do
      subject.should be_valid
    end

    describe 'should not be valid' do

      it 'sans number' do
        subject.number = nil
        subject.should_not be_valid
      end

      it 'sans title' do
        subject.title =  nil
        subject.should_not be_valid
      end

      it 'sans exercice' do
        subject.period = nil
        subject.should_not be_valid
      end
        
      it 'non valide si exercice clos' do
        subject.stub(:period).and_return(mock_model(Period, open:false))
        subject.should_not be_valid     
      end
    end
      
    
  end
  
  context  'méthode de classe' do

      describe 'available' do

        it 'retourne 5301 si c est la première caisse' do
           Account.stub_chain(:where, :order).and_return(@ar = double(Arel))
          @ar.stub_chain(:last).and_return nil
          Account.available('53').should == '5301'
        end

        it 'sait incrémenter les numéros' do
           Account.stub_chain(:where, :order).and_return(@ar = double(Arel))
          @ar.stub_chain(:last, :number).and_return '5301'
          Account.available('53').should == '5302'
        end
        
        it 'y compris le passage des dizaines' do
           Account.stub_chain(:where, :order).and_return(@ar = double(Arel))
          @ar.stub_chain(:last, :number).and_return '5329'
          Account.available('53').should == '5330'
        end
        
        it 'bloque à 99' do
          Account.stub_chain(:where, :order).and_return(@ar = double(Arel))
          @ar.stub_chain(:last, :number).and_return '5399'
          expect {Account.available('53')}.to raise_error(RangeError)
        end
      end
    end

 
  context 'avec un organisme' do
    
    def new_with_real_attributes
        acc = Account.new(valid_attributes)
        acc.period_id = @p.id
        acc
      end

    before(:each) do
      use_test_organism 
    end
    
    after(:each) do
      Writing.delete_all
    end
  
    describe 'solde initial', wip:true do

      before(:each) do
        @acc1 = @p.accounts.first
      end
      
      
      it 'sans exercice précédent, et sans report à nouveau, zero' do
        @acc1.init_sold_debit.should == 0
        @acc1.init_sold_credit.should == 0
      end
      
      it 'même avec une écriture dans l exercice' do
        odw = @od.writings.new(date:@p.start_date, narration:'ecriture d od',
          :compta_lines_attributes=>{'0'=>{account_id:@acc1.id, credit:1000},
            '1'=>{account_id:@baca.id, debit:1000}})
        puts odw.errors.messages unless odw.valid?
        odw.save!
      end
    
      context 'avec report à nouveau' do
      
      
        before(:each) do
          @o.an_book.writings.create!(date:Date.today.beginning_of_year, narration:'ecriture d an',
            :compta_lines_attributes=>{'0'=>{account_id:@acc1.id, credit:66},
              '1'=>{account_id:@baca.id, debit:66}})
        end

        it 'sans exercice précédent et avec RAN, donne ce montant' do
          @acc1.init_sold_debit.should == 0
          @acc1.init_sold_credit.should == 66
        end

        it 'donne un an_sold' do 
          @acc1.init_sold('debit').should == 0
          @acc1.init_sold('credit').should == 66
        end


    

        context 'avec exercice précédent clos' do

          before(:each) do
            eve = @p.start_date - 1
            @p.stub(:previous_period?).and_return true
            Period.any_instance.stub(:previous_period).and_return @pp = mock_model(Period, close_date:eve, closed?:true)
            Period.any_instance.stub(:previous_period_open?).and_return false
            @pp.stub(:accounts).and_return @arel = double(Arel)

          end

          it 'avec exercice précédent clos, prend le report à nouveau' do
            @acc1.init_sold_debit.should == 0
            @acc1.init_sold_credit.should == 66
          end




        end

      end
    
     
  
    end

    describe 'solde final' do
      
      before(:each) do
        @acc1 = @p.accounts.first
      end
      
      it 'final_sold' do
        @acc1.should_receive(:sold_at).with(@p.close_date).and_return(1000)
        @acc1.final_sold
      end

    end

    describe 'solde précédent'  do
      before(:each) do
        @acc1 = Account.new(number:'100', title:'Capital')
        @acc1.stub(:period).and_return @p
      end

      it 'previous_sold demande à period le compte' do
        @p.should_receive(:previous_account).with(@acc1).at_least(1).times.and_return(mock_model(Account, :final_sold=>105))
        @acc1.previous_sold.should == 105
      end

   

    end



   
   
    describe 'polymorphic' do
      it 'la création d\'une banque entraîne celle d\'un compte' do
        @ba.should have(1).accounts
      end

      it 'la création d\'une caisse entraîne celle d\'un compte' do
        @c.accounts.length.should == 1
      end
    end



    describe 'all_lines_locked?' do
      
      

      it 'vrai si pas de lignes' do
        new_with_real_attributes.should be_all_lines_locked
      end

      context 'avec des lignes'  do
    
        before(:each) do
          @w1 = create_outcome_writing(97)
          @w2 = create_outcome_writing(3)
          @ac = @w1.compta_lines.first.account
        end
        
        it 'faux si plusieurs lignes ne sont pas verrouillées' do
          @ac.should_not be_all_lines_locked
        end
    
        it 'faux si une ligne est non verrouillée' do
          @w1.lock
          @ac.should_not be_all_lines_locked
        end

        it 'true si toutes les lignes sont locked' do
          @w1.lock
          @w2.lock
          @ac.should be_all_lines_locked
        end
      end

    end

   
    describe 'to_pdf' do
      it 'on peut créer un listing' do
        # Account.create!(valid_attributes)
        Account.to_pdf(@p).should be_a_instance_of(PdfDocument::Simple)
      end
      
      it 'et le rendre' do
        Account.to_pdf(@p).render
      end
    end

    describe 'classe' do
      it 'un compte connait sa classe comptable' do
        @account = new_with_real_attributes
        @account.classe.should == '6'
      end
    end


    

  end

  
end 

