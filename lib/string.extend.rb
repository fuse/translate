class String
  def blank?
    nil? or strip.empty?
  end # blank
  
	def truncate(length = 30, truncate_string = "...")
    return if blank?
    (self.length > length ? self[0...(length - truncate_string.length)] + truncate_string : self).to_s
  end # truncate  

	def sanitize
		# strip html tags and html code of the arrow (=>)
		self.strip.gsub(/<.*?>|&#8658;/, '')
	end #sanitize
end
