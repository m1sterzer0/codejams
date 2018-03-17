import fileinput
import sys

class MyInput(object) :
    def __init__(self) :
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("A.in")]
        #if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("A.short")]
        else                   : self.lines = [x for x in fileinput.input()]
        self.lineno = 0
    def getintline(self,n=-1) : 
        ans = tuple(int(x) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getintline'%(n,len(ans)))
        return ans
    def getfloatline(self,n=-1) :
        ans = tuple(float(x) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getfloatline'%(n,len(ans)))
        return ans
    def getstringline(self,n=-1) :
        ans = tuple(self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getstringline'%(n,len(ans)))
        return ans
    def getbinline(self,n=-1) :
        ans = tuple(int(x,2) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getbinline'%(n,len(ans)))
        return ans
        
## KEY INSIGHT:
## The first device must plug into some socket, so there are only N possible keys to try

def doesKeyWork(key,devices,dsocket) :
    for d in devices :
        if d ^ key not in dsocket :
            return False
    return True

def scoreKey(key) :
    score = 0
    while key > 0 :
        if key & 1 != 0 : score += 1
        key = key >> 1
    return score

if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline()
    for tt in range(t) :
        (n,l) = myin.getintline(2)
        devices = myin.getbinline(n)
        sockets = myin.getbinline(n)

        ## Make a dictionary to check sockets
        dsocket = {}
        for s in sockets : dsocket[s] = 1

        minFlips = l+1
        for s0 in sockets : ## s0 is the socket paired with device zero 
            key = s0 ^ devices[0]
            if (doesKeyWork(key,devices,dsocket)) :
                s = scoreKey(key)
                if s < minFlips : minFlips = s

        if minFlips == l+1 :
            print("Case #%d: NOT POSSIBLE" % (tt+1,))
        else :
            print("Case #%d: %d" % (tt+1,minFlips))
