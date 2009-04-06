module ContactHelper
  def render_contact(resource, options = {})
    capture do
      unless options[:address] == false || resource.address.blank?
        concat render_heading(t(:address, :scope => [ :contacts ]))

        concat render(:partial => 'addresses/show', :locals => { :address => resource.address })
      end

      unless options[:emails] == false || resource.emails.empty?
        concat render_heading(tp(:email, :scope => [ :contacts ]))

        concat render(:partial => 'emails/show', :collection => resource.emails, :as => :email)
      end

      unless options[:phones] == false || resource.phones.empty?
        concat render_heading(tp(:phone, :scope => [ :contacts ]))

        concat render(:partial => 'phones/show', :collection => resource.phones, :as => :phone)
      end

      unless options[:urls] == false || resource.urls.empty?
        concat render_heading(tp(:url, :scope => [ :contacts ]))

        concat render(:partial => 'urls/show', :collection => resource.urls, :as => :url)
      end
    end
  end
end