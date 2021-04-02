tests = []
for N in range(1,3+1) :
    for P in range(1,2**N+1) : 
        tests.append((N,P))
with open ("Btc1.in","wt") as fp:
    ntc = len(tests)
    print(f"{ntc}",file=fp)
    for (n,p) in tests :
        print(f"{n} {p}",file=fp)


