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
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :

        ## Key idea -- we should always take the K-1 pancakes with greatest 2 * pi * R * H
        ## We then loop through the remaining pancakces and see which makes the largest stack 
        n,k = IN.ints()
        pancakes = []
        for i in range (n) :
            r,h = IN.ints()
            sidearea = 2 * math.pi * r * h
            toparea  = math.pi * r * r
            pancakes.append((sidearea, toparea))
        pancakes.sort(reverse=True)

        largestTopArea = 0.00
        sumSideArea = 0.00
        for i in range(k-1) : sumSideArea += pancakes[i][0]; largestTopArea = max(largestTopArea, pancakes[i][1])
        syrupAreas = map(lambda x : sumSideArea + x[0] + max(largestTopArea,x[1]), pancakes[k-1:])
        best = max(syrupAreas)
        print("Case #%d: %.8f" % (tt,best))

