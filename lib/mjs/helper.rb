require 'mjs/java_script_context'

module Mjs
  module Helper
    def page
      @page ||= Mjs::JavaScriptContext.new
    end

    def remote_function(opts)
      build_href(opts)
      if opts[:submit]
        "$.ajax(%s);" % options_for_ajax(opts)
      else
        "$.getScript('#{opts[:href]}')"
      end
    end

    # experimental: not tested yet
    def button_to(name, url='', opts={})
      ajax = remote_function(opts)
      opts[:type] = 'button'
      opts[:value] = name
      opts[:remote] ||= true if opts[:submit]
      if opts.delete(:remote)
        ajax = remote_function(opts)
        opts[:onclick] = "#{opts.delete(:onclick)}; #{ajax}; return false;"
      end
      %{<input #{ opts.to_xml_attributes }>}
    end

    # override! :link_to # for Ajax
    def link_to(name, url='', opts={})
      opts[:href]   ||= url
      opts[:remote] ||= true if opts[:submit]
      return super unless opts.delete(:remote)

      ajax = remote_function(opts)
      opts[:onclick] = "#{opts.delete(:onclick)}; #{ajax}; return false;"
      opts[:href] = '#'
      %{<a #{ opts.to_xml_attributes }>#{name}</a>}
    end

    ######################################################################
    ### derived from actionpack

    JS_ESCAPE_MAP = {
      '\\'    => '\\\\',        '</'    => '<\/',
      "\r\n"  => '\n',
      "\n"    => '\n',        "\r"    => '\n',
      '"'     => '\\"',
      "'"     => "\\'" }

    # Escape carrier returns and single and double quotes for JavaScript segments.
    def escape_javascript(javascript)
      if javascript
        javascript.gsub(/(\\|<\/|\r\n|[\n\r"'])/) { JS_ESCAPE_MAP[$1] }
      else
        ''
      end
    end

    private
      def build_href(opts)
        if opts[:href].is_a?(DataMapper::Resource)
          record = opts[:href]
          if record.new_record?
            opts[:href] = resource(record.class.name.downcase.pluralize.intern, :new)
          else
            opts[:href] = resource(record)
          end
        end
        opts
      end

      AJAX_FUNCTIONS = {
        :before      => :beforeSend,
        :before_send => :beforeSend,
        :beforeSend  => :beforeSend,
        :complete    => :complete,
        :success     => :success,
        :error       => :error,
        :dataFilter  => :dataFilter,
        :data_filter => :dataFilter,
        :xhr         => :xhr,
      }

      def options_for_ajax(options)
        js_options = build_callbacks!(options)

        submit = options.delete(:submit)
        target =
          case submit
          when Symbol then "$('##{submit} input')"
          when String then "$('#{submit}')"
          when NilClass    # GET requst
          else
            raise ArgumentError, "link_to :submit expects Symbol or String, but got #{submit.class.name}"
          end

        build_href(options)

        js_options[:type] = "'POST'"
        js_options[:url]  = "'#{options[:href]}'"
        js_options[:data] = "#{target}.serialize()"
        js_options[:dataType] = "'script'"

        options_for_javascript(js_options)
      end

      def options_for_javascript(options)
        if options.empty?
          '{}'
        else
          "{#{options.keys.map { |k| "#{k}:#{options[k]}" }.sort.join(', ')}}"
        end
      end

      def jquery_selector(key)
        case key
        when Symbol then "$('##{key}')"
        when String then "$('#{key}')"
        else
          raise "invalid jquery selector: [#{key.class}] #{key}"
        end
      end

      # this method affects "options"
      def build_callbacks!(options)
        callbacks = {}

        # special callback
        spinner = options.delete(:spinner)
        if spinner
          options[:before]   = [options[:before],   "%s.show()" % jquery_selector(spinner)].compact * ';'
          options[:complete] = [options[:complete], "%s.hide()" % jquery_selector(spinner)].compact * ';'
        end

        options.each do |callback, code|
          if (name = AJAX_FUNCTIONS[callback])
            callbacks[name.to_s] = "function(request){#{code}}"
            options.delete(callback)
          end
        end

        callbacks
      end

  end
end
