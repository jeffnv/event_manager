require "csv"

puts "Event manager initialized!"

def clean_zipcode(zip)
  zip ||=""
  
  result = zip.split('')
  
  while result.count != 5 do
    if(result.count < 5)
      result.insert(0, '0')
    elsif(result.count > 5)
      result = result[0..4]
    end
  end
  result.join('')

end
FILE_TO_READ = "event_attendees.csv"
if(File.exist? (FILE_TO_READ))
  
  rows = (CSV.open FILE_TO_READ, headers: true, header_converters: :symbol)
  
  rows.each do |row|
    name = row[:first_name]
    zip = clean_zipcode(row[:zipcode])
    puts "name:#{name} | zip:#{zip}"
  end
  
end