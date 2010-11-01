class Lettr::Base
  DEFAULT_HEADERS = { :accept => :json }

  cattr_accessor :site, :user, :pass, :content_type
  attr_reader :client

  def initialize
    @client = RestClient::Resource.new self.class.site_url, self.class.user, self.class.pass
  end

  def self.site_url
    "#{Lettr.protocol}://#{Lettr.host}/"
  end

  def save object
    path = object.collection_path
    payload = object.to_payload
    payload.merge! :files => object.files if object.respond_to?(:files) && object.files
    client[path].post(payload, DEFAULT_HEADERS)
  end

  def destroy object
    client[object.path].delete DEFAULT_HEADERS
  end

  def find path
    ActiveSupport::JSON.decode(client[path].get DEFAULT_HEADERS)
  end

  def [] path
    client[path]
  end

end
