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
        flash[:error] = t('users.flashs.errors.not_allowed')
        format.html { redirect_to(:back) rescue redirect_to(root_path) }
        format.xml  { head :unauthorized }
        format.js   { head :unauthorized }
      end
    end
  end

  def self.included(receiver)
    receiver.extend ClassMethods
    receiver.class_eval do
      include InstanceMethods
      # If work with authlogic, we should set before_save in User instead.
      before_filter :set_current_user_for_model_security unless defined? Authorization
    end
  end
end