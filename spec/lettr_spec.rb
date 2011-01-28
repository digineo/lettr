require 'spec_helper'

describe Lettr do

  before do
    Lettr.protocol = 'http'
    Lettr.host = 'lettr.timo.digineo.lan'
    #Lettr.credentials = { :user => 'dennis', :pass => 'dennis' }
    Lettr.api_key = "4674c52e7a12bae3777d02f82b79b7ddcc63994c"
  end

  it 'should set the host' do
    Lettr.host.should eql 'lettr.timo.digineo.lan'
  end

  it 'should set the site' do
    Lettr::Base.site_url.should eql 'http://lettr.timo.digineo.lan/'
  end

  describe 'creating a recipient' do
    use_vcr_cassette "lettr/create_recipient", :record => :new_episodes

    before do
      @booking ||= Booking.new
      @recipient = Lettr.subscribe(@booking)
    end

    after do
      @recipient.destroy
    end

    it 'should sign_up' do
      @recipient.email.should eql @booking.email
      @recipient.gender.should eql @booking.title == 'Herr' ? 'm' : 'f'
      @recipient.firstname.should eql @booking.first_name
      @recipient.lastname.should eql @booking.last_name
      @recipient.street.should eql @booking.street
      @recipient.ccode.should eql @booking.country
      @recipient.pcode.should eql @booking.pcode
      @recipient.city.should eql @booking.city
    end
  end

  describe 'destroy recipients by email' do
    use_vcr_cassette "lettr/destroy_recipient_by_email", :record => :new_episodes

    before do
      @booking ||= Booking.new
      @recipient ||= Lettr.subscribe(@booking)
    end

    after do
      #@recipient.destroy if @recipient
    end

    it 'should delete recipients by email' do
      Lettr.unsubscribe(@booking.email)
    end
  end

  describe 'delivering an ApiMailing' do
    use_vcr_cassette "lettr/delivering_an_api_mailing", :record => :new_episodes

    before do
      @villa ||= Villa.new
      @booking ||= Booking.new :email => 'timo@moe.digineo.lan', :discount => 50
    end

    describe 'with automagic' do
      before do
        @delivery = Lettr.confirmation_mail(:booking => @booking, :recipient => @booking.email).deliver
      end

      it 'should deliver a mail' do
        @delivery.should_not be_nil
        @delivery.errors.should be_empty
      end
    end

    describe 'with attachment' do
      before do
        @delivery = Lettr.confirmation_mail(:booking => @booking, :recipient => @booking.email, :attachment => File.join(File.dirname(__FILE__), 'fixtures', 'attachments', 'intervillas_1.pdf' )).deliver
      end

      it 'should deliver a mail' do
        @delivery.should_not be_nil
        @delivery.errors.should be_empty
      end
    end

    describe 'with hash argument' do
      before do
        @delivery = Lettr.confirmation_mail(:booking => @booking.attributes, :recipient => @booking.email).deliver
      end

      it 'should deliver a mail' do
        @delivery.should_not be_nil
        @delivery.errors.should be_empty
      end
    end

    describe 'with :to_nb_hash method' do
      before do
        @booking.class_eval do
          def to_nb_hash
            { :booking => attributes }
          end
        end
        @delivery = Lettr.confirmation_mail(:booking => @booking, :recipient => @booking.email).deliver
      end

      it 'should deliver a mail' do
        @delivery.should_not be_nil
        @delivery.errors.should be_empty
      end
    end

    describe 'caching' do
      before do
        @api_mailing = Lettr.confirmation_mail(:booking => @booking, :recipient => @booking.email)
        @api_mailing.variables.delete_at(0)
        @delivery = @api_mailing.deliver
      end

      it 'should deliver a mail' do
        @delivery.should_not be_nil
        @delivery.errors.should be_empty
      end
    end

    describe 'remind mail' do
      before do
        @delivery = Lettr.reminder_mail(:booking => @booking, :recipient => @booking.email).deliver
      end

      it 'should deliver a mail' do
        @delivery.should_not be_nil
        @delivery.errors.should be_empty
      end
    end

    describe 'valid' do
      before do
        @delivery_options = {:subject => 'test subject', :recipient => @booking.email, :text => 'test text', :html => '<div>test html</div>'}
      end

      describe 'pre rendered mail' do
        before do
          @rendered_mailing = Lettr.pre_rendered_mail(@delivery_options)
          @delivery = @rendered_mailing.deliver
        end

        after do
          @rendered_mailing.destroy
        end

        it 'should deliver a mail' do
          @delivery.should_not be_nil
          @delivery.errors.should be_empty
        end
      end

      describe 'no subject' do
        before do
          @delivery_options.delete :subject
        end

        describe 'pre rendered mail' do
          it 'should raise an argument exception' do
            expect { Lettr.pre_rendered_mail(@delivery_options) }.to raise_error(ArgumentError, ':subject is required')
          end
        end
      end

      describe 'no recipient' do
        before do
          @delivery_options.delete :recipient
        end

        describe 'pre rendered mail' do
          it 'should raise an argument exception' do
            expect { Lettr.pre_rendered_mail(@delivery_options) }.to raise_error(ArgumentError, ':recipient is required')
          end
        end
      end

      describe 'no text and no html' do
        before do
          @delivery_options.delete :text
          @delivery_options.delete :html
        end

        describe 'pre rendered mail' do
          it 'should raise an argument exception' do
            expect { Lettr.pre_rendered_mail(@delivery_options) }.to raise_error(ArgumentError, ':html or :text is required')
          end
        end
      end
    end

  end

end
