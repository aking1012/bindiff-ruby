#!/usr/bin/env ruby
#Class file for ruby function and basic block importing from immunity dumps.
#I may add conversion of the vcg files to dot files and some basic block
#highlighting.

class Bindump
@organized = Array.new

def initialize(filename)
@filename = filename
funclist = Array.new
#funclist.push("Start address","End address","Content array")
afunc = Array.new
#afunc.push("Start address block","End address","Content array")
abb = Array.new
som = "" #not implemented
sof = ""
eof = ""
sob = ""
eob = ""
eom = ""
newf = false
newbb = false

File.open(filename).each { |line|
line.chomp!
#parse for start of binary address
#not implemented

#parse for start of function
if ( line.index('sof')!=nil )
 temparray = line.split(':')
 sof = temparray[1]

#parse for end of function
elsif ( line.index('eof')!=nil )
 temparray = line.split(':')
 eof = temparray[1]
 newf = true

#parse for start of basic block
elsif ( line.index('BBS')!=nil )
 temparray = line.split(':')
 sob = temparray[1]

#parse for end of basic block
elsif ( line.index('BBE')!=nil )
 temparray = line.split(':')
 eob = temparray[1]
 newbb = true
 
#if we get here it's either junk or basic block instructions
#trailing junk is okay, leading junk is not
else
 abb.push(line)
end


#check if a basic block is ready
if (newbb == true)
  #add our blocks to the function
  afunc.push(sob, eob, abb)
  #clear the array
  abb = Array.new
#  abb.push("Start address block","End address","Content array")
  #set new block
  newbb = false
  #add the basic block to the function
elsif (newf == true)
  #check if a func is ready
  funclist.push(sof, eof, afunc)
  #clear the array
  afunc = Array.new
#  afunc.push("Start address block","End address","Content array")
  #set new func  
  newf = false
end
  }
#fileread just ended
#copy it out of private to instance
@organized = funclist

end
#init just ended

#functions
def getorganized
 return @organized
end

def getfuncasm(func)
full = Array.new
bbct = bbcount(func)
 (1..bbct).each { |bb|
 
 full.push(getbbasm(func, bb))
 }
 return full
end

def getbbasm(func, bb)
 startadd, endadd, asm = bbgetbynum(func, bb)
 return asm
end

def funccount
 return ((@organized.length)/3)
end

def bbcount(funcnum)
  startadd, endadd, allblocks = funcbynum(funcnum)
  return (allblocks.length/3)
end

def getfunclen(funcnum)
starta, enda, content = funcbynum(funcnum)
#TODO
return starta
end

def getfuncsa(funcnum)
starta, enda, content = funcbynum(funcnum)
return starta
end

def getfuncea(funcnum)
starta, enda, content = funcbynum(funcnum)
return enda
end

def funcbynum(funcnum)
  funcnum = funcnum*3
  startadd = @organized[funcnum-3]
  endadd = @organized[funcnum-2]
  function = @organized[funcnum-1]
  return startadd, endadd, function
end

def bbgetbynum(funcnum, bbnum)
  bbnum = bbnum*3
  startadd, endadd, data = funcbynum(funcnum)
  startadd = data[bbnum-3]
  endaddadd = data[bbnum-2]
  assembly = data[bbnum-1]
  return startadd, endadd, assembly
end

def getfilename
 return @filename
end


end
#end of bindump class

#Start of on execute

begin
if __FILE__ == $0
test = Bindump.new('immdump.old')
#puts "The assembled array looks like this"
#p test.getorganized
#puts "Number of functions is: " + test.funccount.to_s
#puts "We get a function like this funcbynum(1) which returns"
#startadd, endadd, basicblocks = test.funcbynum(2)
#puts "The start address: " + startadd 
#puts "The end address: " + endadd 
#puts "The entire function with extra data: "
#sleep 2
#p basicblocks
#puts "The first function has this many basic blocks"
#puts test.bbcount(10)
#puts "The contents of the first function's first basic block are"
#startadd, endadd, code = test.bbgetbynum(2,3)
#p code
#puts "The start address is: " + startadd
#puts "The end address is: " + endadd
#puts "Okay, so does the example make sense?"
#p test.getfuncasm(10)
#test.getbbasm(10,1)
#p test.getbbasm(10,2)
#p test.getbbasm(10,3)
#test.getbbasm(1,2)
#test.getbbasm(1,3)
end
end
