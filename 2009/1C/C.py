import sys
import math
import functools
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

p = 10000
qarr = []
cache = {}

def solve(a,b) :
    if a >= b : return 0
    if (a,b) not in cache :
        best = 1e99
        found = False    
        for c in qarr :
            if c >= a and c <= b :
                found = True
                tmp = (b-a) + solve(a,c-1) + solve(c+1,b)
                best = min(tmp,best)
        cache[(a,b)] = best if found else 0
    return cache[(a,b)]

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        p,_ = IN.ints()
        qarr = tuple(IN.ints())
        cache = {}
        ans = solve(1,p)
        print("Case #%d: %d" % (tt,ans))
            
