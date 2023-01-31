# frozen_string_literal: true

# Optionally install bundler tasks if present.
begin
    require 'bundler'

    Bundler.setup
    Bundler::GemHelper.install_tasks
rescue LoadError
end

require 'yard'
require 'rake/testtask'
require 'rake/clean'

desc 'Generate documentation'
YARD::Rake::YardocTask.new(:doc) do |task|
    task.files = ['lib/**/*.rb']
end

desc 'Run the test suite'
Rake::TestTask.new do |t|
    t.verbose = true
    t.libs << 'test'
    t.test_files = [ 'test/test_pdf.rb' ]
end

task :clean do
    Rake::Cleaner.cleanup_files Dir['*.gem', 'doc', 'examples/**/*.pdf']
end

task :default => :test
