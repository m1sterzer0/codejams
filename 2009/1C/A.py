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

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    digits = [1,0] + list(range(2,100))
    for tt in range(1,t+1) :
        s, = IN.strs()
        d = {}; i = 0; nn = []
        for c in s :
            if c not in d : d[c] = digits[i]; i += 1
            nn.append(d[c])
        mybase = 2 if i <= 2 else i
        ans = 0; place = 1
        for d in nn[::-1] :
            ans += place * d; place *= mybase
        print("Case #%d: %d" % (tt,ans))
