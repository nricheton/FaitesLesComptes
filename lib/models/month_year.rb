# coding: utf-8

class MonthYear
  include Comparable

  attr_reader :year, :month

  def initialize(h)
    @date = Date.civil(h[:year], h[:month])  # pour généréer InvalidDate si les arguments sont non valables
    @month = '%02d' % h[:month]
    @year = '%04d' % h[:year]
  end

  def to_s
    [@month.to_s, @year.to_s].join('-')
  end

  def to_short_month
    I18n.l( @date, :format=>'%b')
  end

  def self.from_date(date)
    MonthYear.new(year:date.year, month:date.month)
  end

  def <=>(other)
    comparable_string <=> other.comparable.string
  end

  def comparable_string
    (@year+@month).to_i
  end
end
