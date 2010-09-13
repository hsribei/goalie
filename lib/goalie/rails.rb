module Goalie
  class Engine < Rails::Engine

    initializer "goalie.add_middleware" do |app|
      app.middleware.insert_after 'ActionDispatch::ShowExceptions',  Goalie::CustomErrorPages
      app.middleware.delete 'ActionDispatch::ShowExceptions'
    end

  end
end
