import fileinput
import sys
import functools
from statistics import median

class MyInput(object) :
    def __init__(self,default_file="A.in") :
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input(default_file)]
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

@functools.lru_cache(maxsize=8388608)
def solve(origpos,a,b,k,aMatchSoFar,bMatchSoFar,kMatchSoFar) :
    #print("DEBUG: Entering solve(%d,%d,%d,%d)" % (origpos,a,b,k))
    pos = origpos
    while pos > a and pos > b and pos > k and pos > 0 : pos = pos >> 1
    ans = 0
    if pos == 0: 
        ans =  1
    else :
        newpos = pos >> 1
        aone = True if a & pos != 0 else False
        bone = True if b & pos != 0 else False
        kone = True if k & pos != 0 else False

        canAUseOne = (pos <= a) and (not aMatchSoFar or aone)
        canBUseOne = (pos <= b) and (not bMatchSoFar or bone)
        canKUseOne = canAUseOne and canBUseOne and (pos <= k) and (not kMatchSoFar or kone)

        ans =      solve(newpos,a,b,k, aMatchSoFar and not aone, bMatchSoFar and not bone, kMatchSoFar and not kone)
        if canAUseOne : ## (1,0) case
            ans += solve(newpos,a,b,k, aMatchSoFar and     aone, bMatchSoFar and not bone, kMatchSoFar and not kone)
        if canBUseOne : ## (0,1) case
            ans += solve(newpos,a,b,k, aMatchSoFar and not aone, bMatchSoFar and     bone, kMatchSoFar and not kone)
        if canKUseOne : ## (1,1) case
            ans += solve(newpos,a,b,k, aMatchSoFar and     aone, bMatchSoFar and     bone, kMatchSoFar and     kone)

    #print("DEBUG: Leaving solve(%d,%d,%d,%d). Returning value %d" % (origpos,a,b,k,ans))
    return ans

if __name__ == "__main__" :
    myin = MyInput("B.debugin")
    (t,) = myin.getintline()
    for tt in range(t) :
        (a,b,k) = myin.getintline(3)
        ways = solve(1<<30,a-1,b-1,k-1,True,True,True)
        print("Case #%d: %d" % (tt+1,ways))