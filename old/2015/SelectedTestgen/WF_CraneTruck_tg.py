import random
random.seed(8675309)

with open("Ftc1.in","wt") as fp :
    print(300,file=fp)
    tc = 0
    for sl in (20,50,100) :
        for pdist in ([0.25,0.25,0.25,0.25],) : 
            for i in range(100) :
                tc += 1
                s = "".join(random.choices(population=['b','f','u','d'],weights=pdist,k=sl))
                if tc in [10,15,21,77,95,96,111,140,145,174,184,187,189,212,215,224,227,234,267,273,287] : s = "".join(random.choices(population=['b','f','u','d'],weights=pdist,k=sl))
                if tc in [140,287] : s = "".join(random.choices(population=['b','f','u','d'],weights=pdist,k=sl))

                x = random.random()
                if x < 0.01  :
                    #print("HERE1") 
                    #print(f"(){s}",file=fp)
                    print(f"{s}",file=fp)
                elif x < 0.02 :
                    #print("HERE2") 
                    ##print(f"{s}()",file=fp)
                    print(f"{s}",file=fp)
                else:
                    n1 = random.randrange(sl-1)
                    n2 = random.randrange(sl-1)
                    if n2 < n1 : (n1,n2) = (n2,n1)
                    if x < 0.10 or n1 == n2 :
                        #print("HERE3") 
                        s1 = s[:n1+1]
                        s2 = s[n1+1:]
                        #print(f"{s1}(){s2}",file=fp)
                        print(f"{s}",file=fp)
                    else:
                        #print("HERE4") 
                        s1 = s[:n1+1]
                        s2 = s[n1+1:n2+1]
                        s3 = s[n2+1:]
                        print(f"{s1}({s2}){s3}",file=fp)
                        
