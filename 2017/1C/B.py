import collections
import functools
import heapq
import itertools
import math
import re
import sys
from fractions       import gcd
from fractions       import Fraction
from multiprocessing import Pool    
from operator        import itemgetter

class myin(object) :
    def __init__(self,default_file=None,buffered=False) :
        self.fh = sys.stdin
        self.buffered = buffered
        if(len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
        if (buffered) : self.lines = self.fh.readlines()
        self.lineno = 0
    def input(self) : 
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

def doit(fn=None,multi=False) :
    IN = myin(fn)
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    if (not multi) : 
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            printOutput(tt,ans)
    else :
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            printOutput(tt,ans)

#####################################################################################################

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    ac,aj = IN.ints()
    cameron = [tuple(IN.ints()) for x in range(ac) ]
    jaime = [tuple(IN.ints()) for x in range(aj) ]
    return (ac,aj,cameron,jaime)

def solve(inp) :
    (ac,aj,cameron,jaime) = inp
    cameron.sort(); jaime.sort()
    invervals = populateIntervals(cameron,jaime)
    fillGaps(intervals)
    growExisting(intervals)
    insertFiller(intervals)
    ans = countTransitions(intervals)
    return "%d" % ans

def populateIntervals(c,j) :
    i1 = [ (x[0],x[1],'c') for x in c ]
    i2 = [ (x[0],x[1],'j') for x in j ]
    commitments = sort(i1+i2)
    t = 0; intervals = []
    for c in commitments :
        b = c[0]
        if t < c : intervals.append((b-t,'x'))
        intervals.append( (c[1]-c[0], c[2]) )
        t = c[1]
    if t != 24 * 60 :
        intervals.append(24*60 - t,'x')
    if intervals[0][1] == 'x' and intervals[-1][1] == 'x' : 
        l = intervals[0][0] + intervals[-1][0]
        intervals.pop(0); intervals.pop()
        intervals.append( (l,'x') )
    return intervals

def fillGaps(ii) :
    if len(ii) < 3 : return
    gaps = []
    if ii[-1][1] == 'c' and ii[0][1]  == 'x' and ii[1][1] == 'c' : gaps.append( (ii[0][0],0) )
    if ii[-2][1] == 'c' and ii[-1][1] == 'x' and ii[0][1] == 'c' : gaps.append( (ii[-1][0],len(ii)-1) )
    for i in range(1,len(ii)-1) :
        if ii[i-1][1] == 'c' and ii[i][1] == 'x' and ii[i+1][1] == 'c' : gaps.append( (ii[i][0], i) )
    cameronTime = sum(x[0] for x in ii if x[1] == 'c')
    gaps.sort()
    for s,idx in gaps :
        if cameronTime + s > 12*60 : return
        cameronTime += s
        ii[idx] = ( ii[idx][0], 'c')

def growExisting(ii) :
    n = len(ii)
    cameronTime = sum(x[0] for x in ii if x[1] == 'c')
    if cameronTime == 12*60 : return
    ## First look for 'x's to the left of a 'c'
    nl = list(range(1,n)) + [0]
    nc = list(range(n))
    nr = [n-1] + list(range(n-1))
    for i,j in zip(nc,nl) :
        if ii[i][1] == 'x' and ii[j][1] == 'c' :
            s = ii[i][0]
            if cameronTime + s <= 12*60 :
                cameronTime += s
                ii[i] = (ii[i][0],'c')
                if cameronTime == 12*60 : return
            else :
                cameronTime = 12*60
                ii[i] = (ii[i][0],'jc')
                return
        
    for i,j in zip(nc,nr) :
        if ii[i][1] == 'x' and ii[j][1] == 'c' :
            s = ii[i][0]
            if cameronTime + s <= 12*60 :
                cameronTime += s
                ii[i] = (ii[i][0],'c')
                if cameronTime == 12*60 : return
            else :
                cameronTime = 12*60
                ii[i] = (ii[i][0],'cj')
                return


    
    







    res = []
    ic,ij = 0,0
    t = 0
    while ic < len(c) or ij < len(j) :
        if ic < len(c) and ij < len(j) :
            nexttime = c[ic][0]





    ## If cameron has an activity at 0, then we swap cameron and jaime
        
    ## 

        ## We can probably do this better, but this is what we're going to try
        ## value of 'J' means that 'J' has to watch here
        ## value of 'C' means that 'C" has to watch here
        ## value of 'j' means we are scheduling jaime 
        ## value of 'c' means we are scheduling cameron
        schedule = ['c'] * (24 * 60)
        for t in range(aj) :
            for x in range(t[0],t[1]) : schedule[x] = 'J'
        for t in range(ac) :
            for x in range(t[0],t[1]) : schedule[x] = 'C'

        transitions,last = 0,0
        for t in range(ac) :
            if t[0] != last : transitions += 1
            last = t[1]

        last = 'x'; gapStart = False; gapleft = 0; gaps = []
        for i in range(24 * 60) :
            if last == 'J' and schedule[i] == 'c' :
                gapStart = True; gapLeft = i
            elif schedule[i] == 'C' : gapStart = False
            elif gapStart and schedule[i] == 'J' :
                

        ## Now we look to find strings of Js without any intervening C's












#####################################################################################################
if __name__ == "__main__" :
    doit()

































import sys
import math
class myin(object) :
    def __init__(self,default_file=None,buffered=False) :
        self.fh = sys.stdin
        self.buffered = buffered
        if(len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
        if (buffered) : self.lines = self.fh.readlines()
        self.lineno = 0
    def input(self) : 
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        print("Case #%d: %.8f" % (tt,0))
        ac,aj = IN.ints()
        cameron,jaime = [],[]
        for _ in range(ac) : ci,di = IN.ints(); cameron.append((ci,di))
        for _ in range(aj) : ji,ki = IN.ints(); jaime.append((ji,ki))
        cameron.sort(); jaime.sort()
        
        ## If cameron has an activity at 0, then we swap cameron and jaime
        if ac > 0 and cameron[0][0] == 0 : ac,aj = aj,ac; cameron,jaime = jaime,cameron
        
        ## We can probably do this better, but this is what we're going to try
        ## value of 'J' means that 'J' has to watch here
        ## value of 'C' means that 'C" has to watch here
        ## value of 'j' means we are scheduling jaime 
        ## value of 'c' means we are scheduling cameron
        schedule = ['c'] * (24 * 60)
        for t in range(aj) :
            for x in range(t[0],t[1]) : schedule[x] = 'J'
        for t in range(ac) :
            for x in range(t[0],t[1]) : schedule[x] = 'C'

        transitions,last = 0,0
        for t in range(ac) :
            if t[0] != last : transitions += 1
            last = t[1]

        last = 'x'; gapStart = False; gapleft = 0; gaps = []
        for i in range(24 * 60) :
            if last == 'J' and schedule[i] == 'c' :
                gapStart = True; gapLeft = i
            elif schedule[i] == 'C' : gapStart = False
            elif gapStart and schedule[i] == 'J' :
                

        ## Now we look to find strings of Js without any intervening C's

