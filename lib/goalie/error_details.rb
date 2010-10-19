require 'active_support/concern'

module Goalie
  module ErrorDetails
    extend ActiveSupport::Concern
    
    included do
      before_filter :set_error_instance_variables
    end

    private

    def set_error_instance_variables
      error_params = env['goalie.error_params']

      error_params.each do |name, value|
        instance_variable_set("@#{name}", value)
      end
    end
    
  end
end