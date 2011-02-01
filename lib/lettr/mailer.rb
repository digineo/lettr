class Lettr::Mailer < ActionMailer::Base
  include Lettr::ActionMailer

  alias perform_delivery_smtp     perform_delivery_lettr
  alias perform_delivery_sendmail perform_delivery_lettr
  alias perform_delivery_test     perform_delivery_lettr

  self.delivery_method = :lettr

end
