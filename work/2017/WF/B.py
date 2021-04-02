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
from operator        import mul
from functools       import reduce

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
    print("Case #%d: %d %d" % (tt,ans[0],ans[1]))

def getInputs(IN) :
    S,C = IN.ints()
    O = [0] * C
    V = [0] * C
    for i in range(C) :
        aa = IN.input().rstrip().split()
        O[i] = aa[0]
        V[i] = int(aa[1])
    return (S,C,O,V)

def tadd(a,b) : return (a[0]+b*a[1],a[1])
def tsub(a,b) : return (a[0]-b*a[1],a[1])
def tmul(a,b) : return (a[0]*b,a[1])
def tdiv(a,b) : return (a[0],a[1]*b) if b > 0 else (-a[0],-a[1]*b)
def tgt(a,b) :  return b[1]*a[0] > a[1]*b[0]
def tlt(a,b) :  return b[1]*a[0] < a[1]*b[0]

def compressCards(O,V) :
    possum = 0
    negsum = 0
    posmul = 1
    posdiv = 1
    negmul = []
    negdiv = []
    zeromul = False
    for (o,v) in zip(O,V) :
        if v == 0 :
            if o == '*' :
                zeromul = True
        elif v < 0 :
            if   o == '+' : negsum += v
            elif o == '-' : possum -= v
            elif o == '*' : negmul.append(v)
            elif o == '/' : negdiv.append(v)
        else :
            if   o == '+' : possum += v
            elif o == '-' : negsum -= v
            elif o == '*' : posmul *= v
            elif o == '/' : posdiv *= v
    O2,V2 = [],[]
    if possum > 0 :
        O2.append("+"); V2.append(possum)
    if negsum < 0 :
        O2.append("+"); V2.append(negsum)
    if posmul > 1 :
        O2.append("*"); V2.append(posmul)
    if posdiv > 1 :
        O2.append("/"); V2.append(posdiv)
    if zeromul :
        O2.append("*"); V2.append(0)
    negmul.sort()
    if negmul : O2.append("*"); V2.append(negmul.pop())
    if negmul : O2.append("*"); V2.append(negmul.pop())
    if negmul : O2.append("*"); V2.append(reduce(mul,negmul,1))
    negdiv.sort()
    if negdiv : O2.append("/"); V2.append(negdiv.pop())
    if negdiv : O2.append("/"); V2.append(negdiv.pop())
    if negdiv : O2.append("/"); V2.append(reduce(mul,negdiv,1))
    return (O2,V2)

def solve(inp) :
    (S,C,O,V) = inp
    (O2,V2) = compressCards(O,V)
    C2 = len(O2)
    maxbm = 1<<C-1
    minvals = [(1,1) for i in range(1<<C2)]
    maxvals = [(1,1) for i in range(1<<C2)]
    minvals[0] = (S,1)
    maxvals[0] = (S,1)
    for i in range(1,1<<C2) :
        first = True
        for j in range(C2) :
            bm = 1 << j
            if i & bm == 0: continue
            residual = i & ~bm
            v1,v2 = (1,1),(1,1)
            if O2[j] == "+" :
                v1 = tadd(maxvals[residual],V2[j])
                v2 = tadd(minvals[residual],V2[j])
            elif O2[j] == "-" :
                v1 = tsub(maxvals[residual],V2[j])
                v2 = tsub(minvals[residual],V2[j])
            elif O2[j] == "*" :
                v1 = tmul(maxvals[residual],V2[j])
                v2 = tmul(minvals[residual],V2[j])
            elif O2[j] == "/" :
                v1 = tdiv(maxvals[residual],V2[j])
                v2 = tdiv(minvals[residual],V2[j])
            (maxv,minv) = (v1,v2) if tgt(v1,v2) else (v2,v1)
            if first :
                maxvals[i] = maxv
                minvals[i] = minv
                first = False
            else :
                maxvals[i] = maxvals[i] if tgt(maxvals[i],maxv) else maxv
                minvals[i] = minvals[i] if tlt(minvals[i],minv) else minv
    f = Fraction(maxvals[(1<<C2)-1][0],maxvals[(1<<C2)-1][1])
    return (f.numerator,f.denominator)     

#####################################################################################################
if __name__ == "__main__" :
    doit()
