require 'net/http'
require 'json'

class Quizlet
	def getSet(id)
		url = 'https://api.quizlet.com/2.0/sets/' + id.to_s + '?client_id=' + ENV["QUIZLET_CLIENT_ID"] + '&whitespace=1'
		resp = Net::HTTP.get_response(URI.parse(url))
		set = JSON.parse(resp.body)
		return set
	end
end