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

def getInputs(IN) :
    s = IN.input().rstrip()
    return (s,)

def solve(inp) :
    (s,) = inp
    lookup = {}
    for c in "abcdefghijklmnopqrstuvwxyz" : lookup[c] = '.'
    a0 = 'aozq'
    b0 = 'yeqz'## q->z is the only spare mapping left -- all others are given in the problem or the given examples
    a1 = "ejp mysljylc kd kxveddknmc re jsicpdrysi"
    b1 = "our language is impossible to understand"
    a2 = "rbcpc ypc rtcsra dkh wyfrepkym veddknkmkrkcd"
    b2 = "there are twenty six factorial possibilities"
    a3 = "de kr kd eoya kw aej tysr re ujdr lkgc jv"
    b3 = "so it is okay if you want to just give up"    
    for a,b in zip((a0,a1,a2,a3),(b0,b1,b2,b3)) :
        for c,d in zip(a,b) :
            if c in "abcdefghijklmnopqrstuvwxyz" : lookup[c] = d 
    tr1 = "abcdefghijklmnopqrstuvwxyz"
    tr2 = "".join(lookup[c] for c in tr1)
    ans = s.translate(str.maketrans(tr1,tr2))
    return ans

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()
