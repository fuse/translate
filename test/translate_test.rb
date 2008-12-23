#!/usr/bin/ruby -w

$:.unshift(File.join('..', 'lib'))

require 'test/unit'
require 'translate'

class TranslateTest < Test::Unit::TestCase
	include Translate

	def test_available_translations
		assert_equal false, Translate::Language.available_translation?("", "")
		assert_equal false, Translate::Language.available_translation?("fr", "")
		assert_equal false, Translate::Language.available_translation?("", "fr")
		assert_equal true, Translate::Language.available_translation?("en", "fr")
		assert_equal true, Translate::Language.available_translation?(:en, :fr)
		assert_equal false, Translate::Language.available_translation?("de", "fr") # false, fr is not in de list
		assert_equal false, Translate::Language.available_translation?("jz", "fr") # false, jz does'nt exist
	end

	def test_translation_validity
		translation = Translation.new("word")
		assert_equal true, translation.valid?
		
		translation = Translation.new("word", { :from => :fr, :to => :us })
		assert_equal false, translation.valid?
	end

	def test_url
		translation = Translation.new("word")
		assert_equal "http://www.wordreference.com/enfr/word", translation.url.to_s
		
		translation = Translation.new("hello world")
		assert_equal "http://www.wordreference.com/enfr/hello%20world", translation.url.to_s
	end

	def test_string
		str = ""
		assert_equal true, str.blank?
		
		str = " "
		assert_equal true, str.blank?

		str = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus vel mi. Duis est. In vitae erat."
		assert_equal "Lorem ipsum dolor sit amet,...", str.truncate
		assert_equal "Lorem...", str.truncate(8)
		assert_equal "Lorem ipsum...", str.truncate(14)

		str = "Lorem"
		assert_equal "Lorem", str.truncate(10)
	end

	def test_options
		translation = Translation.new("maison", { :from => :fr, :to => :es, :more => true, :width => 100 })

		assert_equal translation.from, :fr
		assert_equal translation.to, :es
		assert_equal translation.more, true
		assert_equal translation.width, 100
	end

	def test_translation_enfr
		translation = Translation.new("house", { :from => :en, :to => :fr })
		translation.translate
		assert_equal 5, translation.items.size
		
		# ensure items' array has been cleared
		translation.translate
		assert_equal 5, translation.items.size

		translation.more = true
		translation.translate
		assert_equal 27, translation.items.size
	end
	
	def test_translation_encz
		translation = Translation.new("house", { :from => :en, :to => :cz })
		translation.translate
		assert_equal 4, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 4, translation.items.size
	end

	def test_translation_engr
		translation = Translation.new("house", { :from => :en, :to => :gr })
		translation.translate
		assert_equal 3, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 3, translation.items.size
	end
	
	def test_translation_enit
		translation = Translation.new("house", { :from => :en, :to => :it })
		translation.translate
		assert_equal 4, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 32, translation.items.size
	end
	
	def test_translation_enja
		translation = Translation.new("house", { :from => :en, :to => :ja })
		translation.translate
		assert_equal 3, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 3, translation.items.size
	end
	
	def test_translation_enko
		translation = Translation.new("house", { :from => :en, :to => :ko })
		translation.translate
		assert_equal 3, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 3, translation.items.size
	end
	
	def test_translation_enpl
		translation = Translation.new("house", { :from => :en, :to => :pl })
		translation.translate
		assert_equal 3, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 3, translation.items.size
	end
	
	def test_translation_enro
		translation = Translation.new("house", { :from => :en, :to => :ro })
		translation.translate
		assert_equal 3, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 3, translation.items.size
	end
	
	def test_translation_entr
		translation = Translation.new("house", { :from => :en, :to => :tr })
		translation.translate
		assert_equal 4, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 4, translation.items.size
	end
	
	def test_translation_enzh
		translation = Translation.new("house", { :from => :en, :to => :zh })
		translation.translate
		assert_equal 3, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 3, translation.items.size
	end
	
	def test_translation_fren
		translation = Translation.new("maison", { :from => :fr, :to => :en })
		translation.translate
		assert_equal 2, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 12, translation.items.size
	end
	
	def test_translation_iten
		translation = Translation.new("casa", { :from => :it, :to => :en })
		translation.translate
		assert_equal 2, translation.items.size
		
		# no more translation	
		translation.more = true
		translation.translate
		assert_equal 4, translation.items.size
	end
end
