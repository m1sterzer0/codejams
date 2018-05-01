import sys
import math
import collections

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
    (combine,opposed,s) = inp
    q = []
    for c in s :
        q.append(c)
        if len(q) >= 2 and q[-2] + q[-1] in combine :
            r = combine[q[-2] + q[-1]]
            q.pop(); q.pop(); q.append(r)
        else :
            for k in opposed[c] :
                if k in q : q = []; break
    return '[' + ", ".join(q) + ']'

def getInputs(IN) :
    tokens = list(IN.input().rstrip().split()); xx = iter(tokens)
    c = int(next(xx))
    combine = {}
    for x in range(c) :
        t = next(xx)
        combine[t[0]+t[1]] = t[2]
        combine[t[1]+t[0]] = t[2]
    d = int(next(xx))
    opposed = collections.defaultdict(list)
    for x in range(d) :
        t = next(xx)
        opposed[t[0]].append(t[1])
        opposed[t[1]].append(t[0])
    n = int(next(xx))
    s = next(xx)
    return (combine,opposed,s)
    
if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t) ]
    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %s" % (tt,ans))
