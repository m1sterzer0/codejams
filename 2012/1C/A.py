import sys
import math
import collections
import heapq
from operator import itemgetter

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

def solve(inp) :
    (n,m) = inp
    ## Find the leaf classes (classes that no-one inherits from)
    s = set(range(1,n+1))
    for parr in m[1:] :
        for p in parr :
            if p in s : s.remove(p)

    for l in s :
        ps = set(); ps.add(l); q = [l]
        while(q) :
            x = q.pop()
            for p in m[x] :
                if p in ps : return "Yes"
                else       : ps.add(p); q.append(p)

    return "No"

def getInputs(IN) :
    n = int(IN.input())
    m = [0] * (n+1)
    for i in range(1,n+1) :
        m[i] = list(IN.ints())
        m[i].pop(0)
    return (n,m)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]

    ## Non-multithreaded case
    if (True) : 
        for tt,i in enumerate(inputs,1) :
            ans = solve(i)
            print("Case #%d: %s" % (tt,ans))

    ## Multithreaded case
    else :
        from multiprocessing import Pool    
        with Pool(processes=32) as pool : outputs = pool.map(solve,inputs)
        for tt,ans in enumerate(outputs,1) :
            print("Case #%d: %s" % (tt,ans))