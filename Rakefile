relative_path = lambda do |relative_path_parts|
  ::File.join(::File.dirname(__FILE__),*relative_path_parts)
end
require relative_path.call(%w{vendor gems environment})
Bundler.require_env
require 'spec/rake/spectask'
require 'cucumber/rake/task'
require 'resque/tasks'
require 'lib/workers/downloader'


namespace :spec do 
  spec_opts = File.read("spec/spec.opts").split(/\n/)
  ruby_opts = ["-r#{relative_path.call %w{spec spec_helper} }"]
  desc "Test Units with rspec"
  Spec::Rake::SpecTask.new "unit" do |s|
    s.spec_opts = spec_opts
    s.ruby_opts = ruby_opts
    s.spec_files = FileList["spec/units/*_spec.rb"]
  end
  
  Spec::Rake::SpecTask.new "external" do |s|
    s.spec_opts = spec_opts
    s.ruby_opts = ruby_opts
    s.spec_files = FileList["spec/external/*_spec.rb"]
  end

  Spec::Rake::SpecTask.new do |s|
    s.spec_opts = spec_opts
    s.ruby_opts = ruby_opts
    s.spec_files = FileList["spec/**/*_spec.rb"]
  end
end
desc "Test with Cucumber"
Cucumber::Rake::Task.new("cucumber") do |t|
  t.cucumber_opts = %w{--format pretty features}
end
