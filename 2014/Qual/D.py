import fileinput
import sys

class MyInput(object) :
    def __init__(self) :
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("D.in")]
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

## For the Deceitful war, you clearly bleed out your opponents top pieces with your bottom pieces
## For the Regular war, playing your boards from bottom to top seems to be the best you can do. 

def doFairWar(n,naomi,ken) :
    score = 0
    idxk = 0
    for i in range(n) :
        while (idxk < n and ken[idxk] < naomi[i]) : idxk += 1
        if idxk >= n : score += 1
        idxk += 1
    return score

def doDeceitfulWar(n,naomi,ken) :
    score = 0
    idxk = 0
    for i in range(n) :
        if naomi[i] > ken[idxk] :
            score += 1
            idxk += 1
    return score
            
if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline()
    for tt in range(t) :
        (n,) = myin.getintline(1)
        naomi = myin.getfloatline(n)
        ken   = myin.getfloatline(n)
        naomi = sorted(naomi)
        ken   = sorted(ken)
        fairWar = doFairWar(n,naomi,ken)
        deceitfulWar = doDeceitfulWar(n,naomi,ken)
        print("Case #%d: %d %d" % (tt+1,deceitfulWar,fairWar))
