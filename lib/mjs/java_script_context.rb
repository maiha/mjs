require 'mjs/utils'

#
# This file is almost derived from prototype_helper.rb of RoR
#
module Mjs
        class JavaScriptContext #:nodoc:

          ######################################################################
          ### define :each method for Rack::Response
          ### because Merb::Rack::StreamWrapper can't create response body correctly
          
          def each(&callback)
            callback.call(to_s)
          end

          def initialize
            @lines = []
          end
  
          def to_s
            javascript = @lines * $/ 
          end

          # Returns a element reference by finding it through +id+ in the DOM. This element can then be
          # used for further method calls. Examples:
          #
          #   page['blank_slate']                  # => $('blank_slate');
          #   page['blank_slate'].show             # => $('blank_slate').show();
          #   page['blank_slate'].show('first').up # => $('blank_slate').show('first').up();
          #
          # You can also pass in a record, which will use ActionController::RecordIdentifier.dom_id to lookup
          # the correct id:
          #
          #   page[@post]     # => $('post_45')
          #   page[Post.new]  # => $('new_post')
          def [](id)
            case id
            when Symbol
              JavaScriptElementProxy.new(self, "##{id}")
            when String, NilClass
              JavaScriptElementProxy.new(self, id)
            else
              raise NotImplementedError, "[MJS] RecordIdentifier.dom_id(id)"
              JavaScriptElementProxy.new(self, ActionController::RecordIdentifier.dom_id(id))
            end
          end

          # Returns an object whose <tt>to_json</tt> evaluates to +code+. Use this to pass a literal JavaScript
          # expression as an argument to another JavaScriptGenerator method.
          def literal(code)
            raise NotImplementedError, "[MJS] ActiveSupport::JSON::Variable.new(code.to_s)"
            ActiveSupport::JSON::Variable.new(code.to_s)
          end

          # Returns a collection reference by finding it through a CSS +pattern+ in the DOM. This collection can then be
          # used for further method calls. Examples:
          #
          #   page.select('p')                      # => $$('p');
          #   page.select('p.welcome b').first      # => $$('p.welcome b').first();
          #   page.select('p.welcome b').first.hide # => $$('p.welcome b').first().hide();
          #
          # You can also use prototype enumerations with the collection.  Observe:
          #
          #   # Generates: $$('#items li').each(function(value) { value.hide(); });
          #   page.select('#items li').each do |value|
          #     value.hide
          #   end
          #
          # Though you can call the block param anything you want, they are always rendered in the
          # javascript as 'value, index.'  Other enumerations, like collect() return the last statement:
          #
          #   # Generates: var hidden = $$('#items li').collect(function(value, index) { return value.hide(); });
          #   page.select('#items li').collect('hidden') do |item|
          #     item.hide
          #   end
          #
          def select(pattern)
            JavaScriptElementCollectionProxy.new(self, pattern)
          end

          # Inserts HTML at the specified +position+ relative to the DOM element
          # identified by the given +id+.
          #
          # +position+ may be one of:
          #
          # <tt>:top</tt>::    HTML is inserted inside the element, before the
          #                    element's existing content.
          # <tt>:bottom</tt>:: HTML is inserted inside the element, after the
          #                    element's existing content.
          # <tt>:before</tt>:: HTML is inserted immediately preceding the element.
          # <tt>:after</tt>::  HTML is inserted immediately following the element.
          #
          # +options_for_render+ may be either a string of HTML to insert, or a hash
          # of options to be passed to ActionView::Base#render.  For example:
          #
          #   # Insert the rendered 'navigation' partial just before the DOM
          #   # element with ID 'content'.
          #   # Generates: Element.insert("content", { before: "-- Contents of 'navigation' partial --" });
          #   page.insert_html :before, 'content', :partial => 'navigation'
          #
          #   # Add a list item to the bottom of the <ul> with ID 'list'.
          #   # Generates: Element.insert("list", { bottom: "<li>Last item</li>" });
          #   page.insert_html :bottom, 'list', '<li>Last item</li>'
          #
          def insert_html(position, id, *options_for_render)
            content = javascript_object_for(render(*options_for_render))
            record "Element.insert(\"#{id}\", { #{position.to_s.downcase}: #{content} });"
          end

          # Replaces the inner HTML of the DOM element with the given +id+.
          #
          # +options_for_render+ may be either a string of HTML to insert, or a hash
          # of options to be passed to ActionView::Base#render.  For example:
          #
          #   # Replace the HTML of the DOM element having ID 'person-45' with the
          #   # 'person' partial for the appropriate object.
          #   # Generates:  Element.update("person-45", "-- Contents of 'person' partial --");
          #   page.replace_html 'person-45', :partial => 'person', :object => @person
          #
          def replace_html(id, *options_for_render)
            call 'Element.update', id, render(*options_for_render)
          end

          # Replaces the "outer HTML" (i.e., the entire element, not just its
          # contents) of the DOM element with the given +id+.
          #
          # +options_for_render+ may be either a string of HTML to insert, or a hash
          # of options to be passed to ActionView::Base#render.  For example:
          #
          #   # Replace the DOM element having ID 'person-45' with the
          #   # 'person' partial for the appropriate object.
          #   page.replace 'person-45', :partial => 'person', :object => @person
          #
          # This allows the same partial that is used for the +insert_html+ to
          # be also used for the input to +replace+ without resorting to
          # the use of wrapper elements.
          #
          # Examples:
          #
          #   <div id="people">
          #     <%= render :partial => 'person', :collection => @people %>
          #   </div>
          #
          #   # Insert a new person
          #   #
          #   # Generates: new Insertion.Bottom({object: "Matz", partial: "person"}, "");
          #   page.insert_html :bottom, :partial => 'person', :object => @person
          #
          #   # Replace an existing person
          #
          #   # Generates: Element.replace("person_45", "-- Contents of partial --");
          #   page.replace 'person_45', :partial => 'person', :object => @person
          #
          def replace(id, *options_for_render)
            call 'Element.replace', id, render(*options_for_render)
          end

          # Removes the DOM elements with the given +ids+ from the page.
          #
          # Example:
          #
          #  # Remove a few people
          #  # Generates: ["person_23", "person_9", "person_2"].each(Element.remove);
          #  page.remove 'person_23', 'person_9', 'person_2'
          #
          def remove(*ids)
            loop_on_multiple_args 'Element.remove', ids
          end

          # Shows hidden DOM elements with the given +ids+.
          #
          # Example:
          #
          #  # Show a few people
          #  # Generates: ["person_6", "person_13", "person_223"].each(Element.show);
          #  page.show 'person_6', 'person_13', 'person_223'
          #
          def show(*ids)
            loop_on_multiple_args 'Element.show', ids
          end

          # Hides the visible DOM elements with the given +ids+.
          #
          # Example:
          #
          #  # Hide a few people
          #  # Generates: ["person_29", "person_9", "person_0"].each(Element.hide);
          #  page.hide 'person_29', 'person_9', 'person_0'
          #
          def hide(*ids)
            loop_on_multiple_args 'Element.hide', ids
          end

          # Toggles the visibility of the DOM elements with the given +ids+.
          # Example:
          #
          #  # Show a few people
          #  # Generates: ["person_14", "person_12", "person_23"].each(Element.toggle);
          #  page.toggle 'person_14', 'person_12', 'person_23'      # Hides the elements
          #  page.toggle 'person_14', 'person_12', 'person_23'      # Shows the previously hidden elements
          #
          def toggle(*ids)
            loop_on_multiple_args 'Element.toggle', ids
          end

          # Displays an alert dialog with the given +message+.
          #
          # Example:
          #
          #   # Generates: alert('This message is from Rails!')
          #   page.alert('This message is from Rails!')
          def alert(message)
            call 'alert', message
          end

          # Redirects the browser to the given +location+ using JavaScript, in the same form as +url_for+.
          #
          # Examples:
          #
          #  # Generates: window.location.href = "/mycontroller";
          #  page.redirect_to(:action => 'index')
          #
          #  # Generates: window.location.href = "/account/signup";
          #  page.redirect_to(:controller => 'account', :action => 'signup')
          def redirect_to(location)
            url = location.is_a?(String) ? location : @context.url_for(location)
            record "window.location.href = #{url.inspect}"
          end

          # Reloads the browser's current +location+ using JavaScript
          #
          # Examples:
          #
          #  # Generates: window.location.reload();
          #  page.reload
          def reload
            record 'window.location.reload()'
          end

          # Calls the JavaScript +function+, optionally with the given +arguments+.
          #
          # If a block is given, the block will be passed to a new JavaScriptGenerator;
          # the resulting JavaScript code will then be wrapped inside <tt>function() { ... }</tt>
          # and passed as the called function's final argument.
          #
          # Examples:
          #
          #   # Generates: Element.replace(my_element, "My content to replace with.")
          #   page.call 'Element.replace', 'my_element', "My content to replace with."
          #
          #   # Generates: alert('My message!')
          #   page.call 'alert', 'My message!'
          #
          #   # Generates:
          #   #     my_method(function() {
          #   #       $("one").show();
          #   #       $("two").hide();
          #   #    });
          #   page.call(:my_method) do |p|
          #      p[:one].show
          #      p[:two].hide
          #   end
          def call(function, *arguments, &block)
            record "#{function}(#{arguments_for_call(arguments, block)})"
          end

          # Assigns the JavaScript +variable+ the given +value+.
          #
          # Examples:
          #
          #  # Generates: my_string = "This is mine!";
          #  page.assign 'my_string', 'This is mine!'
          #
          #  # Generates: record_count = 33;
          #  page.assign 'record_count', 33
          #
          #  # Generates: tabulated_total = 47
          #  page.assign 'tabulated_total', @total_from_cart
          #
          def assign(variable, value)
            record "#{variable} = #{javascript_object_for(value)}"
          end

          # Writes raw JavaScript to the page.
          #
          # Example:
          #
          #  page << "alert('JavaScript with Prototype.');"
          def <<(javascript)
            @lines << javascript
          end

          # Executes the content of the block after a delay of +seconds+. Example:
          #
          #   # Generates:
          #   #     setTimeout(function() {
          #   #     ;
          #   #     new Effect.Fade("notice",{});
          #   #     }, 20000);
          #   page.delay(20) do
          #     page.visual_effect :fade, 'notice'
          #   end
          def delay(seconds = 1)
            record "setTimeout(function() {\n\n"
            yield
            record "}, #{(seconds * 1000).to_i})"
          end

          # Starts a script.aculo.us visual effect. See
          # ActionView::Helpers::ScriptaculousHelper for more information.
          def visual_effect(name, id = nil, options = {})
            record @context.send(:visual_effect, name, id, options)
          end

          # Creates a script.aculo.us sortable element. Useful
          # to recreate sortable elements after items get added
          # or deleted.
          # See ActionView::Helpers::ScriptaculousHelper for more information.
          def sortable(id, options = {})
            record @context.send(:sortable_element_js, id, options)
          end

          # Creates a script.aculo.us draggable element.
          # See ActionView::Helpers::ScriptaculousHelper for more information.
          def draggable(id, options = {})
            record @context.send(:draggable_element_js, id, options)
          end

          # Creates a script.aculo.us drop receiving element.
          # See ActionView::Helpers::ScriptaculousHelper for more information.
          def drop_receiving(id, options = {})
            record @context.send(:drop_receiving_element_js, id, options)
          end

          private
            def loop_on_multiple_args(method, ids)
              record(ids.size>1 ?
                "#{javascript_object_for(ids)}.each(#{method})" :
                "#{method}(#{ids.first.to_json})")
            end

            def page
              self
            end

            def record(line)
              returning line = "#{line.to_s.chomp.gsub(/\;\z/, '')};" do
                self << line
              end
            end

            def render(*options_for_render)
              old_format = @context && @context.template_format
              @context.template_format = :html if @context
              Hash === options_for_render.first ?
                @context.render(*options_for_render) :
                  options_for_render.first.to_s
            ensure
              @context.template_format = old_format if @context
            end

            def javascript_object_for(object)
              object.respond_to?(:to_json) ? object.to_json : object.inspect

            # TODO: to_json is too buggy!
            rescue JSON::GeneratorError
              if object.is_a?(String)
                object.inspect
              else
                raise
              end
            end

            def arguments_for_call(arguments, block = nil)
              arguments << block_to_function(block) if block
              arguments.map { |argument| javascript_object_for(argument) }.join ', '
            end

            def block_to_function(block)
              generator = self.class.new(@context, &block)
              literal("function() { #{generator.to_s} }")
            end

            def method_missing(method, *arguments)
              JavaScriptProxy.new(self, Mjs::Utils.camelize(method))
            end
        end                       # class JavaScriptGenerator

#    class JavaScriptProxy < ActiveSupport::BasicObject #:nodoc:
    # [TODO] BlackSlate is not supported yet
    class JavaScriptProxy

      def initialize(generator, root = nil)
        @generator = generator
        @generator << root if root
      end

      private
        def method_missing(method, *arguments, &block)
          if method.to_s =~ /(.*)=$/
            assign($1, arguments.first)
          else
            call("#{Mjs::Utils.camelize(method, :lower)}", *arguments, &block)
          end
        end

        def call(function, *arguments, &block)
          append_to_function_chain!("#{function}(#{@generator.send(:arguments_for_call, arguments, block)})")
          self
        end

        def assign(variable, value)
          append_to_function_chain!("#{variable} = #{@generator.send(:javascript_object_for, value)}")
        end

        def function_chain
          @function_chain ||= @generator.instance_variable_get(:@lines)
        end

        def append_to_function_chain!(call)
          function_chain[-1].chomp!(';')
          function_chain[-1] += ".#{call};"
        end
    end

    class JavaScriptElementProxy < JavaScriptProxy #:nodoc:
      def initialize(generator, id)
        @id = id
        super(generator, "$(#{id.to_json})")
      end

      # Allows access of element attributes through +attribute+. Examples:
      #
      #   page['foo']['style']                  # => $('foo').style;
      #   page['foo']['style']['color']         # => $('blank_slate').style.color;
      #   page['foo']['style']['color'] = 'red' # => $('blank_slate').style.color = 'red';
      #   page['foo']['style'].color = 'red'    # => $('blank_slate').style.color = 'red';
      def [](attribute)
        append_to_function_chain!(attribute)
        self
      end

      def []=(variable, value)
        assign(variable, value)
      end

      def replace_html(*options_for_render)
        call 'update', @generator.send(:render, *options_for_render)
      end

      def replace(*options_for_render)
        call 'replace', @generator.send(:render, *options_for_render)
      end

      def reload(options_for_replace = {})
        replace(options_for_replace.merge({ :partial => @id.to_s }))
      end

    end

    class JavaScriptVariableProxy < JavaScriptProxy #:nodoc:
      def initialize(generator, variable)
        @variable = variable
        @empty    = true # only record lines if we have to.  gets rid of unnecessary linebreaks
        super(generator)
      end

      # The JSON Encoder calls this to check for the +to_json+ method
      # Since it's a blank slate object, I suppose it responds to anything.
      def respond_to?(method)
        true
      end

      def to_json(options = nil)
        @variable
      end

      private
        def append_to_function_chain!(call)
          @generator << @variable if @empty
          @empty = false
          super
        end
    end
end
