# coding: utf-8

module Extract
#
# un extrait d'un mois d'un livre donné avec capacité à calculer les totaux et les soldes
# 
#
class Cash < Extract::InOut
  
  # définit les titres des colonnes
  def titles
    ['Date', 'Réf', 'Libellé', 'Destination', 'Nature', 'Sorties', 'Entrées']
  end


  # pour pouvoir utiliser indifféremment cash ou book car il n'est pas forcément
  # facile de penser à écrire book quand on traite d'un CashExtract
  def cash
    @book
  end

  # remplit les lignes de l'extrait
  def lines
    @lines ||= cash.extract_lines(@begin_date, @end_date)
  end

  # produit le document pdf en s'appuyant sur la classe PdfDocument::Book
  def to_pdf
     Editions::Cash.new(@period, self)
  end

  
  protected

  
  # ce prepare_line prépare les lignes pour les exports en csv et xls
  #
  # ne pas le confondre avec celui qui préparer les lignes pour le pdf
  # et qui se situe dans la classe Editions::Cash
  def prepare_line(line)
    
    [I18n::l(line.date),
       line.ref,
       line.narration.truncate(40),
       line.destination ? line.destination.name.truncate(22) : '-',
       line.nature ? line.nature.name.truncate(22) : '-' ,
      french_format(line.credit),
      french_format(line.debit)]
  end




end
  

end
