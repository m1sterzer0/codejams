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
anscache = {}
cache = {}
for x in range(2,11) : cache[x] = {} 

def getInputs(IN) :
    b = tuple(IN.ints())
    return (b,)

def solve(inp) :
    (b,) = inp
    rb = tuple(reorderBases(b))
    if rb not in anscache :
        anscache[rb] = findFirst(rb)
    return "%d" % anscache[rb]

def check(n,b) :
    s =set()
    while n != 1 and n not in s and n not in cache[b]:
        s.add(n)
        n = iterate(n,b)
    if n == 1 :
        for x in s : cache[b][x] = True
        return True
    elif n in cache[b] :
        for x in s : cache[b][x] = cache[b][n]
        return cache[b][n]
    else :
        for x in s : cache[b][x] = False
        return False       

def iterate(n,b) :
    ans = 0
    while n > 0 :
        x = n % b
        ans += x * x
        n //= b
    return ans

def reorderBases(bases) :
    rbases = []
    for b in (7,8,6,9,10,5,3) :
        if b in bases : rbases.append(b)
    return rbases

def findFirst(bases) :
    x = 2
    rbases = reorderBases(bases)
    while True :
        #if (x % 1000000 == 0) : print("DEBUG: Trying %d" % x)
        flag = True
        for b in rbases :
            if not check(x,b) : 
                flag=False; break
        if flag : return x
        x += 1

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()

