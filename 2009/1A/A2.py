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

def reorderBases(bases) :
    rbases = []
    for b in (7,8,6,9,10,5,3) :
        if b in bases : rbases.append(b)
    return rbases

def findFirst(bases) :
    x = 2
    rbases = reorderBases(bases)
    while True :
        #if (x % 1000000 == 0) : print("DEBUG: Trying %d" % x)
        flag = True
        for b in rbases :
            if not check(x,b) : 
                flag=False; break
        if flag : return x
        x += 1
    
if __name__ == "__main__" :

    ## First run for finding the max value
    #print(findFirst((10,9,8,7,6,5,4,3,2)))
    ## Max value is 11814485
    
    ## Second, Get a feel for how dense these things are
    #ss = [0] * 11
    #for x in range(2,100000) :
    #    b = ['.'] * 11
    #    for i in range(2,11) :
    #        if check(x,i) :
    #            ss[i] += 1
    #            b[i] = 'Y'
    #    print("%3d %s" % (x, " ".join(b[2:])))
    #values = " ".join(str(x) for x in ss[2:])
    ## print(values)
    ## 99998 23578 99998 23241 6015 1165 5523 7352 14375
    ## Conclusions
    ## Base 2 and 4 always converge to 1
    ## Base 7 is the most restrictive
    ## Appropriate order is : 7 --> 8 --> 6 --> 9 --> 10 --> 5 --> 3

    ## Refined Answer
    anscache = {}
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        b = tuple(IN.ints())
        rb = tuple(reorderBases(b))
        if rb not in anscache :
            anscache[rb] = findFirst(rb)
        print("Case #%d: %d" % (tt,anscache[rb]))
