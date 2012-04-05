# -*- encoding : utf-8 -*-

class LinesController < ApplicationController

  # TODO verifier 'utilité de ce choose layout
  layout :choose_layout # inutile maintenant car lié à l'utilisation de modalbox

  # pour être sur d'avoir l'organisme avant d'appeler le before filter de
  # application_controller qui va remplir le period (lequel est utile pour les soldes)
  prepend_before_filter :find_book
  before_filter :change_period, only: [:index] # pour permettre de changer de period quand on clique sur une
  # des barres du graphe.qui est affiché par organism#show
  before_filter :fill_mois, only: [:index, :new]
  before_filter :fill_natures, :only=>[:new,:edit] # pour faire la saisie des natures en fonction du livre concerné

  # GET /lines
  # GET /lines.json 
  def index 
    @date = @period.guess_date(@mois)
    @monthly_extract = Utilities::MonthlyBookExtract.new(@book, @date)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @lines }
      format.pdf { @listing = Listing.new(@period, @mois, @book) }
      format.csv {render :layout=>false}
  
    end
  end


  # appelé par l'icone clé dans l'affichage des lignes pour
  # verrouiller la ligne concernée.
  # la mise à jour de la vue est faite par lock.js.erb qui
  # cache les icones modifier et delete, ainsi que l'icone clé et
  # fait apparaître l'icone verrou fermé.
  #  def lock
  #    @line=Line.find(params[:id])
  #    if @line.update_attribute(:locked, true)
  #      respond_to do |format|
  #        format.js # appelle validate.js.erb
  #      end
  #    end
  #  end

 

  # GET /lines/new
  # GET /lines/new.json
  def new
    @line =@book.lines.new(line_date: flash[:date] || @period.start_date.months_since(@mois.to_i), :cash_id=>@organism.main_cash_id, :bank_account_id=>@organism.main_bank_id)
    @previous_line = Line.find_by_id(flash[:previous_line_id]) if flash[:previous_line_id]
    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @line }
     end
  end


  # POST /lines
  # POST /lines.json
  def create
   # flash[:date]= get_date # permet de transmettre la date à l'écriture suivante
    @line = @book.lines.new(params[:line])
    respond_to do |format|
      if @line.save
        flash[:date]=@line.line_date
        flash[:previous_line_id]=@line.id
        mois=(@line.line_date.month)-1
        format.html { redirect_to new_book_line_url(@book,mois: mois) }
        format.json { render json: @line, status: :created, location: @line }
      else
        format.html { render action: "new" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
        # format.js
      end
    end
  end

  def edit
    @line = @book.lines.find(params[:id])
  end
  
  
  
  # PUT /lines/1
  # PUT /lines/1.json
  def update
    get_date # transforme la params[:picker_to_date] en params[:line][:line_date]
    @line = @book.lines.find(params[:id])
  
    respond_to do |format|
      if @line.update_attributes(params[:line])
        mois=(@line.line_date.month) -1
        format.html { redirect_to book_lines_url(@book, mois: mois) }#], notice: 'Line was successfully updated.')}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lines/1
  # DELETE /lines/1.json
  def destroy
    @line = @book.lines.find(params[:id])
    @line.destroy
  
    respond_to do |format|
      format.html { redirect_to book_lines_url(@book, :mois=>@period.guess_month(@line.line_date)) }
      format.json { head :ok }
    end
  end

  protected

 
 
  def find_book
    @book=Book.find(params[:book_id] || params[:income_book_id] || params[:outcome_book_id] )
    @organism=@book.organism
  end

  def fill_mois
    if params[:mois]
      @mois = params[:mois]
    else
      @mois= @period.guess_month
      redirect_to book_lines_url(@book, mois: @mois, :format=>params[:format]) if (params[:action]=='index')
      redirect_to new_book_line_url(@book,mois: @mois) if params[:action]=='new'
    end
  end


  # TODO ici il faut remplacer cette méthode par une méthode period.natures_for_book(@book) qui choisira les natures qui
  # conviennent à la classe du livre.
  # FIXME render new ne repassant pas par les filtres les @natures du formulaire sont toutes les natures
  # et non pas seulement celles relatives au book
  def fill_natures
    if @book.class.to_s == 'IncomeBook'
      @natures=@period.natures.recettes
    else
      @natures=@period.natures.depenses
    end
  end

  
  def choose_layout
    (request.xhr?) ? nil : 'application'
  end

  

#  def get_date
#    # TODO voir ce qu'il se passe quand la date n'est pas valide ?
#    params[:line][:line_date]= picker_to_date(params[:pick_date_line])
#  end

  
  # change period est rendu nécessaire car on peut accéder directement aux lignes d'un exercice
  # à partir du graphe d'accueil. 
  # TODO Il serait peut être plus judicieux de se déconnecter complètement de la notion d'exercice 
  # pour avoir alors un appel avec month et year, ce qui oterait toute ambiguité. 
  def change_period
    if params[:period_id] &&  (params[:period_id].to_i != session[:period])
      @period = @organism.periods.find(params[:period_id])
      session[:period]=@period.id
      flash[:alert]= "Attention, vous avez changé d'exercice !"
      redirect_to book_lines_url(params[:book_id], :mois=>params[:mois])
    else
      @period=@organism.periods.find(session[:period])
    end
  end



end
