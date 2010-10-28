module NewsletterBoy::Resource

  def self.included base
    base.extend ClassMethods
    base.cattr_accessor :path
    base.send(:attr_accessor, :errors)
    base.send(:attr_accessor, :id)
  end

  module ClassMethods
    def find id
      new(client.find resource_path(id))
    end

    def client
      @client ||= NewsletterBoy::Base.new
    end

    def resource_path id
      "#{path}/#{id}"
    end
  end

  def initialize *args
    @errors = []
  end

  def save
    res = client.save self
    self.id = ActiveSupport::JSON.decode(res)[resource_name]['id'] unless res.blank?
    true
  rescue RestClient::UnprocessableEntity => e
    self.errors = ActiveSupport::JSON.decode(e.response)
    false
  end

  def client
    self.class.client
  end

  def to_payload
    { self.resource_name => self.attributes }
  end

  def destroy
    client.destroy self
  end

  def resource_name
    self.class.to_s.demodulize.underscore
  end

  def to_json
    { resource_name => attributes }.to_json
  end

  def path
    "#{self.class.path}/#{id}"
  end

  def attributes
    attributes = {}
    each_pair do |key, value|
      attributes.merge! key => value
    end
    attributes
  end
end
