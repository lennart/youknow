require 'spec/rake/spectask'
require 'cucumber/rake/task'


desc "Test with rspec"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_opts = File.read("spec/spec.opts").split(/\n/)
  t.spec_files = FileList["spec/*_spec.rb"]
end

desc "Test with Cucumber+Watir"
Cucumber::Rake::Task.new("cucumber") do |t|
  t.cucumber_opts = %w{-b --format pretty features}
end
