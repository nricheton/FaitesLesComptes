# coding: utf-8

require 'spec_helper'

RSpec.configure do |c|
 # c.filter = {wip:true} 
end

describe Transfer  do
  include OrganismFixture

  def valid_new_transfer
    t = Transfer.new date: Date.today, narration:'test de transfert', book_id: @od.id, amount:1.5
    t.line_to.account_id = @cba.id
    t.line_from.account_id = @cbb.id 
    t
  end
 
  before(:each) do
    create_minimal_organism 
    @bb=@o.bank_accounts.create!(name: 'DebiX', number: '123Y')
    @cba = @ba.current_account @p
    @cbb = @bb.current_account @p
  end 

  
  describe 'virtual attribute pick date' do
  
    before(:each) do
      @transfer=valid_new_transfer
    end
    
    it "should store date for a valid pick_date" do
      @transfer.date_picker = '06/06/1955'
      @transfer.date.should == Date.civil(1955,6,6)
    end 

    it 'should return formatted date' do
      @transfer.date =  Date.civil(1955,6,6)
      @transfer.date_picker.should == '06/06/1955'
    end
 
  end

  describe 'line_to and line_from should respond even for not persisted model' do

    it 'return line_to for not persisted transfer' do
      @transfer = valid_new_transfer
      @transfer.line_to.should be_an_instance_of(ComptaLine)
    end

    it 'return line_to for persisted transfer' do
      @transfer = valid_new_transfer
      @transfer.save!
      t = Transfer.last
      @transfer.line_to.should == t.line_to
    end


  end


  
  describe 'validations'  do

    before(:each) do
      @transfer=valid_new_transfer
    end

    it 'should be valid with valid attributes', wip:true do
      @transfer.valid?
 #     puts @transfer.errors.messages
      @transfer.should be_valid
    end

    it 'but not without a date' do
      @transfer.date = nil
      @transfer.should_not be_valid
    end

    it 'nor with credit in line_from' do
      @transfer.line_from.credit = 0
      @transfer.should_not be_valid
    end

    it 'nor with debit in line_to' do
      @transfer.line_to.debit = 0
      @transfer.should_not be_valid
    end

    it 'nor without account' do
      @transfer.compta_lines.each do |cl|
        cl.account = nil
        @transfer.should_not be_valid
      end
    end

   it 'to_account and from_account should be different' do
      @transfer.line_from.account = @transfer.line_to.account
      @transfer.should_not be_valid
    end

  end


  describe 'errors'  do

    before(:each) do
      @tr = valid_new_transfer
    end

    it 'champ obligatoire when a required field is missing' do 
      @tr.amount = nil 
      @tr.valid?
      @tr.errors[:amount].should == ['obligatoire', 'doit être un nombre'] 
    end

    it 'montant ne peut être nul' do
      @tr.amount = 0
      @tr.valid?
      @tr.errors[:amount].should == ['nul !']
    end

    
  end


  describe 'change amount'  do
    before(:each) do
      @tr = valid_new_transfer
    end

    it 'should change amount for lines' do
      @tr.amount = 200
      @tr.save
      @tr.line_to.debit.should == 200
      @tr.line_from.credit.should == 200
    end

  end


  describe 'instance method line_to and line_from' do
    before(:each) do
      @t = valid_new_transfer
    end

    it 'a new record answers false to partial, debit and credit_locked?' do
      @t.should_not be_partial_locked
      @t.should_not be_to_locked
      @t.should_not be_from_locked
    end

    context 'check save and after_create' do

      it 'save transfer create the two lines' do
        @t.should be_valid
        expect {@t.save}.to change {Line.count}.by(2) 
      end

      it 'save transfer create the two lines' do
        @t.save!
        @t.should have(2).compta_lines
      end

     

      context 'with a saved tranfer' do

        before(:each) do
          @t.save!
        end

        it 'can return the debited line or the credited line' do
          @t.line_to.should == @t.compta_lines.select { |l| l.debit != 0 }.first
          @t.line_from.should == @t.compta_lines.select { |l| l.credit != 0 }.first
        end

        it 'destroy the transfer should delete the two lines' do
          expect {@t.destroy}.to change {Line.count}.by(-2)
        end
        it 'destroy the transfer is impossible if debit_line locked' do
          @t.line_to.update_attribute(:locked, true)
          @t.should_not be_destroyable
          expect {@t.destroy}.not_to change {Line.count}
        end

        it 'destroy the transfer is impossible if any line locked' do 
          l = @t.line_from
          l.locked.should be_false 
          l.locked = true
          l.valid?
          puts l.errors.messages unless l.valid?
          l.save!
          
          @t.line_from.locked.should be_true 
          @t.should_not be_destroyable
          expect {@t.destroy}.not_to change {Transfer.count}
        end

        it 'can say what it can edit' do
          @t.line_to.update_attribute(:locked, true)
          @t.to_editable?.should be_false
          @t.from_editable?.should be_true
        end

        describe 'update' do

          
          context 'line_to locked' do

            before(:each) do
              l= @t.line_to
              l.locked = true
              l.save!(:validate=>false)
            end
          
            it 'says debit_locked' do
              @t.should be_to_locked
              @t.should be_partial_locked
              @t.should_not be_from_locked
            end


          end

          context 'line_from locked' do

            before(:each) do
              l= @t.line_from
              l.locked = true
              l.save!(:validate=>false)
            end

            
            it 'transfer is credit_locked' do 
              @t.should be_from_locked
              @t.should be_partial_locked
              @t.should_not be_to_locked
            end

          end

        end
      end
    end
  end

end
