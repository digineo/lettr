Lettr::RenderedMailing = Struct.new(:identifier, :subject, :html, :text, :files) do
  include Lettr::Resource
  include Lettr::Deliverable

  self.path = 'rendered_mailings'

  attr_writer :created_at
  attr_accessor :recipient

  def initialize attributes={}
    super
    if as = attributes.delete('rendered_mailing')
      as.each do |k, v|
        if %w{ identifier subject html text files }.include? k
          send("#{k}=", v)
        end
      end
    end
    attributes.each do |key, value|
      send("#{key}=", value)
    end
  end

  def attributes= attributes
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
