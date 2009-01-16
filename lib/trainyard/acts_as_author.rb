module Trainyard
  module ActsAsAuthor
    def self.included(base)
      base.extend(MacroMethods)
    end
  
    module MacroMethods
      def acts_as_author(*args)
        class_eval do
          belongs_to :locale
          has_many :messages, :foreign_key => :to_user_id, :order => 'created_at DESC'
          has_many :sent_messages, :class_name => 'Message', :foreign_key => :from_user_id, :order => 'created_at DESC'
          has_many :posts, :order => 'created_at DESC'

          validates_presence_of :locale_id
  
          attr_accessible :locale_id
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Trainyard::ActsAsAuthor) if defined?(ActiveRecord::Base)