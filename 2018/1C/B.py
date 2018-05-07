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

def doitInteractive() :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) : solveInteractive(IN)

#####################################################################################################
import random
random.seed(1)

def solveInteractive(IN) :
    n = int(IN.input())
    counts = [0] * n
    used   = [False] * n
    for _ in range(n) :
        tt = list(IN.ints())
        d = tt.pop(0)
        idx = findLolipop(counts,used,tt)
        if idx >= 0 : used[idx] = True
        print(idx,flush=True)

## For each lolipop, we choose a random lolipop from the set of lolipops that have are tied for the lowest counts that we have seen
def findLolipop(counts,used,tt) :
    found = False
    mincount = 1e99
    s = set()
    for t in tt :
        if not used[t] :
            found = True
            if counts[t] < mincount :
                mincount = counts[t]
                s = {t}
            elif counts[t] == mincount :
                s.add(t)
        counts[t] += 1
    if not found : return -1
    return random.sample(s,1)[0]

#####################################################################################################
if __name__ == "__main__" :
    doitInteractive()
