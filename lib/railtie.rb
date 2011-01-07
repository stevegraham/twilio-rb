module Twilio
  class Railtie < Rails::Railtie
    initializer 'twilio.initialize' do |app|
      module ActionView
        class Template
          module Handlers
            class TwiML < ::ActionView::Template::Handler
              include ::ActionView::Template::Handlers::Compilable

              def compile(template)
                partial = File.basename(template.identifier).starts_with?('_')
                %<Twilio::TwiML.build(#{partial}) { |res| #{template.source} }>
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