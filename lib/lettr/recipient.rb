Lettr::Recipient = Struct.new( :email, :id, :gender, :firstname, :lastname, :street, :ccode, :pcode, :city, :approved ) do
  include Lettr::Resource
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

  def self.delete_by_email email
    client["#{path}/destroy_by_email"].post( { :"_method" => 'delete', :email => email } , { 'X-Lettr-API-Key' => Lettr.api_key } )
  end

end
