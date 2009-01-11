if defined?(Merb::Plugins)

  $:.unshift File.dirname(__FILE__)

  dependency 'merb-slices', :immediate => true
  Merb::Plugins.add_rakefiles "mjs/merbtasks", "mjs/slicetasks", "mjs/spectasks"

  # Register the Slice for the current host application
  Merb::Slices::register(__FILE__)
  
  # Slice configuration - set this in a before_app_loads callback.
  # By default a Slice uses its own layout, so you can swicht to 
  # the main application layout or no layout at all if needed.
  # 
  # Configuration options:
  # :layout - the layout to use; defaults to :mjs
  # :mirror - which path component types to use on copy operations; defaults to all
  Merb::Slices::config[:mjs][:layout] ||= :mjs
  
  # All Slice code is expected to be namespaced inside a module
  module Mjs
    
    # Slice metadata
    self.description = "A slice for the Merb framework that offers Ajax actions like RJS with jQuery"
    self.version = "0.0.1"
    self.author = "maiha"
    
    # Stub classes loaded hook - runs before LoadClasses BootLoader
    # right after a slice's classes have been loaded internally.
    def self.loaded
      require 'mjs/helper'
    end
    
    # Initialization hook - runs before AfterAppLoads BootLoader
    def self.init
      Merb::Controller.send(:include, ::Mjs::Helper)
    end
    
    # Activation hook - runs after AfterAppLoads BootLoader
    def self.activate
    end
    
    # Deactivation hook - triggered by Merb::Slices.deactivate(Mjs)
    def self.deactivate
    end
    
    # Setup routes inside the host application
    #
    # @param scope<Merb::Router::Behaviour>
    #  Routes will be added within this scope (namespace). In fact, any 
    #  router behaviour is a valid namespace, so you can attach
    #  routes at any level of your router setup.
    #
    # @note prefix your named routes with :mjs_
    #   to avoid potential conflicts with global named routes.
    def self.setup_router(scope)
      # example of a named route
      scope.match('/index(.:format)').to(:controller => 'main', :action => 'index').name(:index)
      # the slice is mounted at /mjs - note that it comes before default_routes
      scope.match('/').to(:controller => 'main', :action => 'index').name(:home)
      # enable slice-level default routes by default
      scope.default_routes
    end
    
  end
  
  # Setup the slice layout for Mjs
  #
  # Use Mjs.push_path and Mjs.push_app_path
  # to set paths to mjs-level and app-level paths. Example:
  #
  # Mjs.push_path(:application, Mjs.root)
  # Mjs.push_app_path(:application, Merb.root / 'slices' / 'mjs')
  # ...
  #
  # Any component path that hasn't been set will default to Mjs.root
  #
  # Or just call setup_default_structure! to setup a basic Merb MVC structure.
  Mjs.setup_default_structure!
  
  # Add dependencies for other Mjs classes below. Example:
  # dependency "mjs/other"


  
end
