import collections
import functools
import heapq
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

def getInputs(IN) :
    s, = IN.strs()
    return (s,)

def solve(inp) :
    (s,) = inp
    dlist = [0] + list(int(x) for x in s)
    next_permutation(dlist)
    if dlist[0] == 0 : dlist.pop(0) 
    ans = "".join(str(x) for x in dlist)
    return ans

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def next_permutation(a) :
    for i in range(len(a)-2,-1,-1) :
        if a[i] < a[i+1] :
            for j in range(len(a)-1,i,-1) :
                if a[j] > a[i] :
                    a[i],a[j] = a[j],a[i]
                    a[i+1:] = reversed(a[i+1:])
                    return True
    return False

#####################################################################################################
if __name__ == "__main__" :
    doit()
