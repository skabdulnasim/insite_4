DealMaker::Engine.routes.draw do
  resources :deals

  root :to => 'deals#index'
end
