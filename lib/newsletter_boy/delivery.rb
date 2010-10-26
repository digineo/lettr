class NewsletterBoy::Delivery
  include NewsletterBoy::Resource
  attr_accessor :errors
  attr_reader :files

  def initialize a_hash, files
    @params = a_hash
    @files = files
    @errors = []
  end

  def attributes
    @params
  end

  def path
    "api_mailings/#{attributes[:api_mailing_id]}/deliveries"
  end
end

