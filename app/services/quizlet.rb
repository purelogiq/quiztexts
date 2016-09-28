class Quizlet
	def self.get_card_set(id)
		url = 'https://api.quizlet.com/2.0/sets/' + id.to_s + '?client_id=' + ENV["QUIZLET_CLIENT_ID"] + '&whitespace=1'
		resp = Net::HTTP.get_response(URI.parse(url))
		result = JSON.parse(resp.body)
		return result
		# return model object
	end
end