require 'net/http'

class Elgg
   
  def initialize(base_url, api_key)
    @base_url = base_url
    @api_key = api_key
  end
    
  def get(params)
    uri = URI.parse(@base_url)
    req_path = uri.path + "?" + params.merge(api_key: @api_key).to_query
    req = Net::HTTP::Get.new(req_path)
    resp = Net::HTTP.start(uri.host, use_ssl: uri.scheme == "https") { |http| http.request(req) }
    raise "Elgg REST API GET failure, params: \"#{params.to_query}\"" unless resp.code.to_i == 200
    resp.body
  end
end
