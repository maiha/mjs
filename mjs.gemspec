# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mjs}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["maiha"]
  s.date = %q{2010-02-19}
  s.description = %q{A ruby library that offers Ajax actions like RJS with jQuery}
  s.email = %q{maiha@wota.jp}
  s.extra_rdoc_files = ["README", "LICENSE", "TODO"]
  s.files = ["LICENSE", "README", "Rakefile", "TODO", "lib/mjs.rb", "lib/mjs", "lib/mjs/spectasks.rb", "lib/mjs/helper.rb", "lib/mjs/utils.rb", "lib/mjs/sinatra.rb", "lib/mjs/merb.rb", "lib/mjs/page_object.rb", "lib/mjs/slicetasks.rb", "lib/mjs/merbtasks.rb", "lib/mjs/java_script_context.rb", "spec/mjs_spec.rb", "spec/spec_helper.rb", "spec/requests", "spec/requests/main_spec.rb", "app/views", "app/views/layout", "app/views/layout/mjs.html.erb", "app/views/main", "app/views/main/index.html.erb", "app/controllers", "app/controllers/main.rb", "app/controllers/application.rb", "app/helpers", "app/helpers/application_helper.rb", "public/stylesheets", "public/stylesheets/master.css", "public/javascripts", "public/javascripts/master.js", "stubs/app", "stubs/app/controllers", "stubs/app/controllers/main.rb", "stubs/app/controllers/application.rb"]
  s.homepage = %q{http://github.com/maiha/mjs}
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{merb}
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{A ruby library that offers Ajax actions like RJS with jQuery}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<extlib>, [">= 0.9.14"])
    else
      s.add_dependency(%q<extlib>, [">= 0.9.14"])
    end
  else
    s.add_dependency(%q<extlib>, [">= 0.9.14"])
  end
end
