import argparse
import os



def parseCLArgs() :
    clargparse = argparse.ArgumentParser()
    clargparse.add_argument( '--refout', action='store', default='', help='Reference Output')
    clargparse.add_argument( '--expout', action='store', default='', help='Experimental Output')
    clargs = clargparse.parse_args()
    return clargs

if __name__ == "__main__" :
    clargs = parseCLArgs()
    if not os.path.exists(clargs.refout) or not os.path.exists(clargs.expout) : raise Exception("Something bad happened")
    with open(clargs.refout,"rt") as fp1 :
        with open(clargs.expout,"rt") as fp2:
            f1lines = [l.rstrip() for l in fp1]
            f2lines = [l.rstrip() for l in fp2]
            if len(f1lines) != len(f2lines) : raise Exception("Mismatched lengths")
            tot = len(f1lines)-1
            match = 0
            for (l1,l2) in zip(f1lines[1:],f2lines[1:]) :
                if l1==l2 : match += 1
            print(f"tot:{tot} match:{match} percent:{1.0*match/tot}")