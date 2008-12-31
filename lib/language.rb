module Translate
  module Language
    # Language module contains the different languages available and defined
    # the directions which can be used.
    EN = "English"
    FR = "French"
    IT = "Italian"
    PL = "Polish"
    RO = "Romanian"
    CZ = "Czech"
    GR = "Greek"
    TR = "Turkish"
    ZH = "Chinese"
    JA = "Japanese"
    KO = "Korean"
  
    DIRECTIONS = { 
			EN => [ "CZ", "FR", "GR", "IT", "JA", "KO", "PL", "RO", "TR", "ZH" ],
      FR => [ "EN" ],
      IT => [ "EN" ]
    }

    # Show the available translations on the command line. You can invoke 
    # this method by using : 
    #   $ translate -l
    # It will print the language's abbreviation and real name (in english).
    def self.available_translations
      puts "Available translations :\n"
      (Language.constants - [DIRECTIONS]).sort.each do |l|
        constant = const_get(l)
        puts "\t- #{constant} (#{l.downcase}) to #{DIRECTIONS[constant].map { |c| 
					"#{const_get(c)} (#{c.downcase})"
				}.join(', ')}" if Language::DIRECTIONS.include?(constant)        
      end
    end # available_translations
  
    # Check if the original and final languages are available.
    def self.available_translation?(*args)
      from, to = args.map { |a| a.to_s.strip.upcase }
      return false if from.blank? or to.blank?
      self.const_defined?(from) and self.const_defined?(to) and DIRECTIONS[self.const_get(from)].include?(to)
    end # available_translation?

		def self.klass_fren; end
		def self.klass_iten; end
	end
end
