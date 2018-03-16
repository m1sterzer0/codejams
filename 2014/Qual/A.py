
import fileinput
import sys

class MyInput(object) :
    def __init__(self) :
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("A.in")]
        else                   : self.lines = [x for x in fileinput.input()]
        self.lineno = 0
    def getintline(self,n=-1) : 
        ans = tuple(int(x) for x in self.lines[self.lineno].rstrip().split())
        self.lineno += 1
        if n > 0 and len(ans) != n : raise Exception('Expected %d ints but got %d in MyInput.getintline'%(n,len(ans)))
        return ans
    
def initData() :
    lookup = [0] * 17
    for i in range(17) : lookup[i] = []
    return lookup

def processGrid(iter,lookup,myin) :
    for i in range(4) :
        (a,b,c,d) = myin.getintline()
        for x in (a,b,c,d) :
            lookup[x].append(i+1)

def processAnswer(lookup,ans1,ans2,case) :
    candidates = []
    for i in range(1,17) :
        if lookup[i][0] == ans1 and lookup[i][1] == ans2 :
            candidates.append(i)
    if len(candidates) == 0 :
        print("Case #%d: Volunteer cheated!" % (case,))
    elif len(candidates) >= 2 :
        print("Case #%d: Bad magician!" % (case,))
    else :
        print("Case #%d: %d" % (case,candidates[0]))

if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline()
    for tt in range(t) :
        lookup = initData()
        (ans1,) = myin.getintline()
        processGrid(1,lookup,myin)
        (ans2,) = myin.getintline()
        processGrid(2,lookup,myin)
        processAnswer(lookup,ans1,ans2,tt+1)
        


    