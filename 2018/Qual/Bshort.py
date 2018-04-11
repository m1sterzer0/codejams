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

def runTroubleSort(n,v) :
    done = False
    while not done :
        done = True
        for i in range(0,n-2) :
            if v[i] > v[i+2] :
                done = False; (v[i],v[i+2]) = (v[i+2],v[i])
    ## Check the sort
    for i in range(0,n-1) :
        if v[i] > v[i+1] : return str(i)
    return "OK"

if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline(1)
    for tt in range(t) :
        (n,) = myin.getintline(1)
        v = list(myin.getintline(n))
        ans = runTroubleSort(n,v)
        print("Case #%d: %s" % (tt+1,ans))

