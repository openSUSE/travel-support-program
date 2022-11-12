Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  mount LetterOpenerWeb::Engine, at: "/letter_opener"

  devise_for :users,
    :controllers => { :registrations => 'registrations',
                      :ichain_registrations => "ichain_registrations"},
    :failure_app => Devise::IchainFailureApp

  concern :state_machine do
    resources :state_transitions, :only => [:new, :create]
    resources :state_adjustments, :only => [:new, :create]
  end

  concern :commentable do
    resources :comments, :only => [:new, :create]
  end

  resources :events do
    resources :event_emails, except: [:edit, :update, :destroy] do
      post :preview, on: :collection
    end
    get :participants, on: :member
    resources :event_organizers, except: [:edit, :update, :show] do
      get :autocomplete_user, :on => :collection
    end
  end
  resources :budgets

  resources :travel_sponsorships,
            :concerns => [:state_machine, :commentable],
            :defaults => {:machine => 'travel_sponsorship'} do
    resource :expenses_approval, :only => [:edit, :update]
  end

  resources :shipments,
            :concerns => [:state_machine, :commentable],
            :defaults => {:machine => 'shipment'}

  # Keep index and show as smart redirections for backwards compatibility
  resources :requests, :only => [:index, :show] do
    resource :reimbursement, :concerns => [:state_machine, :commentable], :defaults => {:machine => 'reimbursement'} do
      resources :attachments, :only => [:show], :controller => :reimbursement_attachments
      resource  :acceptance, :only => [:new, :create, :show], :controller => :reimbursement_acceptances
      resources :payments, :except => [:show, :index] do
        get :file, :on => :member
      end
      get :check_request, :on => :member, :defaults => { :format => 'pdf' }
    end
  end

  # A separate controller is needed because inherited_resources cannot manage
  # belongs_to resources associations that are both singleton and optional
  resources :reimbursements, :only => [:index], :controller => :reimbursements_lists

  resource :user_profile do
    get :password, :on => :member
    put :update_password, :on => :member
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  get 'profile' => 'user_profiles#edit', :as => :profile
  get 'profile/password' => 'user_profiles#password', :as => :profile_password
  resources :pages, :controller => 'pages'
  get 'reports/travel_expenses' => "reports#travel_expenses", :as => :travel_expenses_report

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
  root :to => 'pages#userguide'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
