# coding: utf-8

require 'spec_helper'



describe SubscriptionsHelper do
  include ApplicationHelper

  subject {Subscription.new(title:'Un abonnement')}
  
  
  describe 'sub_infos' do
    
    subject {mock_model(Subscription, title:'Un abonnement')}
    
    it 'renvoie rien si la sub est à jour' do
      subject.stub(:late?).and_return false
      sub_infos(subject).should == nil
    end
    
    context 'la subscription est en retard' do
      
      
      
      before(:each) do 
        d = Date.civil(2013, 12, 25)
        subject.stub(:late?).and_return true 
        subject.stub(:first_to_write).and_return(MonthYear.from_date(d.months_ago(3)))
        
      end
      
      it 'renvoie un hash' do
        sub_infos(subject).should be_an_instance_of(Hash)
      end
      
      it 'la cle text' do
        sub_infos(subject)[:text].should == "L'écriture périodique 'Un abonnement' a des écritures à passer à partir de septembre 2013"
      end
      
      it 'la clé icon renvoie sur l action' do 
        sub_infos(subject)[:icon].should == icon_to( 'nouveau.png', subscription_path(subject), method: :post)
      end
      
    end
    
    
  end
  

end
