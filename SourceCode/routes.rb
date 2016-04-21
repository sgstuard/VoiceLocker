# Barebones template created by Rails, filled in manually
# Contributors: Alex Humphries, Simon Stuard

Rails.application.routes.draw do
  resources :text_files
  resources :users
  get     'user_files'  => 'text_files#index'
  get     'signup'      => 'users#new'
  get     'home'        => 'welcome#home'
  get     'login'       => 'sessions#new'
  post    'record_audio'=> 'users#record_audio'

  post    'login'       => 'sessions#create'
  delete  'logout'      => 'sessions#destroy'
  root    'welcome#home'
end
  
