module Twilio
  class Railtie < Rails::Railtie
    initializer 'twilio.initialize' do |app|
      module ActionView
        class Template
          module Handlers
            class TwiML
              class_attribute :default_format
              self.default_format = 'text/xml'

              def compile(template)
                <<-EOS
                controller.content_type = 'text/xml'
                Twilio::TwiML.build { |res| #{template.source} }
                EOS
              end

              def self.call(template)
                new.compile(template)
              end
            end
          end
        end
      end

      ActionController::Base.class_eval { before_filter Twilio::RequestFilter }

      ::ActionView::Template.register_template_handler(:voice, ActionView::Template::Handlers::TwiML)
      ::Mime::Type.register_alias 'text/xml', :voice
    end
  end
end
