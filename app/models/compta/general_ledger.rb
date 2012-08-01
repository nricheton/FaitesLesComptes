# coding: utf-8

module Compta
  # GeneralLedger est proche de balance, l'instance se crée avec
  # un range de date, un range de comptes
  # Les informations de type balance_line sont utiles à GeneralLedger pour
  # pouvoir donner les soldes au début de la période et à la fin de la période
  #
  # La différence essentielle est l'édition du pdf puisqu'on enchaîne en fait des listings
  # de compte.
  #
  # GeneralLedger se crée comme Balance soit en fournissant tous les paramètres, soit
  # en fournissant period_id et en appelant with_default_values
  #
  # GeneralLedger n'est pas destiné à être affiché à l'écran, il n'a de raison
  # d'être que pour faire une édition papier sous forme de pdf.
  #
  class GeneralLedger < Balance
    # permet de déclarer des colonnes
    def self.columns() @columns ||= []; end

    def self.column(name, sql_type = nil, default = nil, null = true)
      columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, default, sql_type.to_s, null)
    end

    # malgré l'héritage, il faut déclarer les colonnes
    column :from_date, :string
    column :to_date, :string
    column :from_account_id, :integer
    column :to_account_id, :integer
    column :period_id, :integer

    # fait une édition du grand livre
    def to_pdf
      # pour chacun des comptes, faire un listing donc on aura fixé les informations
      # de page : page de début et page total.
      # La classe Listing a donc été enrichie de méthode pour gérer cette question
      # de pagination
      # pour chacun des comptes, on affiche le listing correspondant
      # mais on a d'abord besoin du nombre de pages nécessaires à chacun des comptes
      # pour chacun des comptes on cherche le nombre de pages
      # et on veut le total
      final_pdf = Prawn::Document.new(:page_size => 'A4', :page_layout => :landscape)
      range_accounts.each do |a|
        a.to_pdf(from_date, to_date).render_pdf_text(final_pdf)
        final_pdf.start_new_page unless a == range_accounts.last
      end
      final_pdf
    end

    def render_pdf
      to_pdf.render
    end

  
  end
end
