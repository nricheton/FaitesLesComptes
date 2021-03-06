require 'spec_helper'

RSpec.configure do |config|
 # config.filter = {wip:true}
end

describe Subscription do
  
  describe 'validations' do
    subject {Subscription.new(mask_id:1, title:'un abonnement', day:5, permanent:true)}
    
    before(:each) do
      subject.stub(:mask).and_return(mock_model(Mask, complete?:true))     
    end
      
    it('est valide') {subject.should be_valid}  
  
    describe 'invalide' do
    
      it 'sans le jour' do
        subject.day = nil
        subject.should_not be_valid
      end
    
      it 'ni le mask_id' do
        subject.mask_id = nil
        subject.should_not be_valid
      end
    
      it 'ni le title' do
        subject.title = nil
        subject.should_not be_valid
      end
      
      it 'si le titre comprend des caractères invalides' do
        subject.title = 'Bonds? oir'
        subject.should_not be_valid
      end
      
      it 'si le masque n est pas complet' do
        subject.stub(:mask).and_return(mock_model(Mask, complete?:false))
        subject.should_not be_valid
      end
    
    end
  
  end
  
  describe 'before_validation' do
    
    subject {Subscription.new(:end_date=>Date.today, permanent:true, day:5, title:'  avec des espaces  ')}
    
    before(:each) {subject.stub(:mask_complete?).and_return true }
    
    describe 'prepare_params' do     
      
      it 'une souscription permanente a son end_date mise à nil' do
        subject.valid?
        subject.end_date.should be_nil
      end
      
      it 'une non permanente complète son end_date avec le day' do
        subject.permanent = false
        subject.valid?
        subject.end_date.day.should == 5
      end
      
    end
    
    describe 'strip_title' do
      
      it 'enlève les blancs inutiles' do
        subject.valid?
        subject.title.should == 'avec des espaces'
      end
      
    end
    
  end
  
  
  describe 'writings_late', wip:true do
    
    before(:each) do
      tdy = Date.today.beginning_of_month
      Date.stub(:today).and_return(tdy+5.days) # pour considérer qu'on est le 5 du 
      # mois courant
    end
     
    # une souscription qui a lieu le 2
    subject {Subscription.new(title:'test de scubscription', mask_id:1, day:2, permanent:true)}
    
    it 'doit chercher la dernière écriture pour ce mask' do
      subject.should_receive(:last_writing_date).and_return(Date.today.months_ago(1).beginning_of_month + 2.days)
      subject.nb_late_writings
    end
    
    describe 'nbre écritures en retard' do
    
      it '1 si debut du même mois' do
        subject.stub(:last_writing_date).and_return(Date.today.months_ago(1).beginning_of_month)  
        subject.nb_late_writings.should == 1
      end
    
      it '0 si le bon jour du même mois' do
        subject.stub(:last_writing_date).and_return(Date.today.beginning_of_month + 4.days)
        subject.nb_late_writings.should == 0
      end
    
      it '4 si il y a 4 mois de retard' do
        subject.stub(:last_writing_date).and_return(Date.today.months_ago(1).beginning_of_month.months_ago(3))
        subject.nb_late_writings.should == 4
      end
      
      context 'pas encore d écritures pour ce masque' do
        
        before(:each) do
          subject.stub(:mask).and_return mock_model(Mask, :writings=>nil, created_at:Date.today << 3)
        end
        
        it 'part de la date du mask' do
          subject.nb_late_writings.should == 4 # 3 mois plus tôt plus le mois en cours
        end
        
      end
    end
    
    
    
    context 'le jour est le dernier du mois' do
      
      subject {Subscription.new(title:'test de subscription', mask_id:1, day:31)}
      
      
    
      it '1 si la dernière écriture est le dernier jour du mois précédent' do
         Date.stub(:today).and_return Date.civil(2013, 9, 30)
         Date.stub(:current).and_return Date.today
         subject.stub(:last_writing_date).and_return Date.civil(2013, 8, 31)
         subject.nb_late_writings.should == 1 
      end
      
      it 'pour février' , wip:true do
         Date.stub(:today).and_return Date.civil(2013, 4, 10)
         Date.stub(:current).and_return Date.civil(2013, 4, 10) # car Rails utilise current
         
         subject.stub(:last_writing_date).and_return Date.civil(2013, 2, 28)
         subject.nb_late_writings.should == 1 
      end
      
      
    end
    
    context 'la subscription a une échéance' do
      
      subject {Subscription.new(day:5, end_date:Date.civil(2014, 3,12))}
            
      it '1 si on est au début de 2014' do
        Date.stub(:today).and_return Date.civil(2014,1,1)
        Date.stub(:current).and_return Date.today
        subject.stub(:last_writing_date).and_return Date.civil(2013, 11, 30)
        subject.nb_late_writings.should == 1
      end
      
      it 'zero si la date est passée' do
        Date.stub(:today).and_return Date.civil(2014,12,1)
        Date.stub(:current).and_return Date.today
        subject.stub(:last_writing_date).and_return Date.civil(2014, 3, 5) # donc la dernière écriture a été passé
        subject.nb_late_writings.should == 0
      end
      
      
    end
    
    
    
  end
  
  describe 'first_to_write' do
    
    let(:my) {MonthYear.from_date(Date.today)}
    
    it 'appelle month_year_to_write' do
      subject.should_receive(:month_year_to_write).at_least(1).times.and_return(my..my)
      subject.first_to_write
    end
    
    it 'renvoie nil si month_year_to_write a une taille négativevide' do
      subject.stub(:month_year_to_write).and_return(my..my.previous_month)
      subject.first_to_write.should == nil
    end
    
    it 'renvoie le premier mois autrement' do
      subject.stub(:month_year_to_write).and_return(MonthYear.from_date(Date.today.years_ago(1))..my)
      subject.first_to_write.should == MonthYear.from_date(Date.today.years_ago(1))
    end
     
    
    
  end
  
  describe 'pass_writing' do
    
    subject {Subscription.new(day:5)}
    
    before(:each) do
      subject.stub(:mask_complete?).and_return true
      subject.stub(:late?).and_return true
      subject.stub(:month_year_to_write).
        and_return(@lms = MonthYear.from_date(Date.today.months_ago(2))..MonthYear.from_date(Date.today.months_ago(1)))
      subject.stub(:writer).and_return(@writer =  Struct.new(:write))
    end
    
    it 'passe les écritures' do
      @lms.each {|lm| @writer.should_receive(:write).with(subject.send(:subscription_date, lm)) } 
      subject.pass_writings 
    end  
    
    it 'sauf si le mask est incomplet' do
      subject.stub(:mask_complete?).and_return false
       @lms.each {|lm| subject.send(:writer).should_not_receive(:write) } 
      subject.pass_writings
    end
    
    
  end
  
end
