require 'active_support/core_ext/exception'
require 'active_support/notifications'
require 'action_dispatch/http/request'

# This middleware rescues any exception returned by the application
# and renders nice exception pages.
class CustomErrorPages
  LOCALHOST = [/^127\.0\.0\.\d{1,3}$/, "::1", /^0:0:0:0:0:0:0:1(%.*)?$/].freeze

  cattr_accessor :rescue_responses
  @@rescue_responses = Hash.new(:internal_server_error)
  @@rescue_responses.update({
    'ActionController::RoutingError'             => :not_found,
    'AbstractController::ActionNotFound'         => :not_found,
    'ActiveRecord::RecordNotFound'               => :not_found,
    'ActiveRecord::StaleObjectError'             => :conflict,
    'ActiveRecord::RecordInvalid'                => :unprocessable_entity,
    'ActiveRecord::RecordNotSaved'               => :unprocessable_entity,
    'ActionController::MethodNotAllowed'         => :method_not_allowed,
    'ActionController::NotImplemented'           => :not_implemented,
    'ActionController::InvalidAuthenticityToken' => :unprocessable_entity
  })

  FAILSAFE_RESPONSE = [
    500,
    {'Content-Type' => 'text/html'},
    ["<html><body><h1>500 Internal Server Error</h1>" <<
     "If you are the administrator of this website, then please read " <<
     "this web application's log file and/or the web server's log " <<
     "file to find out what went wrong.</body></html>"]
   ]

  def initialize(app, consider_all_requests_local = false)
    @app = app
    @consider_all_requests_local = consider_all_requests_local
  end

  def call(env)
    status, headers, body = @app.call(env)

    # Only this middleware cares about RoutingError. So, let's just
    # raise it here.
    # TODO: refactor this middleware to handle the X-Cascade scenario
    # without having to raise an exception.
    if headers['X-Cascade'] == 'pass'
      raise(ActionController::RoutingError,
            "No route matches #{env['PATH_INFO'].inspect}")
    end

    [status, headers, body]
  rescue Exception => exception
    render_exception(env, exception)
  end

  private
  def render_exception(env, exception)
    log_error(exception)

    request = ActionDispatch::Request.new(env)
    if @consider_all_requests_local || local_request?(request)
      rescue_action_locally(request, exception)
    else
      rescue_action_in_public(request, exception)
    end
  rescue Exception => failsafe_error
    $stderr.puts("Error during failsafe response: #{failsafe_error}\n" <<
                 "#{failsafe_error.backtrace * "\n  "}")
    FAILSAFE_RESPONSE
  end

  # Render detailed diagnostics for unhandled exceptions rescued from
  # a controller action.
  def rescue_action_locally(request, exception)
    require 'custom_error_pages/app/controllers/local_errors_controller'

    # TODO this should probably move to the controller, that is, have
    # http error codes map directly to controller actions, then let
    # controller handle different exception classes however it wants
    rescue_actions = Hash.new('diagnostics')
    rescue_actions.update({
      'ActionView::MissingTemplate'         => 'missing_template',
      'ActionController::RoutingError'      => 'routing_error',
      'AbstractController::ActionNotFound'  => 'unknown_action',
      'ActionView::Template::Error'         => 'template_error'
    })

    error_params = {
      :request => request, :exception => exception,
      :application_trace => application_trace(exception),
      :framework_trace => framework_trace(exception),
      :full_trace => full_trace(exception)
    }
    request.env['custom_error_pages.error_params'] = error_params
    action = rescue_actions[exception.class.name]
    response = LocalErrorsController.action(action).call(request.env).last
    render(status_code(exception), response.body)
  end

  def rescue_action_in_public(request, exception)
    require 'custom_error_pages/app/controllers/public_errors_controller'

    error_params = {
      :request => request, :exception => exception,
      :application_trace => application_trace(exception),
      :framework_trace => framework_trace(exception),
      :full_trace => full_trace(exception)
    }
    request.env['custom_error_pages.error_params'] = error_params
    action = @@rescue_responses[exception.class.name]
    response = PublicErrorsController.action(action).call(request.env).last
    render(status_code(exception), response.body)
  end

  # True if the request came from localhost, 127.0.0.1.
  def local_request?(request)
    LOCALHOST.any? { |local_ip|
      local_ip === request.remote_addr && local_ip === request.remote_ip
    }
  end

  def status_code(exception)
    Rack::Utils.status_code(@@rescue_responses[exception.class.name])
  end

  def render(status, body)
    [status,
     {'Content-Type' => 'text/html', 'Content-Length' => body.bytesize.to_s},
     [body]]
  end

  def public_path
    defined?(Rails.public_path) ? Rails.public_path : 'public_path'
  end

  def log_error(exception)
    return unless logger

    ActiveSupport::Deprecation.silence do
      message = "\n#{exception.class} (#{exception.message}):\n"

      if exception.respond_to?(:annoted_source_code)
        message << exception.annoted_source_code
      end

      message << "  " << application_trace(exception).join("\n  ")
      logger.fatal("#{message}\n\n")
    end
  end

  def application_trace(exception)
    clean_backtrace(exception, :silent)
  end

  def framework_trace(exception)
    clean_backtrace(exception, :noise)
  end

  def full_trace(exception)
    clean_backtrace(exception, :all)
  end

  def clean_backtrace(exception, *args)
    defined?(Rails) && Rails.respond_to?(:backtrace_cleaner) ?
    Rails.backtrace_cleaner.clean(exception.backtrace, *args) :
      exception.backtrace
  end

  def logger
    defined?(Rails.logger) ? Rails.logger : Logger.new($stderr)
  end
end
