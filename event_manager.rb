require "csv"
require 'sunlight/congress'

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

puts "Event manager initialized!"

def clean_zipcode(zip)
  zip.to_s.rjust(5, '0')[0..4]
end

def legislators_by_zip zip
  legislators = Sunlight::Congress::Legislator.by_zipcode(zip)
  legislators.map{|l| "#{l.first_name} #{l.last_name}"}
end

FILE_TO_READ = "event_attendees.csv"
if(File.exist? (FILE_TO_READ))
  
  rows = (CSV.open FILE_TO_READ, headers: true, header_converters: :symbol)
  
  rows.each do |row|
    name = row[:first_name]
    zip = clean_zipcode(row[:zipcode])
    
    legs = legislators_by_zip(zip)
    
    puts "name:#{name} | zip:#{zip} | #{legs.join(', ')}"
  end
  
end