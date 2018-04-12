import sys

class myin(object) :
    def __init__(self,default_file=None,buffered=False) :
        self.fh = sys.stdin
        self.buffered = buffered
        if(len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
        if (buffered) : self.lines = self.fh.readlines()
        self.lineno = 0
    def input(self) : 
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    inv = { "+" : "-", "-" : "+" }
    for tt in range(1,t+1) :
        p,k = IN.strs(); p = list(p); k = int(k)
        ans = 0
        for i in range(len(p)-k+1) :
            if p[i] == '+' : continue
            ans += 1
            for j in range(k) : p[i+j] = inv[p[i+j]]
        if len(p) != p.count('+') : print("Case #%d: IMPOSSIBLE" % tt)
        else                      : print("Case #%d: %d" % (tt,ans))
