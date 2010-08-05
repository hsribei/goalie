class PublicErrorsController < ActionController::Base
  self.append_view_path "#{File.dirname(__FILE__)}/../views"

  def internal_server_error
  end

  def not_found
  end

  def unprocessable_entity
  end

  def conflict
    render :action => 'internal_server_error'
  end

  def method_not_allowed
    render :action => 'internal_server_error'
  end

  def not_implemented
    render :action => 'internal_server_error'
  end

end
