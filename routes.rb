login '/login', :controller => 'user_sessions', :action => 'new'
logout '/logout', :controller => 'user_sessions', :action => 'destroy'
resource :user_session

resources :groups, :has_many => [ :invites, :organizations, :users ]
invitation '/groups/:group_id/invitation/:invite_code', :controller => 'invites', :action => 'invitation'
update_invitation '/groups/:group_id/update_invitation/:invite_code', :controller => 'invites', :action => 'update_invitation'
resources :invites
signup '/signup', :controller => 'users', :action => 'new'
confirm '/confirm/:id', :controller => 'users', :action => 'confirm'
forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
reset_password '/reset_password/:id', :controller => 'users', :action => 'reset_password'
change_password '/change_password', :controller => 'users', :action => 'edit_password'
update_locale '/update_locale/', :controller => 'users', :action => 'update_locale'
resources :organizations, :member => { :set_current => :get }, :has_many => [ :themes, :users ]
resources :users, :member => { :enable => :put, :confirm => :get, :update_reset_password => :post },
                  :collection => { :activate => :get, :request_reset_password => :post },
                  :has_many => [ :groups, :posts, :watchings ]
user_roles '/users/:user_id/roles', :controller => 'roles', :action => 'index'
user_role '/users/:user_id/roles/:id', :controller => 'roles', :action => 'update', :conditions => { :method => :put }
connect '/users/:user_id/roles/:id', :controller => 'roles', :action => 'destroy', :conditions => { :method => :delete }
group_user_roles '/groups/:group_id/users/:user_id/roles', :controller => 'roles', :action => 'index'
group_user_role '/groups/:group_id/users/:user_id/roles/:id', :controller => 'roles', :action => 'update', :conditions => { :method => :put }
connect '/groups/:group_id/users/:user_id/roles/:id', :controller => 'roles', :action => 'destroy', :conditions => { :method => :delete }

resources :addresses, :collection => { :update_regions => :get, :locate => :get, :locate_results => :get }

resources :articles, :member => { :erase => :put }, :has_many => [ :articles, :article_revisions, :comments, :medias, :reviews, :watchings ]
blog_article '/blogs/:id/articles/:article_id', :controller => 'blogs', :action => 'article'
resources :blogs, :member => { :contents => :get }, :has_many => [ :articles ]
resources :comments
resources :forums, :collection => { :sort => :post }, :has_many => [ :topics ]
resources :medias
new_message_to_user '/messages/new/:to_user_id', :controller => 'messages', :action => 'new'
resources :messages
resources :organizations, :has_many => [ :articles, :comments, :reviews, :watchings ]
resources :posts, :member => { :edit_guru_points => :get, :update_guru_points => :put }
resources :reviews
stylesheet_theme '/stylesheet_theme/:id.css', :controller => 'themes', :action => 'stylesheet'
resources :themes, :member => { :apply => :post }, :collection => { :preview => :get }
resources :topics, :has_many => [ :posts ]
resources :watchings
resources :wikis, :has_many => [ :articles ]

portlet '/portlet/:portal_type/:portal_id', :controller => 'portlet', :action => 'portlet'
reset_portlet '/reset_portlet', :controller => 'portlet', :action => 'reset_portlet'
