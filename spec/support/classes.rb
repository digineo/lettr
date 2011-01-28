class Villa < OpenStruct
  extend Lettr::Whitelist

  lettr_white_list :name, :street, :safe_code, :phone

  DEFAULTS = {
  }

  def initialize attributes={}
    super DEFAULTS.merge attributes
  end

end

class Traveler < OpenStruct

  DEFAULTS = {
  }

  def initialize attributes={}
    super DEFAULTS.merge attributes
  end

end

class Booking < OpenStruct
  extend Lettr::Whitelist

  lettr_white_list :number, :start_date, :end_date, :nights, :persons, :price_total_persons, :price_adults, :price_children, :cleaning, :boat_training, :price_total, :house_deposit, :boat_deposit,
    :deposit, :title, :name, :address, :appnr, :postal_code, :city, :country, :phone, :email, :total_discount, :price_total_with_discount, :downpayment_deadline, :downpayment, :payment_deadline,
    :remainder, :discount?, :late?, :salutation, :edit_url, :price_total_with_deposit

  DEFAULTS = {
    :title => 'Herr',
    :gender => 'm',
    :first_name => 'Max',
    :last_name => 'Mustermann',
    :email => 'test@example.com',
    :address => 'test street',
    :city => 'test city',
    :start_date => 4.weeks.since,
    :end_date => 4.weeks.since + 7.days,
    :adults => 2,
    :state => 'offer',
    :villa => Villa.new,
    :travelers => (1..5).to_a.map { |n| Traveler.new }
  }

  attr_reader :attributes

  def initialize attributes={}
    @attributes = DEFAULTS.merge attributes
    super @attributes
  end

  def firstname
    first_name
  end

  def lastname
    last_name
  end

  def traveler_names
    ['foo', 'bar']
  end

end


