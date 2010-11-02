require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

desc 'Default: run specs.'
task :default => :specs

#desc 'Test the newsletter_boy plugin.'
#Rake::TestTask.new(:test) do |t|
  #t.libs << 'lib'
  #t.libs << 'test'
  #t.pattern = 'test/**/*_test.rb'
  #t.verbose = true
#end

desc "Run all specs"
Spec::Rake::SpecTask.new('specs') do |t|
  t.spec_files = FileList['spec/*_spec.rb']
end

desc 'Generate documentation for the newsletter_boy plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Lettr'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
