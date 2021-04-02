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
    n,l = IN.ints()
    words = [IN.input().rstrip() for x in range(n) ]
    return (n,l,words)

def solve(inp) :
    (n,l,words) = inp
    lettersByPos = doLetters(words,l)
    substrByPos  = doSubstrings(words,l)
    comboCounts = len(lettersByPos[0])
    for i in range(1,l) :
        comboCounts *= len(lettersByPos[i])
        if len(substrByPos[i]) <  comboCounts :
            return findMissingSubstr(i,lettersByPos,substrByPos) + ("" if i == l-1 else "".join(words[0][i+1:]))
    return "-"

def doLetters(words,l) :
    lettersByPos = [ set() for x in range(l) ]
    for w in words :
        for i in range(l) :
            lettersByPos[i].add(w[i])
    return lettersByPos

def doSubstrings(words,l) :
    substringsByPos = [ set() for x in range(l) ]
    for w in words :
        s = ""
        for i in range(l) :
            s = s + w[i]
            substringsByPos[i].add(s)
    return substringsByPos

def findMissingSubstr(i,lettersByPos,substrByPos) :
    ll = lettersByPos[i]
    s1 = substrByPos[i-1]
    s2 = substrByPos[i]
    for pre in s1 :
        for l in ll :
            if pre+l not in s2 : return pre+l
    return ""

#####################################################################################################
if __name__ == "__main__" :
    doit()

