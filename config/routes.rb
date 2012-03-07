Faitesvoscomptes::Application.routes.draw do

  
  namespace :compta do
    resources :organisms do
      resources :periods
    end
    resources :periods do
      resource :balance
      resources :accounts
    end
    resources :accounts do
      resources :lines
    end
  end


  namespace 'admin' do
 
    resource :restore do
      member do
        post 'rebuild'
      end
    end
    resources :organisms do
      
      resources :archives
      resources :books
      resources :income_books
      resources :outcome_books
    
      resources :destinations
      resources :bank_accounts do
        resources :bank_extracts, :only=>[:index, :edit, :destroy] do
          member do
            get 'unlock'
          end
        end
      end
      resources :cashes do
        resources :cash_controls, only: [:index, :destroy]
      end
      resources :periods do
        member do
          get 'select_plan'
          get 'close'
          post 'create_plan'
        end
        resources :lines do
          member do
            post 'lock'
          end
        end
        resources :natures
        resources :accounts do
          collection do
            get :mapping
          end
        end
      end
    end
    resources :periods do
      resources :natures do
        member do
          post :link_nature, :unlink_nature
        end
      end
    end
  end  # FIN DE ADMIN

  # get 'bank_lines/index'

  # match 'cash/:cash_id/cash_lines/index' => 'cash_lines#index', :as=>:cash_lines

  # match 'bank_account/:bank_account_id/bank_lines/index' => 'bank_lines#index', :as=>:bank_account_bank_lines
  # match 'bank_extract/:bank_extract_id/pointage/index' => 'pointage#index',  :as => :pointage
  # match "bank_extract/:bank_extract_id/pointage/:id/pointe" => 'pointage#pointe', :as=> :pointe, :method=>:post
  # match "bank_extract/:bank_extract_id/pointage/:id/depointe" => 'pointage#depointe', :as=> :depointe,:method=>:post

  # DEBUTde la zone public

  resources :organisms , :only=> [:index, :show] do
    resources :periods, :only=> [:index, :show] do
      resources :natures, only: :index do
        collection do
          get 'stats'
        end
      end
      member do
        get 'change'
        
      end
    end

    resources :bank_accounts, :only=> [:index, :show] do
      resources :bank_extracts do
        member do
          get 'pointage'
          post 'pointe'
          post 'depointe'
          post 'lock'
        end
        resources :bank_extract_lines do
          member do
            post 'up'
            post 'down'
          end
        end
      end
    end
    
    resources :books, :only=>[:show]
    resources :income_books
    resources :outcome_books
    resources :destinations, only: :index
    
   
  

    resources :bank_accounts do
      resources :check_deposits
    end

  end

  resources :books do

    resources :multiple_lines
    # TODO probablement inadapté si on ne relie pas le bank_extracts à un books A voir.
    # TODO voir si les post lock sont bien utiles. Peut être à supprimer.
    resources :bank_extracts do
      member do
        post 'lock'
      end
    end
      
   
    resources :lines do
      member do
        post 'lock' # pour la requete ajax
      end
    end
    
  end
  resources :income_books do
    resources :lines
  end
  resources :outcome_books do
    resources :lines
  end
  resources :cashes, :only=> [:show] do
    resources :cash_controls do
      member do
        put 'lock'
      end
    end
    resources :cash_lines
  end

  resources :users

  root to: 'organisms#index'
  

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
