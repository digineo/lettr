NewsletterBoy::Recipient = Struct.new( :email, :id, :gender, :firstname, :lastname, :street, :ccode, :pcode, :city, :approved ) do
  include NewsletterBoy::Resource
  self.path = 'recipients'

  def path
    "#{self.class.path}/#{id}"
  end

end
