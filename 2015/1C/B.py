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
    k,l,s = IN.ints()
    keys = IN.input().rstrip()
    target = IN.input().rstrip()
    return (k,l,s,keys,target)

def solve(inp) :
    (k,l,s,keys,target) = inp
    p = analyzeKeys(k,keys)
    pw = probWord(target,p)
    if pw == 0 or s < l : return "%.8f" % 0.00
    expectedWords = 0.0 if s < l else (s-l+1) * pw ## Linearity of expectation is a great thing
    mw = maxWords(target,l,s)
    return "%.8f" % (mw - expectedWords)

def analyzeKeys(k,keys) :
    d = {}
    for c in 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' : d[c] = 0.00
    for kk in keys :
        d[kk] += 1.0 / k
    return d

def probWord(target,p) :
    pp = 1.0
    for c in target : pp *= p[c]
    return pp

def maxWords(target,l,s) :
    minPrefixLen = l
    for i in range(1,l) :
        t = True
        for offset in range(l-i) :
            if target[offset] != target[i+offset] :
                t = False
                break
        if t :
            minPrefixLen = i
            break
    return 1 + ((s-l) // minPrefixLen)

#####################################################################################################
if __name__ == "__main__" :
    doit()
