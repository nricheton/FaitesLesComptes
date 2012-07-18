# coding: utf-8


require 'date'

#lib/month_year.rb
#
# MonthYear permet de gérer les aspects mois et année du logiciel
# Il s'agit d'une petite classe dans lib qui simplifie l'utilisation des appels 
# de pages sur la base de mois
# 
# L'initialisation est faite avec un hash comprenant les clés :month et :year
# Ces clés peuvent être sous forme numérique ou string
# 
# Une méthode de classe from_date permet également de construire un MonthYear 
# à partir d'une date MonthYear.from_date(Date.today) par exemple.
# 
# MonthYear est Comparable ce qui permet de les ordonner (utile
# pour les exercices décalés)
# MonthYear est notamment utilisé par ListMonths qui est une classe Enumerable
# d'appui à Period. Cela permet de faire Period.list_months.each et de disposer
# des MonthYear de l'exercice.
#
class MonthYear
  include Comparable

  attr_reader :year, :month

  def initialize(h)
    @date = Date.civil(h[:year].to_i, h[:month].to_i)  # pour généréer InvalidDate si les arguments sont non valables
    @month = '%02d' % h[:month]
    @year = '%04d' % h[:year]
  end

  # format par défaut mm-yyyy
  def to_s
    [@month.to_s, @year.to_s].join('-')
  end

  # permet de définir le format de sortie sous la forme habituelle pour les dates
  # %b, %B, %y, %Y etc... avec recours à l'internationalisation.
  # Cela part de la date interne à la classe qui est le premier jour du mois
  # On peut donc avoir un format avec le jour qui sera le 1
  # to_s correspond au format mm-yyyy
  # to_short correspond au format %b (jan. fév. ...
  def to_format(format)
    I18n.l(@date, :format=>format)
  end

  # to_format avec %b donc jan.fév. mar. avr. mai,...
  def to_short
    to_format('%b')
  end

  # méthode de classe permettant de créer unn MonthYear à partir d'une date
  def self.from_date(date)
    MonthYear.new(year:date.year, month:date.month)
  end

  def <=>(other)
    comparable_string <=> other.comparable_string
  end

  
  # donne la date du début du mois
  def beginning_of_month
    @date.beginning_of_month
  end

  # donne la date de fin de mois
  def end_of_month
    @date.end_of_month
  end

  # retourne un hash qui est utilisé dans la constuction des url
  def to_french_h
    {an:@year, mois:@month}
  end

  # crée un hash à corresondant au même mois de l'année précédente
  def previous_year
    MonthYear.from_date(@date.years_ago(1))
  end

  # nombre de jous du mois représenté
  def nb_jour_mois
    @date.end_of_month.day
  end

  protected

  # construit la chaine yyyymm pour faire les comparaisons
  def comparable_string
    (@year+@month).to_i
  end

 

end