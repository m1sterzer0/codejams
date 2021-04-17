import random
random.seed(2345)

if __name__ == "__main__" :
    with open("E.in2","wt") as fp :
        t = 50
        print(t,file=fp)
        for tt in range(t) :
            A = random.uniform(-10.0,10.0)
            B = random.uniform(-10.0,10.0)
            C1 = random.uniform(-10.0,10.0)
            print("%d %.2f %.2f" % (1,A,B),file=fp)
            print("%.2f" % C1,file=fp)
        
    with open("E.in3","wt") as fp :
        t = 50
        print(t,file=fp)
        for tt in range(t) :
            A = random.uniform(-10.0,10.0)
            B = random.uniform(-10.0,10.0)
            C1 = random.uniform(-10.0,10.0)
            C2 = random.uniform(-10.0,10.0)

            print("%d %.2f %.2f" % (2,A,B),file=fp)
            print("%.2f %.2f" % (C1,C2), file=fp)
