ActionController::Routing::Routes.draw do |map|
  map.login '/login', :controller => 'user_sessions', :action => 'new'
  map.logout '/logout', :controller => 'user_sessions', :action => 'destroy'
  map.resource :user_session

  map.resources :groups, :has_many => [ :invites, :organizations, :users ]
  map.invitation '/groups/:group_id/invitation/:invite_code', :controller => 'invites', :action => 'invitation'
  map.update_invitation '/groups/:group_id/update_invitation/:invite_code', :controller => 'invites', :action => 'update_invitation'
  map.resources :invites
  map.signup '/signup', :controller => 'users', :action => 'new'
  map.confirm '/confirm/:id', :controller => 'users', :action => 'confirm'
  map.forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
  map.reset_password '/reset_password/:id', :controller => 'users', :action => 'reset_password'
  map.change_password '/change_password', :controller => 'users', :action => 'edit_password'
  map.update_locale '/update_locale/', :controller => 'users', :action => 'update_locale'
  map.resources :organizations, :member => { :set_current => :get }, :has_many => [ :themes, :users ]
  map.resources :users, :member => { :enable => :put, :confirm => :get, :update_reset_password => :post },
                    :collection => { :activate => :get, :request_reset_password => :post },
                    :has_many => [ :friends, :groups, :posts, :watchings ]
  map.user_roles '/users/:user_id/roles', :controller => 'roles', :action => 'index'
  map.user_role '/users/:user_id/roles/:id', :controller => 'roles', :action => 'update', :conditions => { :method => :put }
  map.connect '/users/:user_id/roles/:id', :controller => 'roles', :action => 'destroy', :conditions => { :method => :delete }
  map.group_user_roles '/groups/:group_id/users/:user_id/roles', :controller => 'roles', :action => 'index'
  map.group_user_role '/groups/:group_id/users/:user_id/roles/:id', :controller => 'roles', :action => 'update', :conditions => { :method => :put }
  map.connect '/groups/:group_id/users/:user_id/roles/:id', :controller => 'roles', :action => 'destroy', :conditions => { :method => :delete }

  map.resources :addresses, :collection => { :update_regions => :get, :locate => :get, :locate_results => :get }

  map.resources :activities
  map.resources :articles, :member => { :erase => :put }, :has_many => [ :articles, :article_revisions, :comments, :medias, :reviews, :watchings ]
  map.blog_article '/blogs/:id/articles/:article_id', :controller => 'blogs', :action => 'article'
  map.resources :blogs, :member => { :contents => :get }, :has_many => [ :articles ]
  map.resources :comments
  map.resources :forums, :collection => { :sort => :post }, :has_many => [ :topics ]
  map.resources :friendships, :member => { :accept => :put }
  map.resources :medias
  map.new_message_to_user '/messages/new/:to_user_id', :controller => 'messages', :action => 'new'
  map.resources :messages
  map.resources :organizations, :has_many => [ :articles, :comments, :reviews, :watchings ]
  map.resources :posts, :member => { :edit_guru_points => :get, :update_guru_points => :put }
  map.resources :reviews
  map.stylesheet_theme '/stylesheet_theme/:id.css', :controller => 'themes', :action => 'stylesheet'
  map.resources :themes, :member => { :apply => :post }, :collection => { :preview => :get }
  map.resources :topics, :has_many => [ :posts ]
  map.resources :watchings
  map.resources :wikis, :has_many => [ :articles ]

  map.portlet '/portlet/:portal_type/:portal_id', :controller => 'portlet', :action => 'portlet'
  map.reset_portlet '/reset_portlet', :controller => 'portlet', :action => 'reset_portlet'
end