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
    l,d,n = IN.ints()
    words =    [ IN.strs()[0] for x in range(d) ]
    patterns = [ IN.strs()[0] for x in range(n) ]

    import re
    for tt,p in enumerate(patterns,1) :
        p2 = p.translate(str.maketrans("()","[]"))
        matches = sum(1 for x in words if re.match(p2,x))
        print("Case #%d: %d" % (tt,matches))

