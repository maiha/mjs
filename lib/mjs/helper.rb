require 'mjs/java_script_context'

module Mjs
  module Helper
    def page
      @page ||= Mjs::JavaScriptContext.new
    end

    # override! :link_to # for Ajax
    def link_to(name, url='', opts={})
      opts[:href]   ||= url
      if url.is_a?(DataMapper::Resource)
        record = opts[:href]
        if record.new_record?
          opts[:href] = resource(record.class.name.downcase.pluralize.intern, :new)
        else
          opts[:href] = resource(record)
        end
      end

      opts[:remote] ||= true if opts[:submit]
      return super unless opts.delete(:remote)

      submit = opts.delete(:submit)
      target =
        case submit
        when Symbol then "$('##{submit} input')"
        when String then "$('#{submit}')"
        when NilClass    # GET requst
        else
          raise ArgumentError, "link_to :submit expects Symbol or String, but got #{submit.class.name}"
        end

      ajax = submit ? "$.post('#{opts[:href]}', #{target}.serialize(), null, 'script');" : "$.getScript('#{opts[:href]}')"
      opts[:onclick] = "#{opts.delete(:onclick)}; #{ajax}; return false;"
      opts[:href] = '#'
      %{<a #{ opts.to_xml_attributes }>#{name}</a>}
    end
  end
end
