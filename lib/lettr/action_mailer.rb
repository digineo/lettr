module Lettr::ActionMailer

  private

  def perform_delivery_lettr mail
    Lettr::MailExtensions::Lettr.new(:template => @template).deliver! mail
  end

end
