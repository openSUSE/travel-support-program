#
# A user at connect.opensuse.org.
# This class uses the REST interface of connect.opensuse.org to read information
# about a given Connect user. See
# http://en.opensuse.org/openSUSE:Connect_API
#
class ConnectUser

  # Creates a new instance for accessing the information of a given connect user
  #
  # @param [String] login the username of the user in Connect.
  # @return [ConnectUser]
  def initialize(login)
    begin
      api_conf = TravelSupport::Config.setting(:opensuse_connect)
      api_key = api_conf["api_key"]
      url = api_conf["base_url"] + "/services/api/rest/json"
      method = "connect.user.attribute.get"
      elgg = Elgg.new(url, api_key)
      @attributes = ActiveSupport::JSON.decode(elgg.get(method: method, login: login, attribute: "*"))["result"]["all"]
    rescue
      @attributes = {}
    end
  end

  def method_missing(meth, *args, &block)
    if @attributes && @attributes.keys.include?(meth.to_s)
      @attributes[meth.to_s]
    else
      super
    end
  end

  def respond_to?(meth, include_private = false)
    if @attributes && @attributes.keys.include?(meth.to_s)
      true
    else
      super
    end
  end

  def self.profile_url_for(login)
    TravelSupport::Config.setting(:opensuse_connect, :base_url) + "/pg/profile/#{login}"
  end

end
