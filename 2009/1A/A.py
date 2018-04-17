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


cache = {}
for x in range(2,11) : cache[x] = {} 
def check(n,b) :
    s =set()
    while n != 1 and n not in s and n not in cache[b]:
        s.add(n)
        n = iterate(n,b)
    if n == 1 :
        for x in s : cache[b][x] = True
        return True
    elif n in cache[b] :
        for x in s : cache[b][x] = cache[b][n]
        return cache[b][n]
    else :
        for x in s : cache[b][x] = False
        return False       

def iterate(n,b) :
    ans = 0
    while n > 0 :
        x = n % b
        ans += x * x
        n //= b
    return ans

def findFirst(bases) :
    x = 2
    while True :
        flag = True
        for b in bases :
            if not check(x,b) : 
                flag=False; break
        if flag : return x
        x += 1

if __name__ == "__main__" :
    anscache = {}
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        b = tuple(IN.ints())
        if b not in anscache :
            anscache[b] = findFirst(b[::-1])
        print("Case #%d: %d" % (tt,anscache[b]))
