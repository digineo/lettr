NewsletterBoy::RenderedMailing = Struct.new(:identifier, :subject, :html, :text, :files) do
  include NewsletterBoy::Resource
  include NewsletterBoy::Deliverable

  self.path = 'rendered_mailings'

  def initialize attributes={}
    super
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def handle_options
    attributes.each do |key, value|
      if key == :files
        @files.merge! value if value
      else
        @hash.merge! key => value
      end
    end
    p @hash
    p @files
  end

  def to_payload
    { self.resource_name => attributes_for_create }
  end

  def path
    "#{self.class.path}/#{identifier}"
  end

  def collection_path
    self.class.path
  end

  def attributes_for_create
    as = {}
    attributes.each do |key, value|
      as.merge! key => value unless %w{html text files}.include? key.to_s
    end
    as
  end

end
