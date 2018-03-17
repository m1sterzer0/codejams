import fileinput
import sys

class MyInput(object) :
    def __init__(self) :
        if (len(sys.argv) < 2) : self.lines = [x for x in fileinput.input("C.in")]
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

## ans[0][0] is the click

def initSol(r,c) :
    ans = [0] * r
    for i in range(r) : ans[i] = ['*'] * c
    return ans

def solve(r,c,m) :
    n = r*c
    ans = initSol(r,c)
    holesLeft = n-m

    ## Deal with the fail cases first
    if r == 2 and holesLeft > 1 and holesLeft % 2 == 1 : return True, None
    if r >= 2  and holesLeft in (2,3,5,7) : return True, None

    if m == 0 :
        for i in range(r) :
            for j in range(c) :
                ans[i][j] = '.'

    elif holesLeft == 1 :
        pass

    elif r == 1 :
        for i in range(holesLeft) :
            ans[0][i] = '.'

    elif r == 2 :
        for i  in range(holesLeft//2) :
            ans[0][i] = ans[1][i] = '.'

    elif holesLeft <= 3*c :
        i = 0
        while holesLeft > 4 :
            ans[0][i] = ans[1][i] = ans[2][i] = '.'
            holesLeft -= 3
            i += 1
        if holesLeft == 4 :
            ans[0][i] = ans[1][i] = ans[0][i+1] = ans[1][i+1] = '.'
        elif holesLeft == 3:
            ans[0][i] = ans[1][i] = ans[2][i] = '.'
        else :
            ans[0][i] = ans[1][i] = '.'

    else :
        ridx = 0
        while holesLeft >= c :
            for j in range(c) : ans[ridx][j] = '.'
            holesLeft -= c
            ridx += 1
        if holesLeft == 1 :
            ans[ridx][0] = ans[ridx][1] = '.'
            ans[ridx-1][c-1] = '*'
        else :
            for j in range(holesLeft) :
                ans[ridx][j] = '.' 

    ans[0][0] = 'c'
    return False,ans

def flipans(r,c,ans) :
    ans2 = initSol(c,r)
    for i in range(r) :
        for j in range(c) :
            ans2[j][i] = ans[i][j]
    return ans2

def doPrintBoard(r,c,ans) :
    for i in range(r) :
        print("".join(ans[i]))
      
if __name__ == "__main__" :
    myin = MyInput()
    (t,) = myin.getintline()
    for tt in range(t) :
        (r,c,m) = myin.getintline(3)
        transposed = False
        if (r>c) : transposed = True; (r,c) = (c,r)
        impossible,ans = solve(r,c,m)
        if (not impossible and transposed) : ans = flipans(r,c,ans); (r,c) = (c,r)
        print("Case #%d:" % (tt+1,))
        #print("DEBUG: (r,c,m) = (%d,%d,%d)"%(r,c,m))
        if impossible : print("Impossible")
        else :          doPrintBoard(r,c,ans)