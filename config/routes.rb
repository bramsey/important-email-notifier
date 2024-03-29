Notifier::Application.routes.draw do

  get "accounts/create"

  get "accounts/destroy"

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks",
                                       :registrations => "users/registrations" }
  resources :users do
    resources :messages, :only => [:index, :show]
    resources :accounts, :only => [:index, :new]
    resources :notification_services, :except => [:create]
    resources :email_services, :controller => "notification_services"
    resources :notifo_services, :controller => "notification_services"
    member do
      get :recipients, :senders
      post :busy
    end
    collection do
      post :reset_pass
      get  :recover
    end
  end
  
  resources :messages, :except => [:index] do
    member do
      post :disagree
      post :agree
    end
    collection do
      post :init
    end
  end
  resources :accounts, :except => [:index, :new] do
    member do
      post :toggle_active
      post :toggle_reply
      post :update_service
    end
  end
  
  resources :notification_services
  resources :email_services, :controller => "notification_services"
  resources :notifo_services, :controller => "notification_services"
  
  namespace :users do
      root :to => "pages#home"
  end
  
 
  
  #resources :sessions, :only => [:sign_in, :create, :destroy]
  resources :relationships, :only => [:create, :destroy, :toggle_allow, :toggle_blocked] do
    member do
      post 'toggle_allow'
      post 'toggle_blocked'
    end
  end

  match '/oauth/google', :to => 'oauth#google'
  match '/oauth/auth', :to => 'oauth#auth'
  match '/contacts', :to => 'users#index'
  match '/signup', :to => 'users#new'
  match '/signin', :to => 'sessions#new'
  match '/signout', :to => 'sessions#destroy'
  match '/contact', :to => 'pages#contact'
  match '/about', :to => 'pages#about'
  match '/prioritize', :to => 'messages#prioritize'
  match '/rank', :to => 'messages#rank'

  root :to => 'pages#home'

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
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
