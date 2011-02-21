#!/usr/bin/env ruby
require 'socket'
ipadd = '172.30.1.5'
port = '8888'
int = '172.30.1.1'
servport = '8888'
@contoserv = TCPSocket.new(ipadd, 8008)

def startimmdbg()
#insert file creation, nc, and autoit logic here...

end

def oldfilenwfile(file)

end

def diffit

end

puts "This is the ruby bindiff connector for my ImmDbg plug-in"
exit = ""
cmd = ""
string = String.new
@funcfile = File.new("/home/bildr/src/tuts/bindiff/placeholder", "w+")

outputthr = Thread.new do
aserv = TCPServer.open(int, servport)
while (servsock = aserv.accept)
string = ""
allfuncs = ""
if (File.exist?("/home/bildr/src/tuts/bindiff/immdump.old"))
puts "trying immdump.new"
@funcfile = File.new("/home/bildr/src/tuts/bindiff/immdump.new", "w")
puts "using immdump.new"
else
puts "trying immdump.old"
@funcfile = File.new("/home/bildr/src/tuts/bindiff/immdump.old","w")
puts "using immdump.old"
end

while ( string.index("exit") == nil )
 while (string.index('!') == nil)
  string << servsock.gets
 end
  string.gsub!("\n", "")
  string.gsub!("\r", "")
  string.gsub!("!", "\n")
  puts string
  allfuncs = allfuncs + string
  puts "added string to funcs"
  if (string.index("exit") == nil)
   string = ""
  else
   @funcfile.write(allfuncs)
   @funcfile.flush
   @funcfile.close
  end
end
puts "I got an exit and I figured it out"
servsock.close
end
end





while (exit != "!quit\n")
 #read output
 #send input
  cmd = readline
  if (cmd != "\n")
#   cmd.gsub!("\n", "")
#   p cmd
  if (cmd == "r\n")
   outputthr.kill
   outputthr.exit
   outputthr.run
  elsif (cmd == "loada\n")
   nccmd = ""
    @contoserv.write("\n\n")
   while (nccmd.index('>') == nil)
    nccmd = nccmd + @contoserv.gets
   end    
   @contoserv.write("immdbga.bat\n")
   @contoserv.flush
   puts "Command sent...please wait"
   sleep 5
  elsif (cmd == "loadb\n")
   nccmd = ""
    @contoserv.write("\n\n")
   while (nccmd.index('>') == nil)
    nccmd = nccmd + @contoserv.gets
   end  
   @contoserv.write("immdbgb.bat\n")
   @contoserv.flush
   puts "Command sent...please wait"
   sleep 5
  elsif (cmd == "con\n")
   @contodbg = TCPSocket.new(ipadd, port)
  elsif (cmd == "clean\n")
   File.delete("/home/bildr/src/tuts/bindiff/immdump.old")
   File.delete("/home/bildr/src/tuts/bindiff/immdump.new")
  elsif (cmd == "ls\n")
   system('ls -la /home/bildr/src/tuts/bindiff')
  elsif (cmd != "!quit\n")
   @contodbg.write(cmd)
  end
  if (cmd == "!quit\n")
   exit = cmd
  end
 end
end
outputthr.kill
outputthr.exit
File.delete("/home/bildr/src/tuts/bindiff/placeholder")
