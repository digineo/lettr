NewsletterBoy::RenderedMailing = Struct.new(:identifier, :subject, :html, :text, :files) do
  include NewsletterBoy::Resource
  include NewsletterBoy::Deliverable

  def initialize attributes={}
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

end
