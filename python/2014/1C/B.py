import fileinput
import sys
import functools
from string import ascii_lowercase

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

## Corner cases
## Cars that have one letter 

## Corner cases
## 

def genFactArr(n) :
    factArr = [1] * (n+1)
    m = 1000000007
    for i in range(1,n+1) : factArr[i] = (i * factArr[i-1]) % m
    return factArr

def calcAns(singles, clusters, factArr) :
    ans,m = 1,1000000007
    for s in singles : ans = (ans * factArr[s]) % m
    ans = (ans * factArr[clusters]) % m
    return ans

def makeScoreboard(n,trains) :
    sb = initScoreboard()
    endLookup = [ ['-'] * 2 for x in range(n+1) ]
    stillPossible = True
    for c,t in enumerate(trains) :
        r = myreduce(t)
        if len(r) == 1 : 
            stillPossible = stillPossible & updateFull(sb, r[0], c)
        else :
            n = len(r)
            stillPossible = stillPossible & updateLeft(sb, r[0], c)
            stillPossible = stillPossible & updateRight(sb, r[n-1], c)
            for i in range(1,n-1) :
                stillPossible = stillPossible & updateInterior(sb, r[i], c)
            endLookup[c] = [r[0],r[n-1]]
    return sb, endLookup, stillPossible

def processTrain(startidx, d, sb, endLookup) :
    trainIdx = startidx
    leftLetter = endLookup[trainIdx][0]
    if d[leftLetter] : return False
    d[leftLetter] = True
    rightLetter = endLookup[trainIdx][1]
    if d[rightLetter] : return False
    d[rightLetter] = True
    while (True) :
        ## Get the next train
        if not sb[rightLetter]['left'] : 
            return True
        trainIdx = sb[rightLetter]['leftidx']
        rightLetter = endLookup[trainIdx][1]
        if d[rightLetter] : return False
        d[rightLetter] = True
    return True  ## Shouldn't get here

def processScoreboard(endLookup, sb, fact) :
    d = {}
    for c in ascii_lowercase : 
        if not sb[c]['interior'] and not sb[c]['left'] and not sb[c]['right'] and sb[c]['fullcnt'] == 0 : d[c] = True
        else : d[c] = False
    
    ## Look for any letters that immediately loop back on themselves
    for c in ascii_lowercase :
        if sb[c]['left'] and sb[c]['right'] and sb[c]['leftidx'] == sb[c]['rightidx'] :
            return 0

    ## Chasing Trains -- our failure mechanism is that a train loops back on itself
    numTrains = 0
    ansarr = []
    for c in ascii_lowercase :
        if sb[c]['fullcnt'] > 1 : ansarr.append(sb[c]['fullcnt'])

    for c in ascii_lowercase :
        if not d[c] and sb[c]['left'] and not sb[c]['right'] :
            stillPossible = processTrain(sb[c]['leftidx'], d, sb, endLookup)
            if not stillPossible:  return 0
            numTrains += 1

    for c in ascii_lowercase :
        if sb[c]['fullcnt'] > 0 and not sb[c]['left'] and not sb[c]['right'] : numTrains += 1
        if sb[c]['left'] and sb[c]['right'] and not d[c]: return 0 ## Cornercase to seal with a circle

    ansarr.append(numTrains)
    ans = 1
    for a in ansarr : ans = (ans * fact[a]) % 1000000007
    return ans 

def myreduce(t) :
    ans = []; last = '-'
    for c in t :
        if c != last : ans.append(c)
        last = c
    return ans

def initScoreboard() :
    d = {}
    for c in ascii_lowercase :
        d[c] = {'interior' : False, 'fullcnt' : 0, 'left' : False, 'right' : False, 'leftidx' : -1, 'rightidx' : -1 }
    return d

def updateFull(sb, c, idx) :
    if sb[c]['interior'] : return False
    sb[c]['fullcnt'] += 1; return True

def updateLeft(sb, c, idx) :
    if sb[c]['interior'] : return False
    if sb[c]['left']     : return False
    sb[c]['left'], sb[c]['leftidx'] = True, idx; return True

def updateRight(sb, c, idx) :
    if sb[c]['interior'] : return False
    if sb[c]['right']     : return False
    sb[c]['right'], sb[c]['rightidx'] = True, idx; return True

def updateInterior(sb, c, idx) :
    if sb[c]['interior'] : return False
    if sb[c]['right']    : return False
    if sb[c]['left']     : return False
    if sb[c]['fullcnt'] > 0 : return False
    sb[c]['interior'] = True; return True

if __name__ == "__main__" :
    myin = MyInput("Bdebug.in")
    (t,) = myin.getintline(1)
    factArr = genFactArr(100)
    for tt in range(t) :
        (n,) = myin.getintline()
        trains = myin.getstringline(n)
        #trains = [ myin.getstringline(1)[0] for i in range(n) ]
        sb, endLookup, possible = makeScoreboard(n,trains)
        ans = 0
        if possible: ans = processScoreboard(endLookup, sb, factArr)
        print("Case #%d: %d" % (tt+1,ans))
