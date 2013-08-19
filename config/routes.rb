Cocina::Application.routes.draw do

  resources :recipes do
    get :print, :on => :member             #/recipes/1/print
    get :search_title, :on => :collection  #for auto-complete
    post :rate, :on => :member             #/recipes/1/rate?rating=4
    post :move, :on => :member             #/recipes/1/move?cat_id=4&tag=chicken
    get :tags, :on => :collection          #recipes/tags for auto-complete
    get :cats, :on => :collection          #recipes/cats for left nav
    get :indx, :on => :collection          #recipes/indx
    resources :photos do                   #/recipes/1/photos
        get :setprimary, :on => :member
    end
  end 
  
  match 'categories/:category_id/recipes' => 'recipes#by_category', :as => :recipes_by_category, :via => :get
  match 'categories/:category_id/tags/:tag/recipes' => 'recipes#by_category_and_tag', :as => :recipes_by_category_and_tag, :via => :get
        
  namespace :admin do
    resources :categories do
      post :reorder, :on => :collection   
      post :tagname, :on => :collection
      get :tagmaint, :on => :collection
    end
    resources :scarfers do
      post :dotest, :on => :collection
      get :export, :on => :member
      post :import, :on => :collection
    end
    resources :preferences do
      get :editaccount, :on => :collection
      post :updateaccount, :on => :collection
    end
    resources :users
  end 
  
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    delete 'logout' => :destroy
  end  

  root :to => 'recipes#index'
  
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
  
  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
