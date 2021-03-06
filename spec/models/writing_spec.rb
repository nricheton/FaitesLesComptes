# coding: utf-8

require 'spec_helper'

RSpec.configure do |config| 
  # config.filter = {wip:true} 
end

describe Writing do
  include OrganismFixtureBis

  describe 'with stub models' do

    before(:each) do  
      @o = stub_model(Organism)
      @p = stub_model(Period, start_date:Date.today.beginning_of_year, close_date:Date.today.end_of_year)
      @b = stub_model(Book, :organism=>@o, :type=>'IncomeBook')
      @o.stub(:find_period).and_return @p
      Writing.any_instance.stub_chain(:compta_lines, :size).and_return 2
      Writing.any_instance.stub(:complete_lines).and_return true
    end

    def valid_parameters
      {narration:'Première écriture', date:Date.today}
    end

  

    describe 'presence validator' do

      before(:each) do
        Writing.any_instance.stub(:total_credit).and_return 10
        Writing.any_instance.stub(:total_debit).and_return 10
        Writing.any_instance.stub(:book).and_return @b
        Writing.any_instance.stub_chain(:compta_lines, :each).and_return nil
        Writing.any_instance.stub(:period).and_return @p
       
      end

      it 'champs obligatoires' do
        @w = @b.writings.new(valid_parameters)
        @w.should be_valid
        [:narration, :date, :book_id].each do |field|
          f_eq = (field.to_s + '=').to_sym
          @w = Writing.new(valid_parameters)
          @w.send(f_eq, nil)
          @w.should_not be_valid, "Paramètres obligatoire manquant : #{field}"
        end
      end
    end


    describe 'other validators' do

      before(:each) do
        @w = @b.writings.new(valid_parameters)
        Writing.any_instance.stub(:book).and_return @b
        Writing.any_instance.stub(:total_credit).and_return 10
        Writing.any_instance.stub(:total_debit).and_return 10
        Writing.any_instance.stub_chain(:compta_lines, :each).and_return nil
      end

      it 'doit être valide' do
        @w.valid?
        @w.should be_valid
      end

      it 'non valide si déséquilibrée' do
        @w.stub(:total_debit).and_return(10)
        @w.stub(:total_credit).and_return(20)
        @w.should_not be_valid
      end

      it 'et valide si équilibrée' do
        @w.stub(:total_debit).and_return(10)
        @w.stub(:total_credit).and_return(10)
        @w.should be_valid
      end
      
      describe 'period_start_date_validator' do
        
        before(:each) {@b.stub(:type).and_return('AnBook')}
        
        it 'est valide si la date doit être le premier jour de l exercice' do
          @w.date = @p.start_date
          @w.should be_valid
        end
        
        it 'mais invalide autrement' do
          @w.date = @p.start_date + 1
          @w.should_not be_valid
        end
        
      end

      describe 'test des compta_lines' do

        it 'doit avoir au moins deux lignes' do
          @w.stub(:compta_lines).and_return([mock_model(ComptaLine, nature:mock_model(Nature, period:@p), account:mock_model(Account, period:@p))])
          @w.should_not be_valid
        end

        it 'la date doit être dans l exercice' do
          @o.should_receive(:find_period).with(@w.date).and_return nil
          @w.should_not be_valid
        end

        it 'valide si les natures sont dans l exercice' do
          @w.stub(:compta_lines).and_return([mock_model(ComptaLine, nature:mock_model(Nature, period:@p), account:mock_model(Account, period:@p)),
              mock_model(ComptaLine, nature:nil, account:mock_model(Account, period:@p))])
          @w.should be_valid
        end

        it 'et invalide dans le cas contraire' do
          @w.stub(:compta_lines).and_return([mock_model(ComptaLine, nature:mock_model(Nature, period:mock_model(Period)), account:mock_model(Account, period:@p)),
              mock_model(ComptaLine, nature:nil, account:mock_model(Account, period:@p))])
          @w.should_not be_valid
          @w.errors[:date].should == ['Incohérent avec Nature']
        end


        it 'invalide si les comptes ne sont pas dans l exercice' do
          @w.stub(:compta_lines).and_return([mock_model(ComptaLine, nature:mock_model(Nature, period:@p), account:mock_model(Account, period:mock_model(Period))),
              mock_model(ComptaLine, nature:nil, account:mock_model(Account, period:@p))])
          @w.should_not be_valid
          @w.errors[:date].should == ['Incohérent avec Compte']
        end

      end

    end

  end

  context 'with real models' do

    describe 'save' , wip:true do

      before(:each) do
        use_test_organism
        @l1 = ComptaLine.new(account_id:@p.accounts.first.id, debit:0, credit:10)
        @l2 = ComptaLine.new(account_id:@p.accounts.last.id, debit:10, credit:0)
        @r = @od.writings.new(date:Date.today, narration:'Une écriture')
        @r.compta_lines<< @l1
        @r.compta_lines<< @l2
      end
      
      after(:each) do
        Writing.delete_all
      end
      
      it 'should save' do
        puts @r.errors.messages unless @r.valid?
        @r.should be_valid
        expect {@r.save}.to change {Writing.count}.by(1)
      end

      it 'should save the lines' do
        expect {@r.save}.to change {ComptaLine.count}.by(2)
      end
      
      describe 'on ne peut ecrire dans un exercice clos' do 
        before(:each) do 
          @p.stub(:open?).and_return false
          @r.stub(:period).and_return @p 
        end
        
        it 'on vérifie' do
          # @p.should be_closed
          @r.should_not be_valid
        end
      end


    end


    describe 'methods'  do

      before(:each) do
        use_test_organism
        @w = create_in_out_writing
      end
      
      after(:each) do
        Writing.delete_all
      end
      
      it 'check compta_lines' do
        @w.compta_lines.should be_an(Array)
        @w.compta_lines.first.should be_an_instance_of(ComptaLine)
      end


      it 'total_debit, renvoie le total des debits des lignes' do
        @w.total_debit.should == 99
      end

      it 'total_credit, renvoie le total des debits des lignes' do
        @w.total_credit.should == 99
      end

      it 'balanced? répond false si les deux totaux sont inégaux' do
        @w.stub(:total_debit).and_return 145
        @w.should_not be_balanced

      end

      it 'et true s ils sont égaux' do
        @w.should be_balanced
      end

      it 'locked? est faux si aucune ligne n est verrouillée' do
        @w.stub(:compta_lines).and_return(@a = double(Arel))
        @a.should_receive(:where).with('locked = ?', true).and_return @a
        @a.should_receive(:any?).and_return false
        @w.should_not be_locked
      end

      it 'locked? est vrai si une ligne est verrouillée' do
        @w.stub(:compta_lines).and_return(@a = double(Arel))
        @a.should_receive(:where).with('locked = ?', true).and_return @a
        @a.should_receive(:any?).and_return true
        @w.should be_locked

      end

      describe 'une ligne est an_editable' do

        before(:each) do
          @w.stub(:locked?).and_return false
          @w.stub(:book).and_return(mock_model(Book, :type=>'AnBook'))
          @w.stub(:type).and_return(nil)
        end

        it 'an_editable' do
          @w.an_editable?.should be_true
        end

        it 'non od_editable si locked' do
          @w.stub(:locked?).and_return(true)
          @w.an_editable?.should be_false
        end

        it 'si le livre est od_book' do
          @w.stub(:book).and_return(mock_model(Book, :type=>'IncomeBook'))
          @w.an_editable?.should be_false
        end

        it 's il y a un type' do
          @w.stub(:type).and_return 'bonjour'
          @w.an_editable?.should be_false
        end
   
      end

      describe 'une ligne est od_editable'  do

      
        # od_editable est éditable lorsqu'une ligne appartient au livre OD
        # est non verrouillée, n'est pas de type Transfer ni remise de chèques
        before(:each) do
          @w.stub(:locked?).and_return false
          @w.stub(:book).and_return(mock_model(Book, :type=>'OdBook'))
          @w.stub(:type).and_return(nil)
        end

        it 'od_editable' do
          @w.should be_od_editable
        end

        it 'non od_editable si locked' do
          @w.stub(:locked?).and_return(true)
          @w.should_not be_od_editable
        end

        it 'si le livre est od_book' do
          @w.stub(:book).and_return(mock_model(Book, :type=>'IncomeBook'))
          @w.should_not be_od_editable
        end

        it 'si le type est transfer' do
          @w.stub(:type).and_return('Transfer')
          @w.should_not be_od_editable
        end

        it 'si le type est transfer' do
          @w.stub(:type).and_return('InOutWriting')
          @w.should_not be_od_editable
        end

        it 'si le type est remise chèque' do
          @w.stub(:type).and_return('CheckDepositWriting')
          @w.should_not be_od_editable
        end


      end

      describe 'compta_editable'  do

        before(:each) do
          @w.stub(:an_editable?).and_return false
          @w.stub(:od_editable?).and_return false
        end

        it 'n est pas compta_editable' do
          @w.should_not be_compta_editable
        end

        it 'et l est si l une des conditions est remplie' do
          @w.stub(:an_editable?).and_return true
          @w.should be_compta_editable
        end

        it 'l autre condition' do
          @w.stub(:od_editable?).and_return true
          @w.should be_compta_editable
        end

      end
      
      describe 'lock'  do
                
        it 'lock doit verrouiller toutes les lignes' do
          cls = [1,2].map {|i| mock_model(ComptaLine, locked?:false) }
          @w.stub(:compta_lines).and_return(cls)
          cls.each {|cl| cl.should_receive(:send).with(:verrouillage).and_return(true)}
          @w.lock
        end
        
        it 'avant lock une écriture n a pas de numéro continu' do
          @w.continuous_id.should be_nil
        end
        
        it 'ni de locked_at' do
          @w.locked_at.should be_nil
        end
        
        it 'mais après elle a un numéro' do
          @w.lock
          @w.continuous_id.should_not be_nil
        end
        
        it 'et une date de verrouillage' do
          @w.lock
          @w.locked_at.should == Date.today
        end
        
        it 'la numérotation est continue' do
          Writing.should_receive(:last_continuous_id).and_return(100)
          @w.lock
          @w.continuous_id.should == 101
        end
        
        it 'attribuer un numéro non continu rend invalide'  do
          Writing.should_receive(:last_continuous_id).at_least(1).times.and_return(100)
          @w.continuous_id = 50
          @w.should_not be_valid 
          
        end
        
        it 'verrouiller une écriture remise de chèque doit verrouiller les chèques'
      
      end

      describe 'support' do

        it 'support_line renoie la ligne de compte 5 de contrepartie' do
          @w.support_line.account.number.should match /^5/
        end

        it 'retourne le long_name du support' do
          @w.support.should == 'Compte courant'
        end

        # TODO faire un spec de writing et un de in_out_writing correctement séparé
        it 'cas ou @w n est pas un in_out_writing' do
          w = Writing.new
          w.stub(:support_line).and_return(@sl = mock_model(ComptaLine))
          @sl.should_receive(:account).exactly(2).times.and_return(mock_model(Account, :long_name=>'le nom du compte'))
          w.support.should == 'le nom du compte'
        end


      end
      
      describe 'to_csv' do
        
        it 'peut rendre un csv' do
          pending 'voir si utile puisqu on passe par Extract'
          expect {@w.to_csv}.not_to raise_error
        end
        
      end


    end
  end

end
