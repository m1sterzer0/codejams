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
        with Pool(processes=2) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            printOutput(tt,ans)

#####################################################################################################

## Greedy seems to work
## a) Request the "mood" assignment if stack is empty
## b) Turn in if we have already requested as many as we should
## c) Turn in if we can get 10 points
## d) Otherwise request
##
## This seems to work because
## 1) There is no incentive to ever pick a different topic than the "mood" topic
##    (since matching the mood at the beginning == matching mood at the end)
## 2) Each assignment is then worth either 10 points or 5 points 
## 3) 2*5 == 1*10, so we are never better picking up more assignments than we can turn in

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    s = IN.input().rstrip()
    return (s,)

def solve(inp) :
    (s,) = inp
    ls = len(s)
    lsover2 = ls // 2
    st = []
    score = 0
    requests = 0
    for i,c in enumerate(s) :  ## Greedy approach
        if not st :                requests += 1; st.append(c)
        elif st[-1] == c :         score += 10; st.pop()
        elif requests == lsover2 : score += 5; st.pop()
        else                     : requests += 1; st.append(c)
    return "%d" % score



#####################################################################################################
if __name__ == "__main__" :
    doit()

