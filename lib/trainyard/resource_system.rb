module Trainyard
  module ResourceSystem
    def self.included(base)
      base.extend(MacroMethods)
      base.send :helper_method, :resourceful_name if base.respond_to? :helper_method
    end
  
    module MacroMethods
      def make_resource_controller(options = {}, &block)
        action_list = options.delete(:actions) || [ :show, :new, :create, :edit, :update, :destroy ]
  
        base_block = proc do
          actions *action_list
          collection_actions :index unless action_list.include?(:index)
    
          response_for :show_fails do |format|
            not_found = Proc.new { render :file => "#{RAILS_ROOT}/public/404.html", :status => 404 }
            format.html &not_found
            format.js &not_found
            format.xml &not_found
          end

          after :create do
            flash[:notice] = t(:object_created, :object => resourceful_name)
          end
    
          after :create_fails do
            flash[:error] = "<p class='error-heading'>#{t(:object_not_created, :object => resourceful_name)}</p>" +
              @template.render_list(current_object.errors.full_messages)
            logger.warn("Failed to create #{resourceful_name}: #{current_object.errors.full_messages.to_sentence}")
          end

          after :update do
            flash[:notice] = t(:object_updated, :object => resourceful_name)
          end

          after :update_fails do
            flash[:error] = "<p class='error-heading'>#{t(:object_not_updated, :object => resourceful_name)}</p>" +
              @template.render_list(current_object.errors.full_messages)
            logger.warn("Failed to update #{resourceful_name}: #{current_object.errors.full_messages.to_sentence}")
          end

          after :destroy do
            flash[:notice] = t(:object_deleted, :object => resourceful_name)
          end
  
          response_for :destroy do |format|
            format.html { redirect_to :back }
            format.js
          end
        end
  
        self.make_resourceful(options.merge({ :include => base_block }), &block)
      end
    end

    def resourceful_name
      t(:resource)
    end
  
    def save_all(*resources)
      success = false
      begin
        ActiveRecord.transaction do
          resources.each(&:save!)
        end
        success = true
      rescue ActiveRecord::RecordInvalid
      end
    
      errors = []
      unless success
        resources.each { |resource| errors.concat(resource.errors.full_messages) }
        errors.flatten!
        errors.compact!
      end
    
      return success, errors
    end
  end
end

ActionController::Base.send(:include, Trainyard::ResourceSystem) if defined?(ActionController::Base)