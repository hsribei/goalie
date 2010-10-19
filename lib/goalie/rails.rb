module Goalie
  class Engine < Rails::Engine

    initializer "goalie.add_middleware" do |app|
      app.middleware.insert_after 'ActionDispatch::RemoteIp', Goalie::CustomErrorPages, app.config.consider_all_requests_local
      app.middleware.delete 'ActionDispatch::ShowExceptions'
    end

  end
end
