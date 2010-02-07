require "config/boot"
require 'spec/rake/spectask'
require 'cucumber/rake/task'
require 'erb'
require 'fileutils'

desc "Run all specs"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = File.read("spec/spec.opts").split(/\n/)
  t.spec_opts  << "-rspec/spec_helper"
  t.spec_files = FileList["spec/**/*_spec.rb"]
end

namespace :spec do
  Dir["spec/*"].select {|d| File.directory? d }.each do |dir|
    folder = File.basename dir
    desc "Run #{folder} specs"
    Spec::Rake::SpecTask.new(folder) do |t|
      t.spec_opts = File.read("spec/spec.opts").split(/\n/)
      t.spec_opts  << "-rspec/spec_helper"
      t.spec_files = FileList["spec/#{folder}/*_spec.rb"]
    end
  end
end

desc "Test with Cucumber"
Cucumber::Rake::Task.new("features") do |t|
  t.cucumber_opts = %w{--format pretty features}
end

desc "Setup new Environment"
task :setup => :reset do
  title = "youknow"
  author = "Lennart Melzer"
  environments = %w{development test production}
  template = ERB.new File.read("config/environment.rb.erb")
  File.open "config/environment.rb", "w" do |f|
    f.write template.result(binding)
  end
end

desc "Reset Environment"
task :reset do
  if File.exists?("config/environment.rb")
    FileUtils.rm "config/environment.rb", :verbose => true
  end
  %w{app tmp log}.each do |dir|
    FileUtils.mkdir sinatra(dir), :verbose => true unless File.exists? sinatra(dir)
  end
end

namespace :compass do
  desc "Compass Update" 
  task :watch => :update do
    ARGV=%w{-c config/compass.config -u} << __FILE__
    load 'bin/compass'
  end

  desc "Compass Watching"
  task :watch => :update do
    ARGV=%w{-c config/compass.config -w} << __FILE__
    load 'bin/compass'
  end

  desc "Compass Setup"
  task :setup do
    ARGV=%w{-c config/compass.config} << __FILE__
    load 'bin/compass'
  end
end
