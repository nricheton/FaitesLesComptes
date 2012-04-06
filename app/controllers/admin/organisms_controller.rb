# -*- encoding : utf-8 -*-

class Admin::OrganismsController < Admin::ApplicationController
  # GET /organisms
  # GET /organisms.json
 

  def index
    @organisms = Organism.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @organisms }
    end
  end

  # GET /organisms/1
  # GET /organisms/1.json
  def show
    reset_session if (params[:id] != session[:organism])
    @organism = Organism.find(params[:id])
    session[:organism] = @organism.id if @organism
    
    if @organism.periods.empty?
      flash[:alert]= 'Vous devez créer un exercice pour cet organisme'
      redirect_to new_admin_organism_period_url(@organism)
      return
    end
    # on trouve l'exercice à partir de la session mais si on a changé d'organisme
    # il faut changer la session et on charge le dernier exercice par défaut
    begin
      @period = @organism.periods.find(session[:period])
    rescue
      @period = @organism.periods.last
      session[:period]=@period.id
    end
  
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @organism }
    end
  end

  # GET /organisms/new
  # GET /organisms/new.json
  def new
    @organism = Organism.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @organism }
    end
  end

  # GET /organisms/1/edit
  def edit
    @organism = Organism.find(params[:id])
  end

  # POST /organisms
  # POST /organisms.json
  def create
    @organism = Organism.new(params[:organism])

    respond_to do |format|
      if @organism.save
        format.html { redirect_to new_admin_organism_period_url(@organism), notice: "Création de l'organisme effectuée, un livre des recettes et un livre des dépenses ont été créés.\n
          Il vous faut maintenant créer un exercice pour cet organisme" }
        format.json { render json: @organism, status: :created, location: @organism }
      else
        format.html { render action: "new" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /organisms/1
  # PUT /organisms/1.json
  def update
    @organism = Organism.find(params[:id])

    respond_to do |format|
      if @organism.update_attributes(params[:organism])
        format.html { redirect_to [:admin, @organism], notice: "Modification de l'organisme effectuée" }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @organism.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /organisms/1
  # DELETE /organisms/1.json
  def destroy
    @organism = Organism.find(params[:id])
    if @organism.destroy
      session[:period] = nil
      redirect_to admin_organisms_url
    else
      render
    end
    
  end

 
end
