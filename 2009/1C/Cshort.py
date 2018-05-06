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

class unionFind(object) :
    def __init__(self) :
        self.weight = {}
        self.parent = {}
        self.size   = {}
    def insert(self,x) : self.find(x)
    def insertList(self,l) :
        for x in l : self.find(x)
    def find(self,x) :
        if x not in self.parent :
            self.weight[x] = 1
            self.parent[x] = x
            return x
        stk = [x]; par = self.parent[stk[-1]]
        while par != stk[-1] :
            stk.append(par)
            par = self.parent[stk[-1]]
        for i in stk : self.parent[i] = par
        return par
    def union(self,x,y) :
        px = self.find(x)
        py = self.find(y)
        if px != py :
            wx = self.weight[px]
            wy = self.weight[py]
            if wx >= wy : self.weight[px] = wx + wy; del self.weight[py]; self.parent[py] = px
            else        : self.weight[py] = wx + wy; del self.weight[px]; self.parent[px] = py
    def nodeSize(self,x) :
        px = self.find(x)
        return self.weight[px]

def getInputs(IN) :
    p,_ = IN.ints()
    qarr = tuple(IN.ints())
    return (p,qarr)

def solve(inp) :
    (p,qarr) = (inp)
    sb = [0] + [1] * p
    for q in qarr : sb[q] = 0
    globans = 1e99
    for qa in itertools.permutations(qarr) :
        uf = unionFind()
        for i in range(1,p+1) :
            if sb[i] == 1 :
                if sb[i-1] == 0 : parent = i
                uf.insert(i)
                if i != parent : uf.union(i,parent)
        ans = 0
        for q in qa :
            uf.insert(q)
            if q-1 in uf.parent :
                node = uf.find(q-1)
                ans += uf.nodeSize(q-1)
                uf.union(q,q-1)
            if q+1 in uf.parent :
                node = uf.find(q-1)
                ans += uf.nodeSize(q+1)
                uf.union(q,q+1)
        if (ans < globans) :
            globans = ans
            best = qa
    return "%d" % globans

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

#####################################################################################################
if __name__ == "__main__" :
    doit()
