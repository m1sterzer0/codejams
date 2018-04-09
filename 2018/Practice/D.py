import fileinput
import sys
import string
from operator import itemgetter

class MyInput(object) :
    def __init__(self,default_file=None) :
        self.fh = sys.stdin
        if (len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
    def getintline(self,n=-1) : 
        ans = tuple(int(x) for x in self.fh.readline().rstrip().split())
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getintline'%(n,len(ans)))
        return ans
    def getfloatline(self,n=-1) :
        ans = tuple(float(x) for x in self.fh.readline().rstrip().split())
        if n > 0 and len(ans) != n : raise Exception('Expected %d floats but got %d in MyInput.getfloatline'%(n,len(ans)))
        return ans
    def getstringline(self,n=-1) :
        ans = tuple(self.fh.readline().rstrip().split())
        if n > 0 and len(ans) != n : raise Exception('Expected %d strings but got %d in MyInput.getstringline'%(n,len(ans)))
        return ans
    def getbinline(self,n=-1) :
        ans = tuple(int(x,2) for x in self.fh.readline().rstrip().split())
        if n > 0 and len(ans) != n : raise Exception('Expected %d bins but got %d in MyInput.getbinline'%(n,len(ans)))
        return ans

if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline(1)
    for tt in range(t) :
        (n,k) = myin.getintline(2)

        ## Do full tiers
        amts = [n,n+1]
        cnts = [1,0]
        tiercnt = 1
        while k > tiercnt :
            ## two cases, amt[0] is even, and amt[0] is odd
            if amts[0] % 2 == 0 :
                newamt1 = amts[0]//2 - 1
                newamt2 = newamt1 + 1
                newcnt1 = cnts[0]
                newcnt2 = cnts[0] + 2 * cnts[1]
                amts = [newamt1,newamt2]; cnts = [newcnt1,newcnt2]
            else :
                newamt1 = amts[0]//2
                newamt2 = newamt1 + 1
                newcnt1 = 2 * cnts[0] + cnts[1]
                newcnt2 = cnts[1]
                amts = [newamt1,newamt2]; cnts = [newcnt1,newcnt2]
            k -= tiercnt
            tiercnt *= 2

        mymin,mymax = 0,0        
        if k <= cnts[1] :
            mymin = (amts[1]-1)//2; mymax = amts[1] - 1 - mymin
        else :
            mymin = (amts[0]-1)//2; mymax = amts[0] - 1 - mymin

        print("Case #%d: %d %d" % (tt+1,mymax, mymin))
