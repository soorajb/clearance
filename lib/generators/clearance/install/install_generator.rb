require 'diesel/generators/install_base'

module Clearance
  module Generators
    class InstallGenerator < Diesel::Generators::InstallBase
      def install
        template "clearance.rb", "config/initializers/clearance.rb"

        inject_into_class "app/controllers/application_controller.rb", ApplicationController do
          "  include Clearance::Authentication\n"
        end

        user_model = "app/models/user.rb"
        if File.exists?(user_model)
          inject_into_class user_model, User do
            "include Clearance::User"
          end
        else
          template "user.rb", user_model
        end

        if File.exists?("spec")
          template "spec/factories.rb", "spec/factories/clearance.rb"
        else
          template "spec/factories.rb", "test/factories/clearance.rb"
        end

        readme "README"
      end

      private

      def migrations
          super
      end

    end
  end
end
