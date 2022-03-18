Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    resources :books, only: %i(index show)
    resources :borrow_requests, only: %i(index show)

    namespace :admin do
      root "static_pages#home"
      resources :borrow_requests, only: %i(index show edit)
    end

    root "static_pages#home"
    get "/home", to: "static_pages#home"
    get "/about", to: "static_pages#about"
    get "/contact", to: "static_pages#contact"

    get "/signup", to: "users#new"
    post "/signup", to: "users#create"

    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    resources :users

    resources :users do
      resources :borrow_requests
    end

    match "borrow_requests/:id/cancel", to: "borrow_requests#cancel",
                                        as: "user_borrow_request_cancel",
                                        via: :post
  end
end
