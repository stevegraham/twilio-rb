require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe Twilio::TwiML do
  describe ".build" do
    it 'starts with the XML doctype' do
      Twilio::TwiML.build.should =~ /^<\?xml version="1.0" encoding="UTF-8"\?>/
    end
    it 'capitalises method names before conversion into XML elements so that one can write nice code' do
      xml = Twilio::TwiML.build do |res|
        res.say 'Hey man! Listen to this!', :voice => 'man'
      end
      xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  " + 
      "<Say voice=\"man\">Hey man! Listen to this!</Say>\n</Response>\n"
    end
    it 'camelizes XML element attributes before conversion into XML elements so that one can write nice code' do
      xml = Twilio::TwiML.build do |res|
        res.record :action => "http://foo.com/handleRecording.php", :method => "GET", :max_length => "20", :finish_on_Key => "*"
      end
      xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  " + 
      "<Record action=\"http://foo.com/handleRecording.php\" method=\"GET\" maxLength=\"20\" finishOnKey=\"*\"/>\n</Response>\n"
    end
    it 'works with nested elements' do
      xml = Twilio::TwiML.build do |res|
        res.gather :action => "/process_gather.php", :method => "GET" do |g|
          g.say 'Now hit some buttons!'
        end
      end
      xml.should == "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<Response>\n  " + 
      "<Gather action=\"/process_gather.php\" method=\"GET\">\n    <Say>Now hit some buttons!</Say>\n  " + 
      "</Gather>\n</Response>\n"
    end
  end
end
