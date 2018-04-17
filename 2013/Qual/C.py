import fileinput
import sys
import bisect

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

## We realize that the square of a palindrome is a palindrome iff there are no carries when doing the addition after the long multiplication
## Thus, a necessary condition is that the we don't carry when calculating the "middle" digit
## This gives us the sum of the squares of the digits in the generating palindrome.  Thus, we have the following cases/observations for possibilities
## * All of the digits of the generating palindrome must be 0, 1, 2, or 3.  Cases
## * A single 3
## * Two 2's, and the rest zeros
## * One two (must be the middle number), up to 4 ones (two of which must be on the outside), and the rest zeros
## * Up to 9 ones, the reset zeros
##

## * A single 3
## * Two 2's and the reset zeros
## * One two in the middle, and two ones on the outside
## * One two in the middle, two ones on the outside, and two other symmetric ones
## * Two ones on the outside
## * Two ones on the outside + one one in the middle
## * Two ones on the outside + two ones in the middle
def generateFairAndSquare() :
    ## n is the number of digits in the square root of the square and fair number
    ans = []

    for n in range(1,51) :

        leftPlace = 10**(n-1)
        middlePlace = 10**(n//2)  ## Only for odd N
    
        ## One nonzero-digit
        if n == 1 : ans.append(1); ans.append(4); ans.append(9)
    
        ## Two nonzero-digits
        if n >= 2 :
            b = 1 * leftPlace + 1; ans.append(b*b)
            b = 2 * leftPlace + 2; ans.append(b*b)
    
        ## Three nonzero-digits
        if n >= 3 and n & 1 :
            b = 1 * leftPlace + 1 * middlePlace + 1; ans.append(b*b)
            b = 1 * leftPlace + 2 * middlePlace + 1; ans.append(b*b)
            b = 2 * leftPlace + 1 * middlePlace + 2; ans.append(b*b)
    
        ## Four and five nonzero-digits -- choose 1
        if n >= 4 :
            b = 1 * leftPlace  +  1
            for i in range(1,n//2) :
                b2 = b + 1 * 10**i + 1 * 10**(n-i-1); ans.append(b2*b2)
                if n >= 5:
                    b3 = b2 + 1 * middlePlace
                    b4 = b2 + 2 * middlePlace
                    ans.append(b3*b3)
                    ans.append(b4*b4)
    
        ## Six and seven nonzero-digits -- choose 2
        if n >= 6 :
            b = 1 * leftPlace  +  1
            for i in range(1,n//2) :
                for j in range(i+1,n//2) :
                    b2 = b + 10**i + 10**j + 10**(n-i-1) + 10**(n-j-1) ; ans.append(b2*b2)
                    if n >= 7 :
                        b3 = b2 + middlePlace; ans.append(b3*b3)
                            
        ## Eight and 9 nonzero-digits -- choose 3
        if n >= 8 :
            b = 1 * leftPlace  +  1
            for i in range(1,n//2) :
                for j in range(i+1,n//2) :
                    for k in range(j+1,n//2) :
                        b2 = b + 10**i + 10**j + 10**k + 10**(n-i-1) + 10**(n-j-1) + 10**(n-k-1) ; ans.append(b2*b2)
                        if n >= 9 :
                            b3 = b2 + middlePlace; ans.append(b3*b3)
    ans.sort()
    return ans


if __name__ == "__main__" :
    ans = generateFairAndSquare()
    #print(ans)
    myin = MyInput("C.short")
    (t,) = myin.getintline()
    for tt in range(t) :
        (a,b) = myin.getintline(2)
        n1 = bisect.bisect(ans,a-1)
        n2 = bisect.bisect(ans,b)
        print("Case #%d: %d" % (tt+1,n2-n1))

