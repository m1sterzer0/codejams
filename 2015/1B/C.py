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

class MinHeap(object):
  def __init__(self): self.h = []
  def __len__(self): return len(self.h)
  def __getitem__(self,i): return self.h[i]
  def push(self,x): heapq.heappush(self.h,x)
  def pop(self): return heapq.heappop(self.h)
  def empty(self) : return False if self.h else True
  def top(self) : return self.h[0]

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n = int(IN.input())
    h = [0] * n; d = [0] * n; m = [0] * n
    for i in range(n) :
        d[i],h[i],m[i] = IN.ints()
    return (n,h,d,m)

## *  The "lightning fast" case is just to let the horse run around the circle very fast and cross all of the hikers once.
##    otherwise, the crossings just depend on the end time of the horse.
## 
## * The only acceptable end times are "right behind" another hiker on his first lap
## 
## * The only way we improve upon the time above is to get more help from stalling then hurt,
##   and each hiker can "help" only once.
## 
## * Once we pull out a numHikers "hurting" events, we cant get better than the baseline, so we are done
## 
## * Thus, we end up inserting numHikers "helping" events into a priority queue, and numHikers "hurting" events
##   this makes it n log n and makes it (hopefully) work.
## 
## Finally, we can choose the time unit as minutes/360, as this lets us avoid division.

def solve(inp) :
    (n,h,d,m) = inp
    if n == 1 and h[0] == 1 : return str(0) ## We can always hide behind one hiker
    bestscore = sum(x for x in h)  
    (d2,m2) = expand(n,h,d,m)
    mh = MinHeap()
    runningScore = bestscore
    for (dd,mm) in zip(d2,m2) :
        tt = (360-dd) * mm
        mh.push( (tt, -1, dd, mm) )
    badEvents = 0
    numHikers = len(d2)
    while badEvents < numHikers :
        (tt, inc, dd, mm) = mh.pop()
        runningScore += inc
        if inc > 0 : badEvents += 1
        if mh.top()[0] > tt :
            bestscore = min(bestscore,runningScore)  ## Only check at the end of a time step
        mh.push( (tt+360*mm, 1, dd, mm) )
    return "%d" % bestscore
    
def expand(n,h,d,m) :
    d2 = []; m2 = []
    for hh,dd,mm in zip(h,d,m) :
        for i in range(hh) :
             d2.append(dd); m2.append(mm+i)
    return d2,m2

#####################################################################################################
if __name__ == "__main__" :
    doit()
