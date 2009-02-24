module AuthorizedSystem
  module ClassMethods
    
  end
  
  module InstanceMethods
    protected
    
    def set_current_user_for_model_security
      Authorization.current_user = self.current_user
    end
    
    def permission_denied
      respond_to do |format|
        flash[:error] = 'Sorry, you are not allowed to view the requested page.'
        format.html { redirect_to(:back) rescue redirect_to(root_path) }
        format.xml  { head :unauthorized }
        format.js   { head :unauthorized }
      end
    end
  end
  
  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.send :include, InstanceMethods
    # If work with authlogic, we should set before_filter in UserSession instead.
    receiver.send :before_filter, :set_current_user_for_model_security unless defined? Authorization
  end
end