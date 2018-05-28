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

mtable = {}

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    l,x = IN.ints()
    s = IN.input().rstrip()
    return (l,x,s)

def solve(inp) :
    (l,x,s) = inp
    if not checkProd(s,x) : return "NO"
    tf1,x1,numchar1 = findi(s)
    tf2,x2,numchar2 = findk(s)
    if not tf1 or not tf2 : return "NO"
    repeats = x1 + x2 + (1 if numchar1 + numchar2 < l else 2)
    if repeats <= x : return "YES"
    return "NO"

def presolve() :
    q = ['1','-1','i','j','k','-i','-j','-k']
    small = {}
    for x in ['1','i','j','k'] : small[x] = {}
    for x,y in zip(['1','i','j','k'],['1','i','j','k'])   : small['1'][x] = y
    for x,y in zip(['1','i','j','k'],['i','-1','k','-j']) : small['i'][x] = y
    for x,y in zip(['1','i','j','k'],['j','-k','-1','i']) : small['j'][x] = y
    for x,y in zip(['1','i','j','k'],['k','j','-i','-1']) : small['k'][x] = y
    
    global mtable
    for a in q :
        mtable[a] = {}
        for b in q :
            negatives = 1 if a[0] == '-' else 0
            if b[0] == '-' : negatives += 1
            c = small[a[-1]][b[-1]]
            if c[0] == '-' : negatives += 1
            ans = c[-1] if negatives % 2 == 0 else '-' + c[-1]
            mtable[a][b] = ans

    #for a in q :
    #    for b in q :
    #        print("%s * %s = %s" % (a,b,mtable[a][b]))

    return mtable

def checkProd(s,x) :
    p = '1'
    for xx in s : p = mtable[p][xx]
    if p == '1' : return False
    if p == '-1' : return True if x % 2 == 1 else False
    return True if x % 4 == 2 else False

def findi(s) :
    p = '1'
    for i in range(4) :
        for j,xx in enumerate(s) :
            p = mtable[p][xx]
            if p == 'i' : return True,i,j+1
    return False,0,0

def findk(s) :
    p = '1'
    ss = s[::-1]
    for i in range(4) :
        for j,xx in enumerate(ss) :
            p = mtable[xx][p]
            if p == 'k' : return True,i,j+1
    return False,0,0

#####################################################################################################
if __name__ == "__main__" :
    presolve()
    doit()

