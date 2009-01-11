module Mjs
  module PageObject
    private
      def page
        @page ||= Mjs::JavaScriptContext.new
      end

      def render(*args)
        if args[0].is_a?(Mjs::JavaScriptContext)
          args[0].to_s
        else
          super
        end
      end
  end
end
