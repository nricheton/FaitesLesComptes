# clones_controller permet de produire un clone d'une base de données pour faire
# une archive de secours.
#
# Le commentaire qui sera rentré dans le formulaire affiché par la vue new, servira de
# commentaire pour la nouvelle room
#
class Admin::ClonesController < Admin::ApplicationController

  skip_before_filter :current_period

  after_filter :clear_org_cache, only:[:create]

  # ici on a besoin que d'un formulaire qui donne une room avec son id et le champ commentaire
  def new
    @new_clone = Organism.new
  end

  #
  def create
    r = @organism.room
    if r.clone_db(params[:organism][:comment])
      flash[:notice] = 'Un clone de votre base a été créé'
    else
      flash[:alert] = 'Une erreur s\'est produite lors de la création du clone de votre base'
    end
    redirect_to admin_rooms_url
  end
end
