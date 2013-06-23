require "csv"
require 'sunlight/congress'
require 'erb'
require 'date'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"
EVENT_ATTENDEES = "event_attendees.csv"
#EVENT_ATTENDEES = "full_event_attendees.csv"
FORM_LETTER = "form_letter.erb"
FOLLOWUP_FILENAME = "followup.txt"
WEEK_DAYS = %w(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)
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

def sort_items data
  items = Hash.new(0)
  
  data.each do |item|
    items[item] = items[item] + 1
  end
  
  items.sort{|a, b|b[1] <=> a[1]}
end

def parse_date_time(str)
  DateTime.strptime(str, "%m/%d/%y %H:%M")
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
times = []
wdays = []
if(File.exist? (EVENT_ATTENDEES))
  
  rows = (CSV.open EVENT_ATTENDEES, headers: true, header_converters: :symbol)
  
  rows.each do |row|
    template = ERB.new letter_template
    id = row[0]
    names << name = row[:first_name]
    numbers << number = clean_phone(row[:homephone])
    zip = clean_zipcode(row[:zipcode])
    dt = parse_date_time(row[:regdate])
    times << dt.hour
    wdays << dt.wday
    legislators = legislators_by_zip(zip)
    letter = template.result(binding)
    save_form_letter(letter, id)
   
  end
  
  follow_up_content = "The following is a list of numbers for registered attendees, so that we can call them later:\n"
  names.each_with_index do |name, index|
    follow_up_content << "\t#{name} #{numbers[index]}\n"
  end
  
  #i thought that maybe 'the boss' might like it if I created an easy to use document that listed the first names and phone numbers of the attendees and the best two recommended times and dates at the bottom.
  
  sorted_times = sort_items(times)
  sorted_days = sort_items(wdays)
  follow_up_content += "\n\nThe best time to call would be #{sorted_times[0][0]}:00 or #{sorted_times[1][0]}:00 on #{WEEK_DAYS[sorted_days[0][0]]} or #{WEEK_DAYS[sorted_days[1][0]]}"
  
  save_followup_list follow_up_content
  
end

