module Twilio
  class Railtie < Rails::Railtie
    initializer 'twilio.initialize' do |app|
      module ActionView
        class Template
          module Handlers
            class TwiML < ::ActionView::Template::Handler
              self.default_format = 'text/xml'
              include ::ActionView::Template::Handlers::Compilable

              def compile(template)
                <<-EOS
                controller.content_type = 'text/xml'
                Twilio::TwiML.build {|res| #{template.source} }
                EOS
              end
            end
          end
        end
      end

      ::ActionView::Template.register_template_handler(:voice, ActionView::Template::Handlers::TwiML)
      ::Mime::Type.register_alias 'text/xml', :voice
    end
  end
end
