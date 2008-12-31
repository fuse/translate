module Translate
	# Translate provides an easy to translate word or expression into another, 
	# using wordreference. This website does'nt provide API yet so I decided 
	# to create this script which make GET requests and parse results using Hpricot.
	# Default translation is english to french but it can be overriden by 
	# providing command line options or config file.
	# Translate can be used directly in command line or inside an other program.
	# 
	# == Command line example
	# 
	# 	$ translate world
	# 	Will translate world from english to french.
	# 	$ translate casa -f it -t en
	# 	Will translate casa from italian to english.
	#
	# If you want to know which language can be used :
	# 	$ translate -l
	# 
	# If you want to know all options of translate :
	# 	$ translate -h
	# 
	# == Setup default options
	# 
	# If you don't want to retype options each time you're using translate, just 
	# create a config file into your home named translate.yml using this syntax :
	# 	translate:
	# 		from: fr
	# 		to: en
	# 		width: 100	
	# 		more: true
	# Priority is given to command line options, config file options and finally 
	# default options.
	# 
	# == How to use in another program ?
	# 
	# You only have to create a new instance or the translation class by giving 
	# the expression to translate and your options and explicitly call translate.
	# 
	# === Example :
	# 
	# translation = Translation.new("maison", { :from => :fr, :to => :en, :more => true })
	# translation.translate
	# 
	# Results are directly available through translation.items

  %w(rubygems net/http hpricot open-uri optparse language string.extend).each do |lib|
    begin 
      require lib 
    rescue LoadError
      puts "Fail to load #{lib}, exiting."
      exit
    end
  end

  # You can change default options below. Default settings translate from english
  # to french without additional translations.
  URL         = 'http://www.wordreference.com/'
	# Default width, can be overriden.
	WIDTH				= 78
	MIN_WIDTH		= 40
	CONFIG_FILE	=	"translate.yml"
    
  class Translation
    attr_accessor :from, :to, :more, :expression, :width, :items, :errors
    OPTIONS     = { :more => false, :from => :en, :to => :fr, :width => WIDTH }
    
	 	# Initialize translation with expression and options.	
		# Ensure width will be an integer, and provides an empty array of items.
		def initialize(expression, options = {})
			self.expression = expression
			options = OPTIONS.merge(options)
			for k in options.keys
				self.send("#{k}=", options[k]) if self.respond_to?(k)
			end
			@items = []
			@width = @width.to_i
		end # initialize

		# Provide the from, to combination. Example: from en to fr will give enfr.
		# Usefull to build the final url.
		def combination
			@combination ||= "#{from}#{to}"
		end # combination

		# Only used when translate is called from command line.
		# Define the separator between two lines.
		def separator
			@separator ||= '-' * width
		end # separator
   
	 	# Parse the document retrieved from tree and add items into 
		# the final results array.	
		def translate
			return nil unless valid?
			continue = false
			@items.clear
			klass = Language.respond_to?("klass_#{combination}") ? Language.send("klass_#{combination}") : "2"
			tree.search("table.Rtbl#{klass}/tr").each do |child|
				head = child.search("td.Head:first").first
				continue = !! (
					head.html =~ /Principal/ || 
					head.attributes['title'] =~ /Principal/ ||
					(head.html =~ /Additional/ and more) ||
					(head.attributes['title'] =~ /Additional/)) if head.respond_to?(:html)
				unless ! continue or child.classes =~ /(evenEx|oddEx)/
					# strip html tags
					description = child.search("td.FrCN#{klass}/*").to_s.sanitize
					translation = child.search("td.ToW#{klass}/*").to_s.sanitize
					@items << Item.new({ 
						:description 	=> description, 
						:translation 	=> translation,
						:new_line			=> ! child.search("td.FrW#{klass}").empty?
					}) unless description.empty? and translation.empty?
				end
			end
		end # translate

		# Only used when translate is called from command line.
		# Print results in the shell.
		def print
			lambda { puts "No results found." ; exit }.call if @items.empty?
			half = (width - 4) / 2 # 4 : 2 slash and space
			puts @items.inject("") { |o, item|
				str  = item == @items.first ? "#{separator}\n#{@expression.center(width, ' ')}\n" : ""
				str  += "#{separator}\n" if item.new_line
				str  += " %-#{half}s|"		% item.description.truncate(half)
				str  += " %-#{half}s\n"  % item.translation.truncate(half)
				str  += "#{separator}\n" if item == @items.last
				o + str
			}
		end # print
		
		# Only used when translate is called from command line.
		# Print errors in the shell.
		def print_errors
			puts @errors.inject("Some errors encountered :") { |str, e|
				str += "\n\t- #{e}"
			}
		end # print_errors

		# Provide the full document retrieved from the url.
		def tree
			@tree ||= Hpricot.parse(retrieve)
		end # tree
  	
	 	# Wordreference full url.	
		def url
			@url ||= URI::parse(URI.escape("#{URL}#{combination}/#{expression}"))
		end # url

		# Check if the translation is valid, ie. options exists and an expression
		# has been providen. Build an array of errors which will be printed to the 
		# end user.
    def valid?
			@errors = []
			@errors << "Expression can't be blank." if expression.blank?
			@errors << "Translation from #{from} to #{to} is not available, use translate -l to show available languages." unless Translate::Language.available_translation?(from, to)
			@errors << "Width must be an integer >= #{MIN_WIDTH}." unless width.is_a?(Integer) and width >= MIN_WIDTH
			@errors.empty?
    end # valid?
    
		# Call a wordreference url, dynamiquely builded with from expression and combination.
  	# We need to provide an User-Agent otherwise we're redirected to yahoo.
		def retrieve
			request = Net::HTTP::Get.new(url.path)
			request.add_field('User-Agent', 'translate')
			Net::HTTP.new(url.host, url.port).request(request).body
		end # retrieve  
  end
  
  class Item
		attr_accessor :description, :translation, :new_line
    
		def initialize(attributes = {})
			for k in attributes.keys
				self.send("#{k}=", attributes[k]) if self.respond_to?(k)
			end
		end # initialize
  end

	# Load options from config file if exists.
	def config
		if has_config_file?
			section = YAML::load(File.open(config_file_path))["translate"]
			return section.nil? ? {} : section.keys.inject({}) { |h, k| 
				h[k.to_sym] = section[k] 
				h
			}
		end
		{}
	end #config

	# Define config file path.
	def config_file_path
		File.join(home, CONFIG_FILE)
	end # config_file_path

	# Check if a config file has been set or not.
	def has_config_file?
		File.readable?(config_file_path)
	end # has_config_file?
  
	# Try to return the home path using environement var. Home path is not 
	# set on the same var on unix & windows.
	def home
		ENV['HOME'] || ENV['USERPROFILE']
	end # home

	# Parse the command line to register user's options or display help or examples.
  def parse_command_line
		options = {}
    OptionParser.new do |@parser|
      @parser.banner = 'Usage: translate word [options]'

      @parser.on('-e', '--example', 'Show some examples.') do |option|
        puts "Examples :\n"
        puts "\t ./translate house (default translation from english to french)"
        puts "\t ./translate house -m (show additional translations)"
        puts "\t ./translate maison -f fr -t en (translate from french to english)"
        puts "\t ./translate -f fr -t en 'se moquer' (use single or double quote to escape multiple words)"
        exit
      end

      @parser.on('-f', '--from language', String, 'Define original language.') do |option|
        options[:from] = option
      end

      @parser.on('-l', '--language', 'Show supported languages / translations.') do |option|
				Translate::Language.available_translations
        exit
      end

      @parser.on('-m', '--more', 'Show additional translations.') do |option|
        options[:more] = option
      end

      @parser.on('-t', '--to language', String, 'Define destination language.') do |option|
        options[:to] = option
      end
      
			@parser.on('-w', '--width number', String, "Define width, min width is #{MIN_WIDTH}.") do |option|
        options[:width] = option
      end

      @parser.on('-v', '--version', String, 'Show version.') do |option|
        puts "translate 0.2 Martin Catty <martin@noremember.org>"
        exit
      end

      @parser.on_tail('-h', '--help', 'Show this message.') do
        puts @parser
        exit
      end
      begin
        @parser.parse!(ARGV)
				expression = ARGV.empty? ? "" : ARGV.shift.strip
				return Translation.new(expression, Translation::OPTIONS.merge(config).merge(options))
      rescue
				puts $!
        puts @parser
        exit
      end
    end
  end # parse_command_line
  
	# Only used when translate is called from command line.
  # Call the above methods to show results.
	def translate
		trap(:INT) { puts "Bye." ; exit }
		translation = parse_command_line
		translation.translate
		translation.errors.empty? ? translation.print : translation.print_errors
	end # translate
end
