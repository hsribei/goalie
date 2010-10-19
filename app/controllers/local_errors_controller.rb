class LocalErrorsController < ActionController::Base
  include Goalie::ErrorDetails

  def routing_error
  end

  def template_error
  end

  def missing_template
  end

  def unknown_action
  end

  def diagnostics
  end


end
