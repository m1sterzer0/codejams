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

import bisect
glist  = []
def presolve() :
    global glist
    ans = []
    for n in range(1,51) :
        leftPlace = 10**(n-1)
        middlePlace = 10**(n//2)  ## Only for odd N
    
        ## One nonzero-digit
        if n == 1 : ans.append(1); ans.append(4); ans.append(9)
    
        ## Two nonzero-digits
        if n >= 2 :
            b = 1 * leftPlace + 1; ans.append(b*b)
            b = 2 * leftPlace + 2; ans.append(b*b)
    
        ## Three nonzero-digits
        if n >= 3 and n & 1 :
            b = 1 * leftPlace + 1 * middlePlace + 1; ans.append(b*b)
            b = 1 * leftPlace + 2 * middlePlace + 1; ans.append(b*b)
            b = 2 * leftPlace + 1 * middlePlace + 2; ans.append(b*b)
    
        ## Four and five nonzero-digits -- choose 1
        if n >= 4 :
            b = 1 * leftPlace  +  1
            for i in range(1,n//2) :
                b2 = b + 1 * 10**i + 1 * 10**(n-i-1); ans.append(b2*b2)
                if n >= 5 and n & 1:
                    b3 = b2 + 1 * middlePlace
                    b4 = b2 + 2 * middlePlace
                    ans.append(b3*b3)
                    ans.append(b4*b4)
    
        ## Six and seven nonzero-digits -- choose 2
        if n >= 6 :
            b = 1 * leftPlace  +  1
            for i in range(1,n//2) :
                for j in range(i+1,n//2) :
                    b2 = b + 10**i + 10**j + 10**(n-i-1) + 10**(n-j-1) ; ans.append(b2*b2)
                    if n >= 7 and n & 1:
                        b3 = b2 + middlePlace; ans.append(b3*b3)
                            
        ## Eight and 9 nonzero-digits -- choose 3
        if n >= 8 :
            b = 1 * leftPlace  +  1
            for i in range(1,n//2) :
                for j in range(i+1,n//2) :
                    for k in range(j+1,n//2) :
                        b2 = b + 10**i + 10**j + 10**k + 10**(n-i-1) + 10**(n-j-1) + 10**(n-k-1) ; ans.append(b2*b2)
                        if n >= 9 and n & 1:
                            b3 = b2 + middlePlace; ans.append(b3*b3)
    ans.sort()
    glist = ans

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def getInputs(IN) :
    a,b = IN.ints()
    return (a,b)

def solve(inp) :
    (a,b) = inp
    n1 = bisect.bisect(glist,a-1)
    n2 = bisect.bisect(glist,b)
    return str(n2-n1)    

#####################################################################################################
if __name__ == "__main__" :
    presolve()
    #for x in glist : print(x)
    doit()

