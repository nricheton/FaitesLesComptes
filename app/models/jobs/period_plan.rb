module Jobs
  
  # class permettant de remplir en arrière plan toutes les données d'un nouvel
  # exercice
  class PeriodPlan < Struct.new(:db_name, :period_id)
    
    def before(job)
      Apartment::Database.process(db_name) do
        @period = Period.find(period_id)
      end      
    end
    
    def perform
      Apartment::Database.process(db_name) do
        
        # TODO vraiment pas terrible de voir que Period doit solliciter organism.send(:status_class)
        pc = Utilities::PlanComptable.new(@period, @period.organism.send(:status_class))
        
        if @period.previous_period?
          pc.copy_accounts(@period.previous_period)
          pc.copy_natures(@period.previous_period)
        else
          pc.create_accounts
          pc.create_bank_and_cash_accounts
          pc.create_rem_check_accounts           
          pc.load_natures
        end
        @period.check_nomenclature
        # TODO probablement inutile si pas asssociation
        pc.fill_bridge        
      end
    end
    
    def success(job)
      Apartment::Database.process(db_name) do
        @period = Period.find(period_id)
        @period.update_attribute(:prepared, true)
      end
    end
    
  end
  
end