# Unix's installer for the translate script.
require "ftools"

LIBRARY_PATH    = File.join("lib", "translate.rb")
EXECUTABLE_PATH = "translate"

def check_privileges
  userid = `id -u`.chomp.to_i
  unless userid.zero?
    puts "You must have root's privileges to install translate."
    interrupt
  end
end

def interrupt
  puts "Bye."
  exit
end

def file_not_found(path)
  puts "#{path} does'nt exists, installer is going to stop."
  interrupt
end

def success
  puts %q{
The translate library and executable have been both successfully installed. 
You can start using it by typing : 
  translate -h
  }
  interrupt
end

def executable_available?
  File.exists?(EXECUTABLE_PATH)
end

def library_available?
  File.exists?(LIBRARY_PATH)
end

def copy(from, to)
  if File.directory?(to) and File.writable?(to)
    filename = File.basename(from)
    if (File.copy(from, to) rescue false)
      puts "#{filename} successfully copied to #{to}" 
    else
      puts "Fail to copy #{filename} to #{to}"
      interrupt
    end
  else
    puts "Directory #{to} is not a directory or is not writable."
    interrupt
  end
end

def install(from, destinations, name)
  begin
    destinations = destinations.reject { |d| "." == d }.uniq.sort
    puts "Please choose a directory to install #{name} :"    
    destinations.each_with_index do |dir, @index|  
      puts "\t[#{@index += 1}] #{dir}"
    end
    puts "\t[#{@index += 1}] Exit installer"
    choice = STDIN.gets.to_i
  end while not choice.is_a?(Integer) or not choice.between?(1, @index)
  choice == @index ? interrupt : copy(from, destinations[choice - 1])
  return destinations[choice - 1]
end

def install_library
  library_available? ? install(LIBRARY_PATH, $LOAD_PATH, "the library translate.rb") : file_not_found(LIBRARY_PATH)
end

def install_executable
  if executable_available?
    paths = `echo $PATH`.chomp.split(':')
    destination = install(EXECUTABLE_PATH, paths, "the executable translate")
    File.chmod(0755, File.join(destination, EXECUTABLE_PATH)) if destination
  else
    file_not_found(EXECUTABLE_PATH)    
  end
end

check_privileges
install_library
install_executable
success
