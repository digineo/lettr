class Lettr::Base
  DEFAULT_HEADERS = { :accept => :json }

  cattr_accessor :site, :user, :pass, :content_type
  attr_reader :client

  def initialize
    resource_args = [ self.class.site_url ]
    resource_args += [self.class.user, self.class.pass] unless Lettr.api_key
    @client = RestClient::Resource.new *resource_args
  end

  def self.site_url
    "#{Lettr.protocol}://#{Lettr.host}/"
  end

  def save object
    path = object.collection_path
    payload = object.to_payload
    payload.merge! :files => object.files if object.respond_to?(:files) && object.files
    client[path].post(payload, headers)
  end

  def destroy object
    client[object.path].delete headers
  end

  def find path
    ActiveSupport::JSON.decode(client[path].get headers)
  end

  def [] path
    client[path]
  end

  def headers
    headers = DEFAULT_HEADERS
    headers.merge! 'X-Lettr-API-key' => Lettr.api_key if Lettr.api_key
    headers
  end

end
