import sys
import math
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

def next_permutation(a) :
    for i in range(len(a)-2,-1,-1) :
        if a[i] < a[i+1] :
            for j in range(len(a)-1,i,-1) :
                if a[j] > a[i] :
                    a[i],a[j] = a[j],a[i]
                    a[i+1:] = reversed(a[i+1:])
                    return True
    return False

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        s, = IN.strs()
        dlist = [0] + list(int(x) for x in s)
        next_permutation(dlist)
        if dlist[0] == 0 : dlist.pop(0) 
        ans = "".join(str(x) for x in dlist)
        print("Case #%d: %s" % (tt,ans))
