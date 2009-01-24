login '/login', :controller => 'user_sessions', :action => 'new'
logout '/logout', :controller => 'user_sessions', :action => 'destroy'
resource :user_session

resources :groups, :has_many => [ :invites, :users ]
invitation '/groups/:group_id/invitation/:invite_code', :controller => 'invites', :action => 'invitation'
update_invitation '/groups/:group_id/update_invitation/:invite_code', :controller => 'invites', :action => 'update_invitation'
resources :invites
signup '/signup', :controller => 'users', :action => 'new'
confirm '/confirm/:id', :controller => 'users', :action => 'confirm'
forgot_password '/forgot_password', :controller => 'users', :action => 'forgot_password'
reset_password '/reset_password/:id', :controller => 'users', :action => 'reset_password'
change_password '/change_password', :controller => 'users', :action => 'edit_password'
update_locale '/update_locale/', :controller => 'users', :action => 'update_locale'
resource :account, :controller => 'users'
resources :users, :member => { :enable => :put }, :has_many => [ :groups, :posts, :products, :quote_requests ]

resources :addresses, :collection => { :update_regions => :get }

resources :articles, :has_many => [ :articles, :article_revisions, :comments, :medias, :reviews ]
blog_article '/blogs/:id/articles/:article_id', :controller => 'blogs', :action => 'article'
resources :blogs, :member => { :contents => :get }, :has_many => [ :articles ]
resources :comments
resources :forums, :member => { :move_up => :post, :move_down => :post }, :has_many => [ :topics ]
resources :medias
new_message_to_user '/messages/new/:to_user_id', :controller => 'messages', :action => 'new'
resources :messages
resources :posts, :member => { :edit_guru_points => :get, :update_guru_points => :put }
resources :reviews
stylesheet_theme '/stylesheet_theme/:id.css', :controller => 'themes', :action => 'stylesheet'
resources :themes, :collection => { :preview => :get }
apply_theme '/:themeable_type/:themeable_id/themes/:id/apply', :controller => 'themes', :action => 'apply', :method => :post
resources :topics, :has_many => [ :posts ]
resources :wikis, :has_many => [ :articles ]