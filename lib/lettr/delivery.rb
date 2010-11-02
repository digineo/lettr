class Lettr::Delivery
  include Lettr::Resource
  attr_reader :files

  def initialize a_hash, files
    super
    @params = a_hash
    @files = files
  end

  def attributes
    @params
  end

  def save
    unless super
      dump_json
    end
  end

  def dump_json
    if defined? Rails
      path = File.join(Rails.root, 'log')
      File.open(File.join(path, "lettr-delivery-#{Time.now}.json"), 'w') do |f|
        f.write attributes.to_json
      end
    end
  end

  def collection_path
    "api_mailings/#{attributes[:api_mailing_id]}/deliveries"
  end
end


