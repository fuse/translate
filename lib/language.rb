module Translate
  module Language
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

    def self.available_translations
      puts "Available translations :\n"
      (Language.constants - [DIRECTIONS]).sort.each do |l|
        constant = const_get(l)
        puts "\t- #{constant} (#{l.downcase}) to #{DIRECTIONS[constant].map { |c| 
					"#{const_get(c)} (#{c.downcase})"
				}.join(', ')}" if Language::DIRECTIONS.include?(constant)        
      end
    end # available_translations
  
    def self.available_translation?(*args)
      from, to = args.map { |a| a.to_s.strip.upcase }
      return false if from.blank? or to.blank?
      self.const_defined?(from) and self.const_defined?(to) and DIRECTIONS[self.const_get(from)].include?(to)
    end # available_translation?

		def self.klass_fren; end
		def self.klass_iten; end
	end
end
