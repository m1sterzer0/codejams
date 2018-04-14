import sys
import math
class myin(object) :
    def __init__(self,default_file=None,buffered=False) :
        self.fh = sys.stdin
        self.buffered = buffered
        if(len(sys.argv) >= 2) : self.fh = open(sys.argv[1])
        elif default_file is not None : self.fh = open(default_file)
        if (buffered) : self.lines = self.fh.readlines()
        self.lineno = 0
    def input(self) : 
        if (self.buffered) : ans = self.lines[self.lineno]; self.lineno += 1; return ans
        return self.fh.readline()
    def strs(self) :   return self.input().rstrip().split()
    def ints(self) :   return (int(x) for x in self.input().rstrip().split())
    def bins(self) :   return (int(x,2) for x in self.input().rstrip().split())
    def floats(self) : return (float(x) for x in self.input().rstrip().split())

def checkCookies(board,left,right,top,bot,chipsPerCookie) :
    numchips = 0
    for i in range(top,bot+1) :
        for j in range(left,right+1) :
            numchips += board[i][j]
    return chipsPerCookie == numchips

if __name__ == "__main__" :
    IN = myin()
    t, = IN.ints()
    for tt in range(1,t+1) :
        r,c,h,v = IN.ints()
        board = [ ['.'] * c for x in range(r) ]
        for i in range(r) :
            s, = IN.strs()
            for j in range(c) :
                board[i][j] = 1 if s[j] == '@' else 0

        numCookies = (h+1) * (v+1)
        rowSums =  [ sum(board[i]) for i in range(r)]
        colSums =  [ sum([board[x][j] for x in range(r)]) for j in range(c)]
        totalChips = sum(rowSums)
        totalCookies = (h+1) * (v+1)
        chipsPerCookie = totalChips // totalCookies
        if totalChips != chipsPerCookie * totalCookies :
            print("Case #%d: IMPOSSIBLE" % (tt,))
            continue
        if totalChips == 0 :
            print("Case #%d: POSSIBLE" % (tt,))
            continue
            
        chipsPerCookieRow = (v+1) * chipsPerCookie
        chipsPerCookieCol = (h+1) * chipsPerCookie

        hcuts = []; target = chipsPerCookieRow; cumRows = 0
        for i in range(r) :
            cumRows += rowSums[i]
            if cumRows == target :
                hcuts.append(i)
                target += chipsPerCookieRow

        vcuts = []; target = chipsPerCookieCol; cumCols = 0
        for j in range(c) :
            cumCols += colSums[j]
            if cumCols == target :
                vcuts.append(j)
                target += chipsPerCookieCol

        if len(hcuts) != h+1 or len(vcuts) != v+1 :
            print("Case #%d: IMPOSSIBLE" % (tt,))
            continue

        ## Now we have our cuts -- now to check if we have the right cookies
        cookieCheck = True
        for i in range(h+1) :
            top = 0 if i == 0 else hcuts[i-1]+1
            bot = hcuts[i]
            for j in range(v+1) :
                left = 0 if j == 0 else vcuts[j-1]+1
                right = vcuts[j]
                if not checkCookies(board,left,right,top,bot,chipsPerCookie) :
                    cookieCheck = False

        if not cookieCheck : 
            print("Case #%d: IMPOSSIBLE" % (tt,))
        else :
            print("Case #%d: POSSIBLE" % (tt,))
        

