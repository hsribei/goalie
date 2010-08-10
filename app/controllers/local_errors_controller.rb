class LocalErrorsController < ActionController::Base

  before_filter :set_error_instance_variables

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

  private
  def set_error_instance_variables
    error_params = env['goalie.error_params']

    error_params.each do |name, value|
      instance_variable_set("@#{name}", value)
    end
  end

end
