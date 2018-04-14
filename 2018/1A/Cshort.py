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

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        n,p = IN.ints()
        widths = [0] * n
        heights = [0] * n
        for i in range(n) :
            widths[i],heights[i] = IN.ints()

        ## For the short problem, each cookie can be 2*h+2*w+delta where delta can be zero or can range from 2 * short side to 2 * sqrt(short^2 + long^2)
        ldelta = 2 * min(widths[0],heights[0])
        rdelta = 2 * math.sqrt(widths[0] * widths[0] + heights[0] * heights[0])
        minperim = 2 * n * (widths[0] + heights[0])
        pdelta = p - minperim

        ## How many ldeltas can I fit in
        nn1 = int(1.0 * pdelta / ldelta)
        nn2 = int(1.0 * pdelta / rdelta)

        if nn1 == 0 :
            print("Case #%d: %.8f" % (tt,minperim)) ## Min perim case
        elif nn1 == nn2 and nn2 <= n :
            print("Case #%d: %.8f" % (tt,minperim + nn2 * rdelta)) ## Max perim case
        elif n * rdelta < pdelta :
            print("Case #%d: %.8f" % (tt,minperim + n * rdelta)) ## Intervals don't overlap
        else :
            print("Case #%d: %.8f" % (tt,p)) ## Perfect
            

