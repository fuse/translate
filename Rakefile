require 'rubygems'
require 'rake/gempackagetask'
require 'rake/testtask'
require 'rake/rdoctask'
require 'rake/contrib/rubyforgepublisher'
require 'rubyforge'

SPEC = Gem::Specification.new do |s| 
  s.name							= "wrtranslate"
  s.version						= "0.2"
  s.author						= "Martin Catty"
  s.email							= "martin@noremember.org"
  s.homepage					= "http://github.com/fuse/translate"
	s.rubyforge_project	= "wrtranslate"
  s.summary						= "translate provide an easy way to translate word or expression using wordreference.com"
  s.description				= "translate make get requests and parse the result using hpricot. You can use it inside an other program or directly via command line."
  s.files							= [ "Rakefile", "install.rb", "uninstall.rb", "README", "LICENCE" ] +
                          Dir.glob("{bin,doc,lib,test}/**/*")
  s.bindir						= "bin"
	s.require_path			= "lib"
  s.test_files				= "test/translate_test.rb"
  s.has_rdoc					= true
  s.extra_rdoc_files	= ["README"]
	s.executables				=	"translate"
  s.add_dependency("hpricot")
end

desc 'Run all tests by default'
task :default => :test

task :gem
Rake::GemPackageTask.new(SPEC) do |pkg|
  pkg.need_zip			= true
  pkg.need_tar_bz2 	= true
end

desc "Install the application"
task :install do
  ruby "install.rb"
end

desc "Publish documentation to RubyForge"
task :publish_doc => [:rdoc] do
  rf = Rake::RubyForgePublisher.new(SPEC.rubyforge_project, 'fuse')
  rf.upload
  puts "Published documentation to RubyForge"
end

desc "Release gem #{SPEC.name}-#{SPEC.version}.gem"
task :release => [:gem, :publish_doc] do
  rf = RubyForge.new.configure
  puts "Logging in"
  rf.login

  puts "Releasing #{SPEC.name} v.#{SPEC.version}"

  files = Dir.glob('pkg/*.{zip,bz2,gem}')
  rf.add_release SPEC.rubyforge_project, SPEC.rubyforge_project, SPEC.version, *files
end

Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.title    = 'Translate'
  rdoc.options << '--line-numbers' << '--inline-source'
	rdoc.options << '--charset' << 'utf-8'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
