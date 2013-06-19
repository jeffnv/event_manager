puts "Event manager initialized!"


FILE_TO_READ = "event_attendees.csv"
if(File.exist? (FILE_TO_READ))
  
  lines = File.readlines FILE_TO_READ

  lines.each_with_index do |line, index|
    next if (index == 0)
    columns = line.split(",")
    puts columns[2]
  end
  
end