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
import string

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    n = int(IN.input())
    people = list(IN.ints())
    return (n,people)

def solve(inp) :
    (n,people) = inp
    capLetters = [x for x in string.ascii_uppercase]
    s = sorted(zip(capLetters[0:n],people), reverse=True, key=itemgetter(1))
    ans = []

    ## Step 1, remove from the majority party until matched with the 2nd place party
    ## Step 2, remove everyone that isn't from the first two parties.
    ## Step 3, remove the people from the top two parties in pairs
    for i in range(s[0][1]-s[1][1]) : ans.append(s[0][0])
    for i in range(2,n) :
        for j in range(s[i][1]) :
            ans.append(s[i][0])
    pairStr = s[0][0] + s[1][0]
    for i in range(s[1][1]) : ans.append(pairStr)
    return " ".join(ans)

#####################################################################################################
if __name__ == "__main__" :
    doit()
