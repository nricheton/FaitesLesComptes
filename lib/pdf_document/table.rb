# coding: utf-8

module PdfDocument

  # la classe Table du module PdfDocument est une classe qui doit alimenter le
  # template de prawn avec les méthodes nécessaires pour fournir
  # la ligne de titre de la table,
  # la ligne de report si elle existe, 
  # les lignes de la table
  # la ligne de total de la table
  # la ligne A reporter si nécessaire
  # la ligne Total Général pour la dernière page
  #
  # La classe se constuit à partir d'un numéro de page, d'un nombre de lignes
  # d'une source pour les lignes
  # et des indications de colonnes en terme de largeur,
  # ainsi que le fait de savoir si les colonnes doivent être totalisées ou non
  #
  # C'est le PdfDocument qui définit les colonnes que l'on retient,
  # leur largeur et quelles colonnes on veut totaliser.


  class Table
    def initialize(page, document)
      @page = page
      @document = document
    end

    # retourne la ligne de titre à partir des informations de PdfDocument::Default
    def title
      @document.columns_titles
    end

    # retourne le tableau de lignes à partir du numéro de la page fourni par
    # @page, du nombre de lignes par pages, de la source et de la méthode
    # fournis par PdfDocument::Default
    # lines renvoie donc un Arel
    def lines
      @lines ||= @document.fetch_lines(@page.number)
    end

    # lines renvoie un array
    def prepared_lines
        @prepared_lines ||= lines.collect {|l| prepare_line(l)} if lines
    end

    # renvoie un array des profondeur de lignes. Utilisé par rubriks.pdf.prawn pour
    # préciser les styles des lignes
    # La profondeur 0 est en maigre, la 1 en gras, la 2 en plus gras encore,...
    #
    def depths
      @depths ||= lines.map do |l|
        if l.respond_to? 'depth'
          l.depth
        else
          nil
        end
      end
    end

   
    # total_lines renvoie un array correspondant à une première colonne
    # intitulée Total, puis des nils ou des totaux si la colonne a été indiquée
    # par document comme devant être totalisée.
    # total_line fait ensuite un formatage des valeurs avant de rajouter le mot Totaux
    # dans une première colonne.
    def total_line
      r = @document.columns_to_totalize.collect {|index| totalize_column(index)}
      r.insert(0, 'Totaux')
    end

    # appelle les méthodes adéquate pour chacun des éléments de la lignes
    def prepare_line(line)
      @document.prepare_line(line)
    end

    
 
    protected

        
    # fait le total des valeurs de la colonne d'indice i
    # modifie d'abord les valeurs en transformant en Float.
    #
    # N'additionne que s'il y a une valeur
    # ce qui permet d'avoir des valeurs vides dans les colonnes
    # 
    # Retourne 0 n'y a aucune ligne
    def totalize_column(i)
      prepared_lines.each.sum do |l|
           l[i].to_f if l[i]
        end rescue 0
     end




    
   

  end

end
