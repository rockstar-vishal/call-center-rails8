Rails.application.routes.draw do
  devise_for :users
  
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Root path - redirects based on user role
  root "dashboard#index"

  # SysAdmin Interface
  namespace :sysadmin do
    get 'dashboard', to: 'dashboard#index'
    resources :companies
    resources :users
    resources :statuses
    resources :sources
    resources :roles
  end

  # Company Interface  
  namespace :company do
    get 'dashboard', to: 'dashboard#index'
    resources :leads do
      collection do
        patch :bulk_update
      end
      member do
        get :mini_edit
        patch :mini_update
        get :call
        patch :submit_call
      end
      resources :call_logs, controller: 'leads/call_logs'
    end
    
    # Lead import routes
    get 'leads/import/new', to: 'lead_imports#new', as: 'new_lead_import'
    post 'leads/import', to: 'lead_imports#create', as: 'lead_imports'
    get 'leads/import/sample', to: 'lead_imports#sample', as: 'sample_lead_import'
    
    resources :projects
    namespace :reports do
      get :projects
      get :productivity
      get :users
      get :activity
      get :performance
    end
    resources :users do
      # Manager assignment routes
      get 'managers', to: 'user_managers#index'
      post 'managers', to: 'user_managers#create'
      delete 'managers/:manager_id', to: 'user_managers#destroy', as: 'remove_manager'
    end
  end

  # Convenience routes
  get 'sysadmin_dashboard', to: 'sysadmin/dashboard#index'
  get 'company_dashboard', to: 'company/dashboard#index'
end
