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


def gopher(myin,x,y) :
    print("%d %d" % (x,y), flush=True)
    (xb,yb) = myin.getintline(2)
    return (xb,yb)

def doit(myin) :
    scoreboard = [[False] * 30 for x in range(30)]
    (xb,yb) = gopher(myin,2,2)
    scoreboard[xb][yb] = True
    minx,miny = xb,yb
    maxx,maxy = xb+9,yb+19
    for x in range(minx,minx+10) :
        xx = x + 1 if x + 1 < maxx else x if x < maxx else x-1
        for y in range(miny,miny+20) :
            while not scoreboard[x][y] :
                yy = y+1 if y+1 < maxy else y if y < maxy else y-1
                (xb,yb) = gopher(myin,xx,yy)
                if (xb,yb) == (0,0) : return True
                if (xb,yb) == (-1,-1) : return False
                scoreboard[xb][yb] = True
    return False

if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline(1)
    for tt in range(t) :
        (a,) = myin.getintline(1)
        if not doit(myin) : break