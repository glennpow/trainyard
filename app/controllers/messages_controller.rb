class MessagesController < ApplicationController
  make_resource_controller(:actions => [ :show, :new, :create, :destroy ]) do
    before :show do
      @message.update_attribute(:read, true) if !@message.read && @message.to_user == current_user
    end
    
    before :new do
      @message.to_user = @to_user
    end
    
    before :create do
      @message.from_user = current_user
    end
    
    response_for :create do |format|
      format.html { redirect_to object_path }
    end
  end
 
  def resourceful_name
    t(:message, :scope => [ :content ])
  end

  before_filter :check_logged_in
  before_filter :check_to_user, :only => [ :new ]
  before_filter :check_recipient_of, :only => [ :destroy ]
  before_filter :check_recipient_or_sender_of, :only => [ :show ]
  
  def index
    @mailbox = (params[:mailbox] || :inbox).to_sym

    respond_with_indexer do |options|
      options[:default_sort] = :name
      options[:headers] = [
        { :name => t(@mailbox == :inbox ? :from : :to, :scope => [ :content ]), :sort => :user, :include => (@mailbox == :inbox ? :from_user : :to_user), :order => "#{User.table_name}.name" },
        { :name => t(:subject, :scope => [ :content ]), :sort => :subject },
        { :name => t(@mailbox == :inbox ? :received : :sent, :scope => [ :content ]), :sort => :created_at }
      ]
      options[:locals] = { :mailbox => @mailbox }

      options[:conditions] = case @mailbox
      when :sent
        { :from_user_id => current_user }
      else #when :inbox
        { :to_user_id => current_user }
      end
    end
  end

  
  private
  
  def check_to_user
    check_condition(params[:to_user_id] && @to_user = User.find(params[:to_user_id]))
  end
  
  def check_recipient_of
    check_condition(has_administrator_role? || @message.to_user == current_user)
  end
 
  def check_recipient_or_sender_of
    check_condition(has_administrator_role? || @message.to_user == current_user || @message.from_user == current_user)
  end
end