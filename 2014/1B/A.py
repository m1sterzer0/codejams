import fileinput
import sys
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
        
def rleEncode(s) :
    keyarr,arr,lastc = [],[],'-'
    for c in s :
        if c == lastc :
            arr[-1] += 1
        else :
            arr.append(1)
            keyarr.append(c)
            lastc = c
    keystr = "".join(keyarr)
    return (keystr,arr)

def incompatible(rle) :
    key = rle[0][0]
    for t in rle :
        if t[0] != key : return True
    return False

def getNumMoves(rle) :
    moves = 0
    for i in range(len(rle[0][1])) :
        counts = [ t[1][i] for t in rle ]
        m = round(median(counts))
        locmoves = [abs(x-m) for x in counts]
        moves += sum(locmoves)
    #for i in range(len(rle[0][1])) :
    #    moves += abs(rle[0][1][i]-rle[1][1][i])
    return moves

if __name__ == "__main__" :
    myin = MyInput("A.short")
    (t,) = myin.getintline()
    for tt in range(t) :
        (n,) = myin.getintline(1)
        inputs = [ myin.getstringline(1)[0] for i in range(n)]
        rle    = [ rleEncode(x) for x in inputs ]
        if incompatible(rle) :
            print("Case #%d: Fegla Won" % (tt+1,))
        else :
            m = getNumMoves(rle)
            print("Case #%d: %d" % (tt+1,m))
