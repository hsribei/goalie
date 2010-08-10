class PublicErrorsController < ActionController::Base

  # 403
  def forbidden
  end

  # 404
  def not_found
  end

  # 405
  def method_not_allowed
    render :action => 'internal_server_error'
  end

  # 409
  def conflict
    render :action => 'internal_server_error'
  end

  # 422
  def unprocessable_entity
  end

  # 500
  def internal_server_error
  end

  # 501
  def not_implemented
    render :action => 'internal_server_error'
  end

end
