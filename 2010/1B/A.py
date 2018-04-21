import sys
import math
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

def splitDirs(s) :
    ans = []
    x = ""
    a = s[1:].split('/')
    for aa in a :
        x = x + '/' + aa
        ans.append(x)
    return ans

def solve(inp) :
    (n,m,existing,newdirs) = inp
    d = set()
    for s in existing :
        a = splitDirs(s)
        for aa in a : d.add(aa)
    ans = 0
    for s in newdirs :
        a = splitDirs(s)
        for aa in a :
            if aa not in d : ans += 1; d.add(aa)
    return ans

def getInputs(IN) :
    n,m = IN.ints()
    existing = list(IN.input().rstrip() for x in range(n))
    newdirs  = list(IN.input().rstrip() for x in range(m))
    return (n,m,existing,newdirs)

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inputs = [ getInputs(IN) for x in range(t)]

    for tt,i in enumerate(inputs,1) :
        ans = solve(i)
        print("Case #%d: %d" % (tt,ans))
