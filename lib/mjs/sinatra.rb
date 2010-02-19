if defined?(Sinatra)

  module Mjs
    module Helper
      def self.registered(app)
        app.helpers Mjs::Helper
      end
    end
  end

end
