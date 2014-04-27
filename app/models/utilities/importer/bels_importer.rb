module Utilities
  
  module Importer
    
    # Classe destinée à importer des lignes de relevés de comptes
    # à partir d'un fichier csv. Utilise le gem smarter_csv
    # 
    # Le fichier doit avoir quatre colonnes reprenant Date, Libellé, 
    # Débit et Crédit (mais pas forcément ces libellés)
    # 
    # La méthode #import prend un fichier comme argument et le parse
    # pour créer des bank_extract_lines
    # 
    class BelsImporter 
      extend ActiveModel::Naming
      include ActiveModel::Conversion
      include ActiveModel::Validations
      
      attr_accessor :file
      
      def initialize(attributes = {})
        attributes.each { |name, value| send("#{name}=", value) }
      end
      
      # Ce n'est pas un modèle persistant (on n'a jamais donc de vue edit)
      def persisted?
        false
      end
      
      # Il s'agit de sauve les BelsImporter qui ont été chargées par cet importateur
      # pas de faire persister ce modèle.
      def save
        if imported_rows.map(&:valid?).all?
          imported_rows.each(&:save!)
          true
        else
          imported_rows.each_with_index do |bel, index|
            bel.errors.full_messages.each do |message|
              errors.add :base, "Ligne #{index+2}: #{message}"
            end
          end
          false
        end
      end
      
      
      
      
      def imported_rows
        @imported_rows ||= load_imported_rows
      end
      
      # TODO voir à gérer les options
      
      protected
      
      # la méthode qui lit réellement le fichier.
      # l'option headers:true indique que la prmeière ligne du fichier contient
      # les headers
      # 
      # enconding transforme ici l'encoding iso-8859-1 en utf-8 (ce qui sera 
      # probablement meilleur pour la base de données
      # 
      # Ceci a été testé avec un fichier venant du Crédit Agricole (mais dont 
      # on a supprimé 7 ou 8 lignes car le fichier transmis contient quelques 
      # lignes d'infos générales avant de passer au données proprement dites.
      #
      def load_imported_rows(options = {headers:true, encoding:'iso-8859-1:utf-8', col_sep:';'})
        lirs = []
        position = 1
        CSV.foreach(file, options) do |row|
          # vérification des champs
          if not_empty?(row) && correct?(row)
            # création d'un array de Bel
            lirs << ImportedBel.new(position:position, 
              date:row[0], narration:row[1], debit:row[2], credit:row[3])
            position += 1
          end
        end 
        lirs
      
      end
      
      # controle la validité d'une ligne. Si les transformations
      # échoues (to_f ou Date.parse) on arrive dans le bloc et la ligne 
      # n'est pas lue.
      def correct?(row)
        # row[3] et row[2] ne doivent pas être vide tous les deux
        return false if row[2] == nil && row[3] == nil
        Date.parse(row[0]) # on peut lire la date
        row[1] = correct_narration(row[1])
        row[2] ||= '0.0' # on remplace les nil par des zéros
        row[3] ||= '0.0'
        # on remplace la virgule décimale et on le transforme en chiffre        
        row[2] = row[2].gsub(',','.').to_d.round(2)  # on peut faire un chiffre du débit
        row[3] = row[3].gsub(',','.').to_d.round(2)  # on peut faire un chiffre du crédit
        true
      rescue
        Rails.logger.warn "une erreut s est produite #{row}"
        false
      end
      
      # méthode qui permet d'éliminer les lignes dont tous les champs sont nil
      def not_empty?(row)
        row.fields.map(&:blank?).include?(false)
      end
      
      # Corrige la narration en retirant les retours à la ligne et en limitant
      # le nombre de caractères.  
      #
      def correct_narration(text)
        text.gsub("\n",'- ').gsub(/\s+/, ' ').strip.truncate(MEDIUM_NAME_LENGTH_MAX)
      end 
      
      
      
      
      
    end
    
  end
  
  
end