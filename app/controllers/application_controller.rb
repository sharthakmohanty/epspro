class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :authenticate_user!
  before_filter :set_cache_buster

  #required for preventing click on back button in browser
  def set_cache_buster
    response.headers["Cache-Control"] = "no-cache, no-store, max-age=0, must-revalidate"
    response.headers["Pragma"] = "no-cache"
  end

  def after_sign_in_path_for(resource)
  	if current_user.role != "merchant"
  		epsadmin_merchants_path
    else
      dashboard_index_path  
  	end
  end

  def mobile_agent?
     @browser = ""
     @browser = "mobile" if request.env["HTTP_USER_AGENT"] && request.env["HTTP_USER_AGENT"][/Android/]
  end

  def status_active(status)
    Merchant.update_attribute("status",status)
  end

  def check_admin
    if current_user && current_user.is_admin?
      return true
    else
      redirect_to "/", notice: "You are not authorised for this page."
    end
  end

  def check_manager
    if current_user && current_user.is_manager?
      return true
    else
      redirect_to "/", notice: "You are not authorised for this page."
    end
  end

  def check_executive
    if current_user && current_user.is_executive?
      return true
    else
      redirect_to "/", notice: "You are not authorised for this page."
    end
  end

  def check_merchant
    if current_user && current_user.is_merchant?
      return true
    else
      redirect_to "/", notice: "You are not authorised for this page."
    end
  end

  def check_not_merchant
    if current_user && current_user.not_merchant?
      return true
    else
      redirect_to "/", notice: "You are not authorised for this page."
    end
  end


  private

  def after_update_path_for(resource)
    destroy_user_session_path
  end

end
