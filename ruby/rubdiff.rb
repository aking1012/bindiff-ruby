#!/usr/bin/env ruby
#Andrew King
#Creative commons, attribution, share and share alike
#Our first attempt at a custom binary differ
#####################################################
$:.unshift File.join(File.dirname(__FILE__),'..')
require 'bindump.rb'
@bdstatold = Array.new
@bdstatnew = Array.new
@alloldsof = Array.new
@allnewsof = Array.new
@alloldeof = Array.new
@allneweof = Array.new

def func_count
fcold = @oldfile.funccount
fcnew = @newfile.funccount
fcdiff = fcnew - fcold
@fc = Array.new
@fc.push(fcold, fcnew, fcdiff)
fc = @fc
return fc
end

def func_addresses
#parse all the function addresses into arrays for easy parsing
 func=1
  @alloldsof = Array.new
  @allnewsof = Array.new
  @alloldeof = Array.new
  @allneweof = Array.new
  @alloldsof.push(0)
  @allnewsof.push(0)
  @alloldeof.push(0)
  @allneweof.push(0)
#get the addresses for both functions
 (1..@fc[0]).each { |func| 
  oldstartadd, oldendadd, oldfunction = @oldfile.funcbynum(func)
  @alloldsof.push(oldstartadd)
  @alloldeof.push(oldendadd)
}
 (1..@fc[1]).each { |func| 
  newstartadd, newendadd, newfunction = @newfile.funcbynum(func)
  @allnewsof.push(newstartadd)
  @allneweof.push(newendadd)
 }
#check to see if old function start address matches new function address
 (1..@fc[0]).each { |funcnumold|
  (1..@fc[1]).each { |funcnumnew|
    if (@alloldsof[funcnumold]==@allnewsof[funcnumnew])
     @funcsaddmatchold[funcnumold] = funcnumnew
    end
  }
 }
#the same in reverse
 (1..@fc[1]).each { |funcnumnew|
  (1..@fc[0]).each { |funcnumold|
    if (@alloldsof[funcnumold]==@allnewsof[funcnumnew])
     @funcsaddmatchnew[funcnumnew] = funcnumold
    end
  }
 }

#populate matching address arrays for both functions
#check to see if old function end address matches new function address
 (1..@fc[0]).each { |funcnumold|
  (1..@fc[1]).each { |funcnumnew|
    if (@alloldeof[funcnumold]==@allneweof[funcnumnew])
     @funceaddmatchold[funcnumold] = funcnumnew
    end
  }
 }
#the same in reverse
 (1..@fc[1]).each { |funcnumnew|
  (1..@fc[0]).each { |funcnumold|
    if (@alloldeof[funcnumold]==@allneweof[funcnumnew])
     @funceaddmatchnew[funcnumnew] = funcnumold
    end
  }
 }

#some testing...just to make sure things are working
#counting matching starting addresses
countoldss=0
  (1..@fc[0]).each { |func|
   if ( @funcsaddmatchold[func].nil? )
    countoldss +=1
   end
  }
countnewss=0
  (1..@fc[0]).each { |func|
   if ( @funcsaddmatchnew[func].nil? )
    countnewss +=1
   end
  }
puts "Old start addresses that don't match new ones: " + countoldss.to_s + " of " + @fc[0].to_s
puts "New start addresses that don't match old ones: " + countnewss.to_s + " of " + @fc[0].to_s

#checking old adresses...these should all match.  they're my wtf msg
countoldse=0
  (1..@fc[0]).each { |func|
   if ( @funceaddmatchold[func].nil? )
    countoldse +=1
   end
  }
countnewse=0
  (1..@fc[0]).each { |func|
   if ( @funceaddmatchnew[func].nil? )
    countnewse +=1
   end
  }
puts "Old end addresses that don't match new ones: " + countoldse.to_s
puts "New end addresses that don't match old ones: " + countnewse.to_s
#end testing...that's not definitive at all
end

def cmp_func_asm_only
#first pass let's try to eliminate the functions with matching start addresses
@neweliminated = Array.new(@fc[0])
@oldeliminated = Array.new(@fc[1])
@neweliminated[0] = 0
@oldeliminated[0] = 0
eliminated = 0
#we only need to do this in one direction
(1..@fc[0]).each {|func|
  oldasm = @oldfile.getfuncasm(func)
 #make sure we already determined a matching startadd
 if (!(@funcsaddmatchold[func].nil?))
   indexofnew = @funcsaddmatchold[func]
   newasm = @newfile.getfuncasm(indexofnew)
   if newasm.eql?(oldasm)
    #puts "We got a match...one function eliminated"
    @neweliminated[indexofnew] = func
    @oldeliminated[func] = indexofnew
    eliminated += 1
    end
  end
  } 

puts eliminated.to_s + " functions with the same starting address eliminated, first pass complete."
#p @neweliminated
#p @oldeliminated

#second pass, check by function index
eliminatedtp = 0

#an optimization to only do it from the smaller end
#<= is failing and it shouldn't bug...
if (@fc[2]<0)
 (1..@fc[0]).each {|func|
 if (@oldeliminated[func].nil?)
   oldasm = @oldfile.getfuncasm(func)
   newasm = @newfile.getfuncasm(func)
    if newasm.eql?(oldasm)
    #puts "We got a match...one function eliminated"
    @neweliminated[func] = func
    @oldeliminated[func] = func
    eliminatedtp += 1
    end
  end
  } 
else

(1..@fc[1]).each {|func|
 if (@neweliminated[func].nil?)
  oldasm = @oldfile.getfuncasm(func)
  newasm = @newfile.getfuncasm(func)
   if newasm.eql?(oldasm)
    #puts "We got a match...one function eliminated"
    @neweliminated[func] = func
    @oldeliminated[func] = func
    eliminatedtp += 1
  end
 end
  } 
 end
puts eliminatedtp.to_s + " functions with the same function index eliminated, second pass complete."
eliminated += eliminatedtp
#third pass...usually yields very little.  maybe move this down to later...
#it's slow too.  still good to try though.  good to see...
#check asm of each unmatched function against every other unmatched function
eliminatedtp = 0
if (@fc[2]>=0)
(1..@fc[0]).each {|func|
  if (@oldeliminated[func].nil?)
   (1..@fc[1]).each {|funca|
   if (@neweliminated[funca].nil?)
   oldasm = @oldfile.getfuncasm(func)
   newasm = @newfile.getfuncasm(funca)
    if newasm.eql?(oldasm)
    #puts "We got a match...one function eliminated"
    @neweliminated[funca] = func
    @oldeliminated[func] = funca
    eliminatedtp += 1
    end
   end
   }
  end
  }
else
(1..@fc[1]).each {|func|
  if (@oldeliminated[func].nil?)
   (1..@fc[0]).each {|funca|
   if (@neweliminated[funca].nil?)
   oldasm = @oldfile.getfuncasm(funca)
   newasm = @newfile.getfuncasm(func)
    if newasm.eql?(oldasm)
    #puts "We got a match...one function eliminated"
    @neweliminated[funca] = funca
    @oldeliminated[func] = func
    eliminatedtp += 1
    end
   end
   }
  end
  }
end#here
puts eliminatedtp.to_s + " functions with different starting index eliminated, third pass complete."
eliminated += eliminatedtp
eliminatedtp = 0
#p @neweliminated
#p @oldeliminated

puts eliminated.to_s + " functions eliminated.\n  Here comes our list of eliminated functions.  0 doesn't count.\n"
p @oldeliminated
p @neweliminated
puts "End of ruby for hackers ep1 pt1 section 2"
sleep 30

#fourth pass, now we have to examine basic blocks


end



begin
@oldfile = Bindump.new("immdump.old")
@newfile = Bindump.new("immdump.new")
#check function count

fc = func_count
foldnum, fnewnum, fchangenum = fc

puts "Old file: " + @oldfile.getfilename + " has " + foldnum.to_s + " functions"
puts "New file: " + @newfile.getfilename + " has " + fnewnum.to_s + " functions"
puts "We gained " + fchangenum.to_s + " new functions"
puts "Checking function addresses"
@funcsaddmatchold = Array.new(fc[0]+1)
@funcsaddmatchnew = Array.new(fc[1]+1)
@funceaddmatchold = Array.new(fc[0]+1)
@funceaddmatchnew = Array.new(fc[1]+1)
@funcsaddmatchold[0] = 0
@funcsaddmatchnew[0] = 0
@funceaddmatchold[0] = 0
@funceaddmatchnew[0] = 0
@funclensold # not implemented
@funclensnew # not implemented
#just testing to make sure some stuff is working on the next routine
func_addresses
#moving on...
cmp_func_asm_only

puts "still in alpha...just so you know"
end
