# coding: utf-8

module Utilities


  # Cette classe est une collection des lignes non pointées pour un compte bancaire spécifique
  #
  # Se crée par new avec un compte bancaire comme argument
  #
  # La liste des écritures non pointées est stockée sous forme de tableau de hash
  # reprenant les infos nécessaires à l'affichage dans l'action pointage
  #
  # A savoir le type d'écriture par un symbole (:check_deposit ou :standard_line)
  # la date, un libéllé qui peut être Remise de chèque ou narration,
  # le débit et le crédit

  class NotPointedLines

    attr_reader :lines, :bank_account

    def initialize(bank_account)
      @bank_account = bank_account
      fetch_lines
    end

    private

    def fetch_lines
      @lines ||= bank_account.compta_lines.not_pointed
    end

  end



end
