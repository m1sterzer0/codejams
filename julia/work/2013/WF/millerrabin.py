
## returns (x^y) % p
def modpow(x, y, p): 
    res = 1
    x = x % p 
    while (y > 0) :
        if (y & 1) : res = (res * x) % p 
        y = y>>1 
        x = (x * x) % p
    return res
	
def millerTest(n):
    if n <= 3 : return True if n in (2,3) else False
    if n % 2 == 0 : return False
    d = n-1; r = 0
    while d % 2 == 0 : r += 1; d //= 2
    alist = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
    for a in alist :
        x = modpow(a, d, n)
        if x in (1,n-1) : continue
        dd = d; bad = True
        while (dd != n - 1): 
            x = (x * x) % n; dd *= 2; 
            if (x == 1): break 
            if (x == n - 1): bad = False; break
        if bad : return False
    return True
            
if __name__ == "__main__" :
    for ee in range(2,18+1) :
        base1 = 10**ee + 1
        while not millerTest(base1) : base1 += 2
        print("10^%-2d : %d" % (ee,base1))
    print("")

    for ee in range(2,18+1) :
        base1 = 2*10**ee + 1
        while not millerTest(base1) : base1 += 2
        print("2*10^%-2d : %d" % (ee,base1))
    print("")

    for ee in range(2,18+1) :
        base1 = 3*10**ee + 1
        while not millerTest(base1) : base1 += 2
        print("3*10^%-2d : %d" % (ee,base1))
    print("")

    for ee in range(2,18+1) :
        base1 = 5*10**ee + 1
        while not millerTest(base1) : base1 += 2
        print("5*10^%-2d : %d" % (ee,base1))
    print("")

