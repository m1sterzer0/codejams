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
    s1,s2 = IN.strs()
    return (s1,s2)

def solve(inp) :
    (s1,s2) = inp
    a1,a2 = [],[]
    a1,a2 = solveme(0,len(s1),s1,s2,a1,a2)
    ans1 = "".join(a1)
    ans2 = "".join(a2)
    return " ".join([ans1,ans2])

def fillmax(idx,n, s,a) :
    for i in range(idx,n) :
        if   s[i] == '?' : a.append('9')
        else             : a.append(s[i])

def fillmin(idx,n,s,a) :
    for i in range(idx,n) :
        if   s[i] == '?' : a.append('0')
        else             : a.append(s[i])
    
def doa1gta2 (i,n,s1,s2,a1,a2) :
    if i == n : return a1,a2
    fillmin(i,n,s1,a1)
    fillmax(i,n,s2,a2)
    return a1,a2

def doa1lta2 (i,n,s1,s2,a1,a2) :
    if i == n : return a1,a2
    fillmax(i,n,s1,a1)
    fillmin(i,n,s2,a2)
    return a1,a2

def solveme(i,n,s1,s2,a1,a2) :
    if i >= n : return a1,a2
    c1,c2 = s1[i],s2[i]
    if c1 != '?' and c2 != '?' :
        a1.append(c1); a2.append(c2)
        if c1 > c2 : return doa1gta2(i+1,n,s1,s2,a1,a2)
        if c2 > c1 : return doa1lta2(i+1,n,s1,s2,a1,a2)
        return solveme(i+1,n,s1,s2,a1,a2)

    if c1 != '?' and c2 == '?' :
        trials = []

        if c1 != '0' :
            t1 = a1[:]; t2 = a2[:]
            t1.append(c1)
            t2.append(str(int(c1)-1))
            t1,t2 = doa1gta2(i+1,n,s1,s2,t1,t2)
            trials.append( (t1,t2) )
        
        t1 = a1[:]; t2 = a2[:]
        t1.append(c1)
        t2.append(c1)
        t1,t2 = solveme(i+1,n,s1,s2,t1,t2)
        trials.append( (t1,t2) )

        if c1 != '9' :
            t1 = a1[:]; t2 = a2[:]
            t1.append(c1)
            t2.append(str(int(c1)+1))
            t1,t2 = doa1lta2(i+1,n,s1,s2,t1,t2)
            trials.append( (t1,t2) )

        return pickBest(trials)

    if c1 == '?' and c2 != '?' :
        trials = []
        if c2 != '0' :
            t1 = a1[:]; t2 = a2[:]
            t1.append(str(int(c2)-1))
            t2.append(c2)
            t1,t2 = doa1lta2(i+1,n,s1,s2,t1,t2)
            trials.append( (t1,t2) )
        
        t1 = a1[:]; t2 = a2[:]
        t1.append(c2)
        t2.append(c2)
        t1,t2 = solveme(i+1,n,s1,s2,t1,t2)
        trials.append( (t1,t2) )

        if c2 != '9' :
            t1 = a1[:]; t2 = a2[:]
            t1.append(str(int(c2)+1))
            t2.append(c2)
            t1,t2 = doa1gta2(i+1,n,s1,s2,t1,t2)
            trials.append( (t1,t2) )

        return pickBest(trials)
        
    if c1 == '?' and c2 == '?' :
        trials = []

        t1 = a1[:]; t2 = a2[:]
        t1.append('0')
        t2.append('0')
        t1,t2 = solveme(i+1,n,s1,s2,t1,t2)
        trials.append( (t1,t2) )

        t1 = a1[:]; t2 = a2[:]
        t1.append('0')
        t2.append('1')
        t1,t2 = doa1lta2(i+1,n,s1,s2,t1,t2)
        trials.append( (t1,t2) )

        t1 = a1[:]; t2 = a2[:]
        t1.append('1')
        t2.append('0')
        t1,t2 = doa1gta2(i+1,n,s1,s2,t1,t2)
        trials.append( (t1,t2) )

        return pickBest(trials)

    return a1,a2

def pickBest(trials) :
    a1,a2 = None,None; diff,v1,v2 = 1e99,1e99,1e99
    for (t1,t2) in trials :
        vv1 = evaluate(t1)
        vv2 = evaluate(t2)
        vdiff = abs(vv1-vv2)
        if vdiff > diff : continue
        if vdiff == diff and vv1 > v1 : continue
        if vdiff == diff and vv1 == v1 and vv2 > v2 : continue
        diff,v1,v2,a1,a2 = vdiff,vv1,vv2,t1,t2
    return a1,a2

def evaluate(t) :
    v = 0
    for c in t : v = 10 * v + int(c)
    return v
              
#####################################################################################################
if __name__ == "__main__" :
    doit()
