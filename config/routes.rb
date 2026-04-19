Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Root path - public search page
  root "nutritionists#index"
  
  # Nutritionists search
  resources :nutritionists, only: [:index]
  
  # Appointment requests
  resources :appointment_requests, only: [:new, :create]
  
  # Nutritionist pending requests (React page)
  namespace :nutritionists do
    resources :pending_requests, only: [:index]
  end
  
  # API endpoints for nutritionist actions
  namespace :api do
    namespace :v1 do
      resources :appointment_requests, only: [] do
        member do
          patch :accept
          patch :reject
        end
      end
      
      resources :nutritionists, only: [] do
        member do
          get :pending_requests
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
