module Goalie
  class Engine < Rails::Engine

    initializer "goalie.add_middleware" do |app|
      app.middleware.delete 'ShowExceptions'
      app.middleware.use Goalie::CustomErrorPages
    end

  end
end
