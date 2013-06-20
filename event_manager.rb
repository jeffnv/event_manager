require "csv"
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"
EVENT_ATTENDEES = "event_attendees.csv"
FORM_LETTER = "form_letter.erb"
puts "Event manager initialized!"

def clean_zipcode(zip)
  zip.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zip zip
  legislators = Sunlight::Congress::Legislator.by_zipcode(zip)
  # legislators.map{|l| "#{l.first_name} #{l.last_name}"}
  legislators
end

def load_form_letter
  letter = File.read(FORM_LETTER)
end

letter_template = load_form_letter

if(File.exist? (EVENT_ATTENDEES))
  
  rows = (CSV.open EVENT_ATTENDEES, headers: true, header_converters: :symbol)
  
  rows.each do |row|
    template = ERB.new letter_template

    name = row[:first_name]
    zip = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zip(zip)
    letter = template.result(binding)
    puts letter
    # puts "name:#{name} | zip:#{zip} | #{legs.join(', ')}"
    
    
  end
  
end

