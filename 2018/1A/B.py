import sys
import math
import itertools
import heapq

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

def coins(c,t) :
    maxt = c[2] + c[1] * c[0]
    if t >= maxt : return c[0]
    return (t - c[2]) // c[1]

def evalCashiers(cashiers,t,r,b) :
    coinsPerCashier = [coins(cashiers[i],t) for i in range(len(cashiers))]
    coinsPerCashier.sort(reverse=True)
    return True if sum(coinsPerCashier[:r]) >= b else False

if __name__ == "__main__" :
    IN = myin("B.in")
    t, = IN.ints()
    for tt in range(1,t+1) :
        r,b,c = IN.ints()
        cashiers = [0] * c
        for i in range(c) :
            mi,si,pi = IN.ints()
            cashiers[i] = (mi,si,pi)

        left,right = 0,2000000000000000000
        #left,right = 0,1000
        while (right-left) > 1 :
            m = (right+left) // 2
            if evalCashiers(cashiers,m,r,b) :
                right = m
            else :
                left = m
        print("Case #%d: %d" % (tt, right))

