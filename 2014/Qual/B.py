import fileinput
import sys

class MyInput(object) :
    def __init__(self) :
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("B.in")]
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
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getintline'%(n,len(ans)))
        return ans

## Assume we have n farms
## We should buy the (n+1)th farm if
##     C / (2 + F*n) < X / (2 + F*n) - X / (2 + F*n + F)
## which simplifies to
#      n > X/C - 2/F -1
# or
#      n+1 > X/C - 2/F        
    
if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline()
    for tt in range(t) :
        (c,f,x) = myin.getfloatline(3)
        n = max(0,int(x/c-2.0/f))
        farmBuildingTime = 0.00
        for i in range(1,n+1) :
            farmBuildingTime += c / (2.0 + f * (i-1))
        cookieTime = x / (2.0 + f * n)
        print("Case #%d: %.7f" % (tt+1,farmBuildingTime+cookieTime))





    