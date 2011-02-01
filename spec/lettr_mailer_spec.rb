require 'spec_helper'

class LettrTestMailer < Lettr::Mailer
  def testmail

    recipients 'test@example.com'
    subject 'test lettr mailer'
    body 'test lettr mailer body'

  end
end

describe 'delivery method :lettr' do
  use_vcr_cassette "lettr/lettr_mailer", :record => :new_episodes

  before do
    ActionMailer::Base.delivery_method = :sendmail
  end

  it 'should have deliver method sendmail set' do
    ActionMailer::Base.delivery_method.should eql :sendmail
  end

  it 'should deliver a mail via lettr' do
    expect { LettrTestMailer.deliver_testmail }.to_not raise_error
  end
end
