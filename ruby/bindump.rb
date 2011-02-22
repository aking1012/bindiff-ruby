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

def getbblen(func, bb)
 asm = getbbasm(func, bb)
 return asm.length
end

def getfuncasmnojsoff(func)
full = Array.new
bbct = bbcount(func)
 (1..bbct).each { |bb|
 
 full.push(getbbasmnojsoff(func, bb))
 }
 return full
end

def getbbasmnojson(func, bb)
 asm = getbbasm(func, bb)
 i = 0
 maxi = asm.length - 1
 (i..maxi).each{ |inst|
  #check to see if this is a jump, then check to see if it's a jump to a symbol
  if (asm[i].index("J")==0 && asm[i].rindex('>')!=(asm[i].length-1))
   #if it isn't, strip it
   asm[i]=nil
  end
 i += 1
 }
# p asm
# sleep 2
 i = 0
 temparr = Array.new
 (i..maxi).each { |inst|
  if (!(asm[i].nil?))
    temparr.push(asm[i])
  end
   i += 1
   }
  asm = temparr
 return asm
end

def getbbasmnojspart(func, bb) #still working on this one
 asm = getbbasm(func, bb)
 i = 0
 maxi = asm.length - 1
 (i..maxi).each{ |inst|
  #check to see if this is a jump, then check to see if it's a jump to a symbol
  #this = asm[i]
  if (asm[i].index("J")==0 && !(asm[i].index('<').nil?) && asm[i].rindex('<')>5)
   #if it isn't, strip it
   #asm[i]=nil
   instruct = String.new
   instruct = asm[i]
   len = instruct.length - 1
   astart = instruct.index('<')
   aend = instruct.index('>')
#the bug here is sustrings returning the numeric representation of a char
#  FIXME
   anotherstring = String.new
   (0..len).each{ |i|
   if ((i>=astart) && (i<=aend))
   tempstring = String.new
   tempstring = instruct[i]
   p anotherstring
   p tempstring
   anotherstring = anotherstring + tempstring
   end
   asm[i] = anotherstring.to_s
   }
  end
 i += 1
 }
# p asm
# sleep 2
 i = 0
 temparr = Array.new
 (i..maxi).each { |inst|
  if (!(asm[i].nil?))
    temparr.push(asm[i])
  end
   i += 1
   }
  asm = temparr
 return asm
end

def getbbasmnojsoff(func, bb)
 asm = getbbasm(func, bb)
 i = 0
 maxi = asm.length - 1
 (i..maxi).each{ |inst|
  #check to see if this is a jump, then check to see if it's a jump to a symbol
  #puts inst
  #p asm
  #p inst
  test = String.new
  test = asm[inst]
  if ( (!(test.nil?)) && (test.index("J")==0 || test.index("CALL")==0))
#bug here....nilclass what? - just reload the file
#(!(asm[inst].index("J").nil?)) && asm[inst].index("J")==0)
   #if it isn't, strip it
   asm[inst]=nil
  #puts inst
  end
#  i += 1
# MAYBE??
 }
# p asm
# sleep 2
 i = 0
 temparr = Array.new
 (i..maxi).each { |inst|
  if (!(asm[i].nil?))
    temparr.push(asm[inst])
  end
   i += 1
   }
  asm = temparr
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
test = Bindump.new('immdump.new')
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
#p test.getbbasmnojson(1,1)
#test = Bindump.new('immdump.old')
#p test.getbbasmnojsoff(1,1)

p test.getfuncasmnojsoff(1)
p test.getfuncasmnojsoff(2)
p test.getfuncasmnojsoff(3)

#test.getbbasm(1,3)
end
end
