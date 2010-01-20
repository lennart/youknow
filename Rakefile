require 'spec/rake/spectask'
require 'cucumber/rake/task'
require 'erb'
require 'fileutils'


desc "Test with rspec"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = File.read("spec/spec.opts").split(/\n/)
  t.spec_files = FileList["spec/*_spec.rb"]
end

desc "Test with Cucumber+Watir"
Cucumber::Rake::Task.new("cucumber") do |t|
  t.cucumber_opts = %w{--format pretty features}
end

desc "Setup new Environment"
task :setup => :reset do
  title = "sinatra-couchbase"
  author = "Lennart Melzer"
  environments = %w{development test integration production}
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
end
