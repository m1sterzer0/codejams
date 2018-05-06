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
import copy

def getInputs(IN) :
    n = int(IN.input())
    cars = []
    for x in range(n) :
        a,b,c = IN.input().rstrip().split()
        cars.append( (x,a,int(b),int(c)) )
    return (n,cars)

def solve(inp) :
    (n,cars) = inp
    events,dependencies,assignment = parseEvents(n,cars)
    cursor = 1
    for e in events :
        (t,typ,c1,c2) = e
        if typ == "overlap" :
            dependencies[c1].add(c2)
            dependencies[c2].add(c1)
            if assignment[c1] == 0 and assignment[c2] == 0 :
                assignment[c1] = cursor
                assignment[c2] = -cursor
                cursor += 1
            elif assignment[c1] == 0 :
                assignment[c1] = -assignment[c2]
            elif assignment[c2] == 0 :
                assignment[c2] = -assignment[c1]
            elif assignment[c1] == assignment[c2] :
                return "%.8f" % float(t)
            elif assignment[c1] == -assignment[c2] :
                continue
            else :
                if abs(assignment[c1]) > abs(assignment[c2]): merge(n,assignment,assignment[c1],-assignment[c2])
                else                                        : merge(n,assignment,assignment[c2],-assignment[c1])
        else :
            dependencies[c1].remove(c2)
            dependencies[c2].remove(c1)
            if not dependencies[c1] : assignment[c1] = 0
            if not dependencies[c2] : assignment[c2] = 0
    return "Possible"

def printOutput(tt,ans) :
    print("Case #%d: %s" % (tt,ans))

def parseEvents(n,cars) :
    mycars = copy.deepcopy(cars)
    mycars.sort(key=itemgetter(3,0,2,1))
    events = []
    dependencies = collections.defaultdict(set)
    assignment = [0] * n
    for i in range(n) :
        (c2,lr2,s2,p2) = mycars[i]
        for j in range(i) :
            (c1,lr1,s1,p1) = mycars[j]
            if p2 >= p1 + 5 and s2 >= s1 :
                continue
            elif p2 >= p1 + 5 :
                t1 = Fraction(p2-p1-5,s1-s2)
                t2 = Fraction(p2-p1+5,s1-s2)
                events.append( (t1,"overlap",c1,c2) )
                events.append( (t2,"clear",c1,c2) )
            else : ## p2 < p1 + 5 
                dependencies[c1].add(c2)
                dependencies[c2].add(c1)
                assignment[c1] = 1e9 if lr1 == 'R' else -1e9
                assignment[c2] = 1e9 if lr2 == 'R' else -1e9
                if s1 > s2 :
                    t2 = Fraction(p2-p1+5,s1-s2)
                    events.append( (t2,"clear",c1,c2) )
                elif s2 > s1 :
                    t2 = Fraction(p1-p2+5,s2-s1)
                    events.append( (t2,"clear",c1,c2) )
    events.sort()
    #for e in events : print(e)
    return events,dependencies,assignment    

def merge(n,assignment,bigger,smaller) :
    for i in range(n) :
        if assignment[i] == smaller : assignment[i] = bigger
        if assignment[i] == -smaller : assignment[i] = -bigger

#####################################################################################################
if __name__ == "__main__" :
    doit()
