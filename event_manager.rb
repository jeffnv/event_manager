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
  Sunlight::Congress::Legislator.by_zipcode(zip)
end

def load_form_letter
  letter = File.read(FORM_LETTER)
end

def save_form_letter(content, id)
  Dir.mkdir("output") unless Dir.exists? "output"

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts content
  end
end

letter_template = load_form_letter

if(File.exist? (EVENT_ATTENDEES))
  
  rows = (CSV.open EVENT_ATTENDEES, headers: true, header_converters: :symbol)
  
  rows.each do |row|
    template = ERB.new letter_template
    id = row[0]
    name = row[:first_name]
    zip = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zip(zip)
    letter = template.result(binding)
    save_form_letter(letter, id)
   
  end
  
end

