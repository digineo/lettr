NewsletterBoy::Recipient = Struct.new( :email, :id, :gender, :firstname, :lastname, :street, :ccode, :pcode, :city, :approved ) do
  include NewsletterBoy::Resource
  self.path = 'recipients'

  def initialize email
    super
    self.email = email
  end

  def path
    "#{self.class.path}/#{id}"
  end

  def collection_path
    self.class.path
  end

end
