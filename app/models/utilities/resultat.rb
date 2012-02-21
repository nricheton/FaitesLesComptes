# coding: utf-8

# ce module est destiné à est inclus dans period pour ajouter des fonctionnalités 
# donnant les résultats mensuels et permettant de construire un graphe
#
module Utilities::Resultat
  

  def monthly_results
    self.list_months('%m-%Y').map {|m| self.monthly_result(m)}
  end

  # m est de la forme 'mm-yyyy'
  def monthly_result(m)
    books.all.sum {|b| b.monthly_sold(m)}
  end

  def default_graphic
    dg=Utilities::Graphic.new(self.list_months('%b'))
    dg.add_serie({:legend=>previous_period.exercice, :datas=>self.previous_monthly_results}) if previous_period?
    dg.add_serie({:legend=>self.exercice, :datas=>self.monthly_results})
    dg
  end



  def graphic
    @graphic ||= default_graphic
  end

 

  def previous_monthly_results
    pp=self.previous_period
    self.list_months('%m-%Y').map do |m|
      year= ((m[/\d{4}$/]).to_i) -1
      n="#{m[/^\d{2}/]}-#{year}"
      pp.monthly_result(n)
    end
    
  end


end
