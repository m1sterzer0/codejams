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
    if ac + aj == 1 : ans = 2
    elif ac == 1 and aj == 1 : ans = 2
    elif ac == 2:
        (a,b),(c,d) = cameron[0],cameron[1]
        if d-a > 720 and b - c + 1440 > 720 : ans = 4
        else                                : ans = 2
    else :
        (a,b),(c,d) = jaime[0],jaime[1]
        if d-a > 720 and b - c + 1440 > 720 : ans = 4
        else                                : ans = 2
    return "%d" % ans    

def populateIntervals(c,j) :
    i1 = [ (x[0],x[1],'c') for x in c ]
    i2 = [ (x[0],x[1],'j') for x in j ]
    commitments = sorted(i1+i2)
    t = 0; intervals = []
    for c in commitments :
        intervals.append((c[0]-t,'x'))
        intervals.append((c[1]-c[0], c[2]))
        t = c[1]
    intervals.append((24*60-t,'x'))
    intervals = [x for x in intervals if x[0] > 0]  ## Filter out zero length intervals
    if intervals[0][1] == intervals[-1][1] : ## Wrap around case
        intervals[0] = (intervals[0][0] + intervals[-1][0],intervals[0][1])
        intervals.pop()
    return intervals

def fillGaps(ii) :
    nl = [ii[-1]] + ii[:-1]
    nr = ii[1:] + [ii[0]]

    group1 = [x for ll,x,rr in zip(nl,ii,nr) if ll[1] == 'c' and x[1] == 'x' and rr[1] == 'c']
    group2 = [x for ll,x,rr in zip(nl,ii,nr) if ll[1] == 'j' and x[1] == 'x' and rr[1] == 'c']
    group3 = [x for ll,x,rr in zip(nl,ii,nr) if ll[1] == 'c' and x[1] == 'x' and rr[1] == 'j']
    group4 = [x for ll,x,rr in zip(nl,ii,nr) if ll[1] == 'j' and x[1] == 'x' and rr[1] == 'j']

    group1.sort()
    group2.sort(reverse=True)

    transitions = 2 * sum(1 for x in ii if x[1] == 'c')
    cameronTime = sum(x[0] for x in ii if x[1] == 'c')
    targetTime = 12*60

    for s,_ in group1 :
        if cameronTime + s > targetTime : return transitions
        transitions -= 2; cameronTime += s
    
    for s,_ in group2+group3 :
        cameronTime += s

    if cameronTime >= targetTime : return transitions

    for s,_ in group4 :
        transitions += 2
        cameronTime += s
        if cameronTime >= targetTime : return transitions

#####################################################################################################
if __name__ == "__main__" :
    doit()
