class ConnectUser

  def initialize(login)
    begin
      api_conf = TravelSupportProgram::Config.setting(:opensuse_auth_proxy, :connect_api)
      api_key = api_conf["api_key"]
      url = api_conf["base_url"] + "/json"
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
end
