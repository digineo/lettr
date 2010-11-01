class NewsletterBoy::Delivery
  include NewsletterBoy::Resource
  attr_reader :files

  def initialize a_hash, files
    super
    @params = a_hash
    @files = files
  end

  def attributes
    @params
  end

  def collection_path
    "api_mailings/#{attributes[:api_mailing_id]}/deliveries"
  end
end


