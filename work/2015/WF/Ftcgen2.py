import random
random.seed(8675309)

with open("Ftc4.in","wt") as fp :
    print(100,file=fp)
    tc = 0
    for sl in (1996,) :
        for pdist in ([0.25,0.25,0.25,0.25],) : 
            for i in range(100) :
                tc += 1
                s = "".join(random.choices(population=['b','f','u','d'],weights=pdist,k=sl))
                if tc in [32,44,58,71,85,90] : s = "".join(random.choices(population=['b','f','u','d'],weights=pdist,k=sl))
                x = random.random()
                n1 = random.randrange(sl-1)
                n2 = random.randrange(sl-1)
                n3 = random.randrange(sl-1)
                n4 = random.randrange(sl-1)
                n1,n2,n3,n4 = sorted([n1,n2,n3,n4])
                if n1==n2 or n2==n3 or n3==n4 :
                    print(f"{s}",file=fp)
                else : 
                    s1 = s[:n1+1]
                    s2 = s[n1+1:n2+1]
                    s3 = s[n2+1:n3+1]
                    s4 = s[n3+1:n4+1]
                    s5 = s[n4+1:]
                    print(f"{s1}({s2}){s3}({s4}){s5}",file=fp)
