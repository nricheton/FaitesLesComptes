# -*- encoding : utf-8 -*-

class BankAccount < ActiveRecord::Base
  include Utilities::JcGraphic

  belongs_to :organism
  has_many :check_deposits
  has_many :bank_extracts
  
  # un compte bancaire a un compte comptable par exercice
  has_many :accounts, :as=> :accountable
  has_many :compta_lines, :through=>:accounts

  attr_accessible :number, :bank_name, :comment, :nickname

  validates :number, :uniqueness=>{:scope=>[:organism_id, :bank_name]}
  validates :bank_name, :number, :nickname,  presence: true

  after_create :create_accounts
  after_update :change_account_title, :if=> lambda {nickname_changed? }
  

 def current_account(period)
   accounts.where('period_id = ?', period.id).first
 end

 # renvoie le solde du compte bancaire à une date donnée et pour :debit ou :credit
 # arguments à fournir : la date et le sens (:debit ou :credit)
 # renvoie 0 s'il n'y a pas d'écriture ou si un exercice n'existe pas
 # Ce peut être le cas avec un premier exercice commencé en cours d'année
 # quand on est dans l'exerice suivant qui lui est en année pleine.
 def cumulated_at(date, dc)
    p = organism.find_period(date)
    return 0 unless p
    acc = current_account(p)
    Writing.sum(dc, :select=>'debit, credit', :conditions=>['date <= ? AND account_id = ?', date, acc.id], :joins=>:compta_lines).to_f
    # nécessaire car quand il n'y a aucune compa_lines, le retour est '0' et non 0 ce qui pose des
    # problèmes de calcul
  end

  # renvoie le dernier relevé de compte (par date de fin) faisant partie de l'exercice
  def last_bank_extract(period)
     bank_extracts.where('end_date <= ?', period.close_date).order(:end_date).last
  end
 
 # créé un nouvel extrait bancaire rempli à partir des informations du précédent
 # le mois courant et solde zéro si c'est le premier
  def new_bank_extract(period)
    previous_be = last_bank_extract(period)
    if previous_be
      bank_extracts.new(begin_date: previous_be.end_date + 1.day,
                        end_date: (previous_be.end_date + 1.day).end_of_month,
                        begin_sold: previous_be.end_sold)
    else
      bank_extracts.new(begin_date: period.start_date,
                        end_date: period.start_date.end_of_month,
                        begin_sold: 0)
    end
  end

 # trouve toutes les lignes non pointées -np pour not pointed
 # les lignes à sélectionner sont celles qui correspondent aux comptes comptables
 # appartenant à ce compte bancaire
 # 
# Appelé par la classe NotPointedLines  
 #
  def np_lines
    not_pointed_lines.lines
  end

 # fait le total débit des lignes non pointées et des remises chèqures déposées
 # donc en fait c'est le total débit des lignes.
 # cette méthode est là par souci de symétrie avec total_credit_np
 def total_debit_np
   total_debit_np_lines
 end

 # fait le total crédit des lignes non pointées et des remises chèqures déposées
 def total_credit_np
   self.total_credit_np_lines 
 end

 # solde des lignes non pointées
 def sold_np
   self.total_credit_np - self.total_debit_np
 end

 def sold
   last_bank_extract_sold + sold_np
 end

 def first_bank_extract_to_point
   bank_extracts.where('locked = ?', false).order('begin_date ASC').first
 end


 def nb_lines_to_point
   np_lines.size 
 end

 

 def unpointed_bank_extract?
   self.bank_extracts.where('locked = ?', false).count > 0 ? true :false
 end

 protected

 def not_pointed_lines
   Utilities::NotPointedLines.new(self)
 end


 #  totalise débit et crédit de toutes les lignes non pointées
 def total_debit_np_lines
   np_lines.sum(&:debit)
 end

  #  totalise débit et crédit de toutes les lignes non pointées
 def total_credit_np_lines
   np_lines.sum(&:credit)
 end


 # appelé par le callback after_create, crée un compte comptable de rattachement
 # pour chaque exercice ouvert.
 def create_accounts
   logger.info 'création des comptes liés au compte bancaire' 
   # demande un compte de libre sur l'ensemble des exercices commençant par 51
   n = Account.available('512') # un compte 512 avec un précision de deux chiffres par défaut
   organism.periods.where('open = ?', true).each do |p|
     self.accounts.create!(number:n, period_id:p.id, title:nickname)
   end
 end

 # quand on change le nickname de la banque il est nécessaire de modifier l'intitulé
 # du compte associé à cette banque.
 def change_account_title
   accounts.each {|acc| acc.update_attribute(:title, nickname)}
 end


end

