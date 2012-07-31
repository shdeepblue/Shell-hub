#
#   _ _ _ _ _                        ((
#  |=|=|=|=|=|.----------------.    _))_
#  |-|-|-|-|-||  AWK Cookbook  | ___\__/)_
#  |_|_|_|_|_|'----------------. |_|_~~_|_|
#
# For more info, see http://awkcookbook.info

# Revision: 262

#######################################################################
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Lesser General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this program.  If not, see
# <http://www.gnu.org/licenses/>.
########################################################################


 function createFile(string, path, filename)
 {
     print string > path"/"filename;
 }

 function appendFile(string, path, filename)
 {
     print string >> path"/"filename;
 }

 function readNthLineInfile(filename, n)
 {
     current=0;
     line="";
     while ((getline < filename) > 0)
     {
         if (++current == n)
         {
             line = $ALL;
             break;
         }
     }
     close(filename);
     return line;
 }

 function takeApart1(      str,find,x) {
       str  = "abc"
       find = "a"
       x    = index(str, find)
       return x
 }

 function takeApart2(    str,find,x) {
	str  = "abc"
	find = "b"
	x    = index(str, find)
        return x
 }

 function takeApart3(    str,find,x) {
       str  = "abc"
       find = "c"
       x    = index(str, find)
       return x
 }

 function takeApart4(    str,find,x) {
	str  = "abc"
	find = "C"
	x    = index(str, find)
	return x
 }

 function demoDateTime() {
      ##-------------------------------------------
      # basic
      print "the_date            : " strftime("%x") 
      print "the_time            : " strftime("%X") 
      print "the_zone            : " strftime("%Z") 
	  #
      ##-------------------------------------------
      ## minutes/secs
      # minute as decimal (00-59)
      print "the_minute          : " strftime("%M") 
      # second of minute as decimal (00-60)
      print "the_second          : " strftime("%S") 
      # 
      ##-------------------------------------------
      ## day/hour
      print "the_name_of_day     : " strftime("%A") 
      print "the_hour_twelve     : " strftime("%I") 
      print "the_hour_twentyfour : " strftime("%H") 
      # locale's equivalent of AM/PM
      print "the_ampm            : " strftime("%p") 
      #
      ##-------------------------------------------
      ## by week
      # weekday as decimal (0-6) starts with Sunday
      print "sun_day_of_week     : " strftime("%w") 
      # weekday as decimal (1-7) starts with Monday
      print "mon_day_of_week     : " strftime("%u") 
      #
      ##-------------------------------------------
      ## by month
      # month as decimal (01-12)
      print "the_month           : " strftime("%m") 
      # locale's full month nam
      print "the_name_of_month   : " strftime("%B") 
      # day of the month as decimal (01-31)
      print "the_day_of_month    : " strftime("%d") 
      #
      ##-------------------------------------------
      ## by year
      # year as decimal (2010)
      print "the_year            : " strftime("%G") 
      # day of the year as decimal (001-366)
      print "the_day_of_year     : " strftime("%j") 
      # week of year (00-53) starts with Sunday
      print "sun_week_of_year    : " strftime("%U") 
      # week of year (01-53) starts with Monday
      print "mon_week_of_year    : " strftime("%V") 
 }

 function isNum(x) {
   return(x == x + 0)
 }

 function rInt(low, hi,    x, y, z) {
     seed()
     x = rand()
     y = (hi - low) + 1
     z = int((x * y) + low)
     return z
}

 function rFloat(low, hi,    x, y, z) {
     seed()
     x = rand()
     y = hi - low
     z = (x * y) + low
     return z
}

 function StringsDemo(   x, y1, y2, z1, z2, z3, z4) {
 	x = "abc"
 	x = "123"
 	y1= "panos" x "papadoupoulous"
 	y2= "panos" + x + "papadopoulos"
 	z1= "panos123" + 1
 	z2= "123paons" + 1
 	z3= "123.23panos" + 1
 	z4= "   123panos" + 1
 	print("x=["x"] y1=["y1"] z1=["z1"] z2=["z2"] z3=["z3"] z4=["z4"]")
 }   

 function trim(s) {
 	sub(/^[ \t\r\n]+/, "", s)
 	sub(/[ \t\r\n]+$/, "", s)
 	return(s)
 }

 # final version
 function trimStr(s, lrb, wcre) {
 	ok(lrb ~ /[rRlLbB]/, "trimStr: ["lrb"] bad lrb arg",2)
 	lrb  = lrb  ? lrb  : "r"
 	wcre = wcre ? wcre : "[ \t\r\n]+"
 	if (lrb ~ /[lLbB]/) sub("^" wcre, "", s)
 	if (lrb ~ /[rRbB]/) sub(wcre "$", "", s)
 	return(s)
 }

 function TrimStr(    x,y,tmp) {	
 	split("  _ 1 2 3 ,arthur", tmp, ",")
 	for(x in tmp) {
 		if (y = trimStr(x, "b", "[^a-zA-Z_]+"))
 			print y
 	}
 }

 function get_user_info(name, data,		ufile, ofs, found) {
 	delete data	# don't forget
 	found = 0
 	ufile = "/etc/passwd"
 	ofs = FS
 	FS = ":"
 	while ((getline <ufile) > 0) {
 		if ($1 == name) {
 			data["uid"] = $3
 			data["gid"] = $4
 			data["info"] = $5
 			data["home"] = $6
 			data["shell"] = $7
 			found = 1
 			break
 		}
 	}
 	close(ufile)
 	FS = ofs
 	return(found)
 }

 function csvArray(arr, from, to,		i, first) {
 	if (from != "") {
 		printf arr[from]
 		for (i = from + 1; i <= to; i++)
 			printf "," arr[i]
 	}
 	else {
 		first = 1
 		for (i in arr) {
 			if (first) {
 				printf arr[i]
 				first = 0
 			}
 			else
 				printf "," arr[i]
 		}
 	}
 	print ""
 }

 function arrayKeyExists(arr, idx) {
 	return(idx in arr)
 }

 function arrayValueExists(arr, val,		i) {
  	for (i in arr) {
  		if (val == arr[i])
  			return(i)
  	}
  	return("")
 }

 function arrayValueOccurences(arr, val,	i, n) {
 	for (i in arr) {
 		if (val == arr[i])
 			n++
 	}
 	return(n + 0)
 }

 function findMaxNum(arr,			i, max) {
 	for (i in arr) {
 		if ((arr[i] + 0) > (max + 0))
 			max = arr[i]
 	}
 	return(max)
 }

 function findMinNum(arr,			i, min) {
 	for (i in arr) {
 		if ((arr[i] + 0) < (min + 0))
 			min = arr[i]
 	}
 	return(min)
 }

 function findMax(arr, cmp,		i, maxi) {
 	for (i in arr) {
 		if (maxi == "")
 			maxi = i
 		else if (cmp(arr, i, maxi) > 0)
 			maxi = i
 	}
 	return(maxi)
 }

 function cmp(arr, i, j,			a, ai) {
 	split(arr[i], ":", a)
 	ai = a[3]
 	split(arr[j], ":", a)
 	if (ai < a[3])
 		return(-1)
 	if (ai > a[3])
 		return(1)
 	return(0)
  }

 function reverseArray(arr, from, to,		errs, x, count) {
 	if (from == "")
 		from = 0
 	else if (from ~ /^[ \t]*[0-9]+[ \t]*$/)
 		from += 0
 	else
 		errs += warning("reverseArray: invalid `from' " \
			"index (" from ")")
 	if (to ~ /^[ \t]*[0-9]+[ \t]*$/)
 		to += 0
 	else if (to != "")
 		errs += warning("reverseArray: invalid `to' " \
			"index (" to ")")
 	notOk(errs)
 	if (!(from in arr))
 		errs += barph("reverseArray: `from' " \
			"index out of range (" from ")")
 	# If not given the upper index, the seek it stepping one
 	# by one after the low index. If there are gaps in the
 	# array (some indices are missing) the the elements after
 	# the first gap will be ignored!
 	if (to == "") {
 		for (to = from + 1; to in arr; to++)
 			;
 		to--
 	}
 	# Normally, this is the point to check for the existence
 	# of the `to' index. But we leave that free in order to
 	# give the flexibility to create new elements as needed,
 	# e.g. given the array a[1], a[2], a[3] we can call
 	# reverseArray(a, 1, 10) and produce a[1]...a[10], puting
 	# a[1] to a[10], a[2] to a[9] and a[3] to a[8].
 	if (to < from)
 		errs += barph("reverseArray: invalid index range (" \
 			from " - " to ")")
 	for (count = 0; from < to; count++) {
 		x = arr[from]
 		arr[from] = arr[to]
 		arr[to] = x
 		from++
 		to--
 	}
 	return(count)
 }

 function TestRevArr(			a, i) {
 	# Create an array of 20 elements indexed zero
 	# based.
 	for (i = 0; i < 10; i++)
 		a[i] = "element_" i
 	# Reverse only the elements 3 throuh 7.
 	reverseArray(a, 3, 7)
 	for (i = 0; i < 10; i++)
 		print i ": " a[i]
 }

 function shuffleDeck(deck, count,		i, n, card) {
 	seed(1) 
 	for (i = 0; i < count; i++) {
 		n = int(rand() * count)
 		card = deck[i]
 		deck[i] = deck[n]
 		deck[n] = card
 	}
 }

 function ShuffleDeck52(		deck) {
 	newDeck52(deck)
 	shuffleDeck(deck, 52)
 	dealDeck(deck, 52)
 }

 function newDeck52(deck,	suits, figure, suit, i, n) {
	delete deck
 	suits["spades"]
 	suits["clubs"]
 	suits["diamonds"]
 	suits["hearts"]
	for (i = 2; i <= 10; i++)
 		figure[i] = i
 	figure[1] = "A"
 	figure[11] = "J"
 	figure[12] = "Q"
 	figure[13] = "K"
 	for (suit in suits) {
 		for (i = 1; i <= 13; i++)
 			deck[n++] = figure[i] " of " suit
 	}
 }

 function dealDeck(deck, count,		i) {
 	for (i = 0; i < count; i++)
 		print deck[i]
 }

 function testVars(x, y,z) {
 	if ((x <= 0) || (y <= 0))
 		return(0)
 	z = sqrt((x * x) + (y * y))
 	if (z > (2 * x))
 		return(z)
 	return(x)
 }

 function arrayTable(arr, tstyle, dstyle,		i, header) {
 	# dstyle is used for styling <td> data (table cells).
 	if (!dstyle)
 		dstyle = "style=\"border-style: inset; " \
			"border-width: 2px;\""
 	for (i in arr) {
 		if (!header) {
 			# tstyle is used for styling the table as a whole.
 			print "<table " (tstyle ? tstyle : \
 				"style=\"border-style: outset; " \
				"border-width: 1px;\"") ">"
 			header = 1
 		}
 		print "\t<tr>"
 		print "\t\t<td " dstyle ">"
 		print i
 		print "\t\t</td>"
 		print "\t\t<td " dstyle ">"
 		print arr[i]
 		print "\t\t</td>"
 		print "\t</tr>"
 	}
 	if (header)
 		print "</table>"
 }

 function isNumString(x) {
	return x ~ \
      /^[+-]?([0-9]+[.]?[0-9]*|[.][0-9]+)([eE][+-]?[0-9]+)?$/
 }

 function seed( seed0) {
      seed0 = seed0 ? seed0 : systime() + PROCINFO["pid"]
      srand(Seed ? Seed : seed0)
 }

 function warning(str,    exitCode) {
     exitCode = exitCode ? exitCode : 1
     print "#"Program" warning: " str   >> "/dev/stderr";
     fflush("/dev/stderr");
	 Patience--
	 if (Patience == 0) 
	 	exit exitCode
 }

 function barph(str,  exitCode) {
     exitCode = exitCode ? exitCode : 1
     warning(str,   exitCode)
     exit exitCode; 
 }

 function ok(status,warning,    exitCode) {
	if (!status)
	  barph(warning,exitCode)
 }

 function notOk(status,warning,    exitCode) {
	if (status)
	  barph(warning,exitCode)
 }

 function a2s(a,sep,  start, stop,  tmp, out,i) { 
     sep   = sep ? sep : ","
     start = start ? start : 1
     stop  = stop ? stop : a[0]
     for(i=start;i<=stop;i++) 
         out = out (i > start ? sep : "") a[i]     
     return out
 }  

 function basename(path,  n,tmp) {
	n = split(path,tmp,/\//)
	return tmp[n]
 }

 function deShell(str) {
     gsub(/["`\$;\|&><]/,"",str);
     return str
 }

 function factorial(n,  out,i) {
     if (n < 1) 
         return 1;
     out = 1
     for(i=2;i<=n;i++) 
         out *= i
     return out
 }

 function no(x) {return (x == "") }

 function s2a(str,a,  sep,blankp,  tmp,n,i) {
    sep    = sep    ? sep    : ","
    blankp = blankp ? blankp : 0
    n= split(str,tmp,sep)
    for(i=1;i<=n;i+=2) 
        if (blankp)
            a[tmp[i]]= tmp[i+1]
        else
            a[trim(tmp[i])]= trim(tmp[i+1]);
    return n/2
 }

 function optionsDemo(opt) { # returns 0 if bad options
      s2a("a=1;c=;h=",opt,"[=;]")
      ARGC = options(opt,ARGV,ARGC)
 }

 function options(opt,input,n,  key,i,j,k,tmp) {
   for(i=1;i<=n;i++)  { # explore argstill no more flags
      key = input[i];
      if (sub(/^[-]+/,"",key))  { # we have a new flag
	 if (key in opt)         # if legal flag, change its value
	     opt[key] = (no("a" opt[key])) ? 1 : input[++i]  
	  else 
	     barph("-"key" unknown.")
      } else {
	   i--;
	   break;
	}
   }
   for(j=i+1;j<=n;j++)  # copy to tmp, what's left on the input
       tmp[j-i]=input[j]
   split("",input,"")   # reset the input args
   for(k in tmp)        #  move the copy back to the input args
	input[k] = tmp[k] 
   n -= i
   return n
 }

 function constants() {
   Inf    = 10^32;
   Ninf   = -1 * Inf;
   Ee     = 848456353 / 312129649; # 2.71...
   Pi     = 428224593349304 / 136308121570117; # 3.14...
   good to 29 digits
   Sp     = " ";
   Q      = "\"";
   White  = "^[ \t\n\r]*$";
   Number="^[+-]?([0-9]+[.]?[0-9]*|[.][0-9]+)([eE][+-]?[0-9]+)?$"
   _      = SUBSEP; 
 }

 function globals() {
     Patience=20
	 Program="ACB"
 }

 function o(a, str,control,   i,com) {
     str = str ? str : "array"
     if (control ~ /^[0-9]/)  {
         if (control==0)
             o1(a,str)
         else
             for(i=1;i<=control;i++)
                 print oprim(str,i,a)
     } else
         if (0 in a) # sometimes i store array size in a[0]
	     o(a,str,a[0])         
         else {
             com = control ? control : " -n -k 2" 
             com = "sort " com  " #" rand(); # com is unique
             for(i in a)
                 print oprim(str,i,a) | com;
             close(com); }
 }

 function oprim(prefix,i,a,  j) {
     j=i
     gsub(SUBSEP,",",j) 
     return prefix "[ " j " ]\t=\t [ " a[i] " ]"
 }

 function oo(a,prefix, i) {
     for(i in a)
         print oprim(prefix,i,a)
 }

 function os(a1,pre1,a2,pre2,a3,pre3,a4,pre4,a5,pre5) {
     if(pre1) o(a1,pre1);
     if(pre2) o(a2,pre2);
     if(pre3) o(a3,pre3);
     if(pre4) o(a4,pre4);
     if(pre5) o(a5,pre5)
 }

 function oos(a1,pre1,a2,pre2,a3,pre3,a4,pre4,a5,pre5) {
     if(pre1) oo(a1,pre1);
     if(pre2) oo(a2,pre2);
     if(pre3) oo(a3,pre3);
     if(pre4) oo(a4,pre4);
     if(pre5) oo(a5,pre5)
 }

 function Rank(  d,r) {
     split("1,1,1,1,1",   d,","); rank(d,r); o(r,"r1");
     split("1,2,3,4,5",   d,","); rank(d,r); o(r,"r5");
     split("1,1,10,10",   d,","); rank(d,r); o(r,"r110"); 
     split("1,1,10,10,20",d,","); rank(d,r); o(r,"r11020");
     split("5,7,2,1,4,4,8,2,3,6,7",d,","); 
	 rank(d,r); o(r,"ro");  
     print r[1] == 1
     print r[7] == 9.5
     print r[3] == 4
     print r[8] == 11
 }

 function rank(data0,ranks,     \
               data,starter,n,old,start,skipping,sum,i,j,r) {
     starter="someCraZYsymBOL";
     n     = asort(data0,data)    
     old   = starter
     start = 1;
     delete ranks;
     for(i=1;i<=n;i++) {
	 skipping = (old == starter) || (data[i] == old);
	 if (skipping) {
	     sum += i 
	 } else {
	     r = sum/(i - start)
	     for(j=start;j<i;j++) 
		 ranks[data[j]] = r;
	     start = i;
	     sum   = i;
	 }
	 old=data[i]
     }
     if (skipping) {
	 ranks[data[n]] = sum/(i - start)
     } else {
	 if (! (data[n] in ranks))
	     ranks[data[n]] = n #int(r+1.4999)
     }
 }

 function mwu(x,pop1,pop2,up,critical,                 \
	      i,data,ranks,n,n1,sum1,ranks1,n2,sum2,ranks2, \
	      correction,meanU,sdU,z) 
 {
     for(i in pop1) data[++n]=pop1[i]
     for(i in pop2) data[++n]=pop2[i]
     rank(data,ranks)
     for(i in pop1) { n1++; sum1 += ranks1[i] = ranks[pop1[i]] }
     for(i in pop2) { n2++; sum2 += ranks2[i] = ranks[pop2[i]] }
     #
     meanU      = n1*(n1+n2+1)/2;  # symmetric, just use pop1's z
     sdU        = (n1*n2*(n1+n2+1)/12)^0.5
     correction = sum1 > meanU ? -0.5 : 0.5  
     z          = abs((sum1 - meanU + correction )/sdU)
     # 
     if (z >= 0 && z <= critical) 
	 return 0
     if (up) 
	 return median(ranks1,n1) - median(ranks2,n2) 
     else
	 return median(ranks2,n2) - median(ranks1,n1) 
 }

 function wilcoxon(pop1,pop2,up,critical,	\
		   ranks,w0,w,correction,z,sigma,\
                   i, delta, n,diff,absDiff) {
     for(i in pop1) {
	 delta = pop1[i] - pop2[i]
	 if (delta) { 
	     n++
	     diff[i]    = delta
	     absDiff[i] = abs(delta) 
	 }
     }
     rank(absDiff,ranks)
     for(i in absDiff)  {
	 w0 = ranks[absDiff[i]] 
	 w += (diff[i] < 0)  ? -1*w0  :  w0
     }
     sigma = sqrt((n*(n+1)*(2*n+1))/6)
     z = (w - 0.5) / sigma; 
     if (z >= 0 && z <= critical) 
	 return 0
     else  
	 return up ? w : -1*w
 }
 function criticalValue(conf) {
     conf = conf ? conf  : 95
     if (conf==99) return 2.326
     if (conf==95) return 1.960 
     if (conf==90) return 1.645
 }

 function abs(x) { return x < 0 ? -1*x : x}

 function median(a,n,   low) {
     low = int(n/2);
     return oddp(n) ?  a[low+1] : (a[low] + a[low+1])/2
 }

 function oddp(n) { return n % 2 }

 function nkeep(x,m) {
     m["n"]++;
     m["s"]  += x
     m["s2"] += x^2
 }
 function nmean(m) {
     return m["s"] / m["n"]
 }
 function nsd(m) {
     return sd(m["s2"],m["s"],m["n"])
 }
 function sd(sumSq,sumX,n) {
     return sqrt((sumSq-((sumX*sumX)/n))/(n-1));
 }

 function Nkeep(   i,m) {
     for(i=1;i<=30;i++)
         nkeep(i,m)
     print nmean(m), nsd(m);
 }

 function gaussianPdf(m,s,x) {
     return 1/(s*sqrt(2*Pi))*Ee^(-1*(x-m)^2/(2*s*s))
 }

 function nsample(m,s,n,a,     i) {
     for(i=1;i<=n;i++)
         a[i]=normal(m,s)
 }
 function normal(m,s) {
     return m+box_muller()*s;
 }
 function box_muller(m,s,    n,x1,x2,w) {
     w=1;
     while (w >= 1) {
         x1= 2.0 * rand() - 1;
         x2= 2.0 * rand() - 1;
         w = x1*x1 + x2*x2};
     w = sqrt((-2.0 * log(w))/w);
     return x1 * w;
 }

 function Nsample(   a,i,m,samples)  {
     seed(1)
     samples=1000
     nsample(100,10,samples,a)
     for(i in a)
         nkeep(a[i],m)
     print nmean(m), nsd(m);
 }
