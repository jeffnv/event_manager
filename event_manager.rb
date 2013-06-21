require "csv"
require 'sunlight/congress'
require 'erb'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"
EVENT_ATTENDEES = "event_attendees.csv"
FORM_LETTER = "form_letter.erb"
FOLLOWUP_FILENAME = "followup.txt"
puts "Event manager initialized!"


def clean_phone(phone)
  num = phone.scan(/\d+/).join('')
  result = ""
  
  case num.length
  when 11
    result  = num if num.start_with?('1')
  when 10
    result = num.insert(0, '1')
  end
  
  unless result.empty?
    result.insert(1,'-')
    result.insert(5, '-')
    result.insert(9, '-')
  end
  result
end

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

def save_followup_list(content)
  Dir.mkdir("output") unless Dir.exists? "output"
  
  filename = "output//#{FOLLOWUP_FILENAME}"
  
  File.open(filename, 'w') do |file|
    file.puts content
  end
end

letter_template = load_form_letter
names = []
numbers = []
if(File.exist? (EVENT_ATTENDEES))
  
  rows = (CSV.open EVENT_ATTENDEES, headers: true, header_converters: :symbol)
  
  rows.each do |row|
    template = ERB.new letter_template
    id = row[0]
    names << name = row[:first_name]
    numbers << number = clean_phone(row[:homephone])
    zip = clean_zipcode(row[:zipcode])
    legislators = legislators_by_zip(zip)
    letter = template.result(binding)
    save_form_letter(letter, id)
   
  end
  follow_up_content = ""
  names.each_with_index do |name, index|
    follow_up_content << "#{name} #{numbers[index]}\n"
  end
  save_followup_list follow_up_content
  
end

