# -*- encoding : utf-8 -*-

# TODO l'ancien session_controller (avant Devise) faisait un contrôle du navigateur
# et indiquait s'il y avait un problème

class ApplicationController < ActionController::Base 
  protect_from_forgery

  # before_filter :control_version

  before_filter :authenticate_user!

  before_filter :find_organism, :current_period, :unless=>('devise_or_bottom_action?')
  
  helper_method :two_decimals, :virgule, :current_user, :current_period?, :abc


  protected

  # Envoie un cookie si le format demandé est l'un des 3 (xls, csv, pdf)
  #
  # Cette méthode doit être appelée dans les actions qui permettent de l'export de données
  # sous l'un de ces 3 formats, si possible dans la partie respond_to.
  #
  # Elle marche en conjonction avec la méthode qui est dans export.js.coffee la page et
  # la débloque à la réception du fichier.
  def send_export_token
    if request.format.in? ['application/xls', 'text/csv', 'application/pdf']
      cookies[:export_token] = { :value =>params[:token], :expires => Time.now + 1800 }
    end
  end


  private


  def devise_or_bottom_action?
    params[:controller] =~ /^devise/ || params[:controller] =~ /^bottom/
  end

  # on est dans une action du gem devise si on n'est pas loggé ou
  # si l'action n'est pas précisément de se déconnecter
  def devise_action?
    params[:controller] =~ /^devise/
  end

  # Overwriting the sign_out redirect path method
  def after_sign_out_path_for(user)
    devise_sessions_bye_url
  end

  

  # A chaque démarrage de l'application, on vérifie que la base principale
  # (celle qui contient les Room)
  # est cohérente avec la version du logiciel.
  #
  def control_version
    Rails.logger.info 'appel de controle version'
    @control_version = Room.version_update?
  end

  # Lorsqu'il n'y a pas d'organisme, il faut afficher soit la vue
  # admin/rooms#index soit la vue organism selon qu'il y a plusieurs bases ou une seule
  #
  #
  def after_sign_in_path_for(user)
    session[:org_db] = nil
    use_main_connection
    case current_user.rooms.count
    when 0
      accueil = "Bienvenue ! "
      accueil += "<br/>Vous pouvez maintenant créer un organisme "
      accueil += "<br/>Vous pouvez également <a href=#{bottom_manuals_url}>consulter maintenent les manuels</a> du logiciel
      <br/>ou le faire plus tard; un lien vers les manuels est disponible au bas de chaque page"
      flash[:notice]=accueil.html_safe
      new_admin_room_url
    when 1
      r = current_user.rooms.first
      session[:org_db] = r.database_name
      if r.connect_to_organism && (@organism = Organism.first)
        organism_url(@organism)
      else
        # TODO vérifier que tous les cas sont bien couverts. Cas où il y aurait eu interruption dans la création de l'org
        admin_rooms_url
      end
    else
      admin_rooms_url
    end
  end

  
  # se connecte à la base de données indiquée par session[:org_db]
  # et instancie @organism
  # TODO voir s'il ne faudrait pas faire un cache
  def find_organism
    
    # utile pour remettre le système cohérent
    use_main_connection if session[:org_db] == nil
    r = current_user.rooms.find_by_database_name(session[:org_db]) if session[:org_db]
    if r # on doit avoir trouvé une room
      r.connect_to_organism
      @organism = Organism.first # il n'y a qu'un organisme par base
    else
      # si pas d organisme (cas d une base corrompue)
      redirect_to admin_rooms_url and return
    end
  end

  # si pas de session, on prend le premier exercice non clos
  def current_period 
    
    unless @organism
      logger.warn 'Appel de current_period sans @organism'
      return nil
    end
    if session[:period]
      @period = @organism.periods.find_by_id(session[:period]) rescue nil
    else
      return nil if @organism.periods.empty?
      @period = @organism.periods.last
      session[:period] = @period.id
    end
    @period
  end

  def current_period?(p)
    p == current_period
  end

  # HELPER_METHODS
 
  # pour afficher une virgule à la place du point décimal.
  # TODO remplacer tous les recours à two_decimals par virgule chaque fois que possible.
  # TODO voir également à supprimer l'une de ces deux méthodes (la même existe dans ApplicationHelper'
  def two_decimals(montant)
    sprintf('%0.02f',montant)
  rescue
    '0.00'
  end

  # Pour transformer un montant selon le format numérique français avec deux décimales
  def virgule(montant)
    ActionController::Base.helpers.number_with_precision(montant, precision:2) rescue '0,00'
  end

 
  # se connecte à la base principale
  def use_main_connection
    Rails.logger.info "use_main_connection : Passage à la base principale"
    Apartment::Database.switch()
  end
  
  # Méthode à appeler dans les controller rooms pour
  # mettre à jour la session lorsqu'il y a un changement d'organisme
  # Récupère également les variables d'instance @organism et @period si cela a du sens.
  #
  def organism_has_changed?(groom = nil)
    change = false
    # premier cas : il y a une chambre et on vient de changer
    if groom && session[:org_db] != groom.database_name
      logger.info "Passage à l'organisation #{groom.database_name}"
      session[:period] = nil
      session[:org_db]  = groom.database_name
      groom.connect_to_organism
      @organism  = Organism.first
      if @organism && @organism.periods.any?
        @period = @organism.periods.last
        session[:period] = @period.id
      end
      change =true
    end
    
    # deuxième cas : il n'y a pas ou plus de chambre
    if groom == nil #: on vient d'arriver ou de supprimer un organisme
      logger.info "Aucune chambre sélectionné"
      use_main_connection
      session[:period] = nil
      session[:org_db] = nil
      change = true
    end

    # troisème cas : on reste dans la même pièce
    if groom && session[:org_db] == groom.database_name
      logger.info "On reste à l'organisation #{groom.database_name}"
      groom.connect_to_organism
      @organism = Organism.first
      logger.warn 'pas d\'organisme trouvé par has_changed_organism?' unless @organism
      current_period
      change = false
    end
    change
  end

  # fill_mois est utile pour tous les controller que l'on peut appeler avec une options qui peut être
  #   rien et dans ce cas, fill_mois trouve le mois le plus adapté
  #   mois:'tous' pour avoir tous les mois d'affichés
  #   mois:2, an:2013 pour demander un mois spécifique
  #
  # local_params doit renvoyer un hash avec les paramètres complémentaires nécessaires
  # essentiellement un id d'un objet, par exemple :cash_id=>@cash}
  #
  #
  # Ceci permet alors d'avoir un routage vers cash_cash_lines_path(@cash) en supposant
  # que l'on soit dans le controller cash_lines et avec l'action index 
  #
  def fill_mois
    if params[:mois] && params[:an]
      @mois = params[:mois]
      @an = params[:an]
      @monthyear = @period.guess_month_from_params(month:@mois, year:@an)
    else
      @monthyear= @period.guess_month
      redirect_to url_for(mois:@monthyear.month, an:@monthyear.year) if params[:action]=='new'
      unless params[:mois] == 'tous'
        redirect_to url_for(mois:@monthyear.month, an:@monthyear.year, :format=>params[:format]) if (params[:action]=='index')
      end
    end
  end

  # raccourci pour avoir la configuration
  #
  # abc pour ActiverecordBaseConnection_config
  def abc
    ActiveRecord::Base.connection_config
  end
  
  

  

end
