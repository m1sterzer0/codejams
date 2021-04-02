import argparse
import os.path
from pathlib import Path

def mkStarterFile(fn) :
    ttt = '''
function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        ##N = parse(Int64,rstrip(readline(infile)))
        ans = 0
        print("$ans\\n")
    end
end

main()
'''
    with open(fn,'wt') as fp :
        print(ttt,file=fp)


def mkTcgenTemplate(fn) :
    ttt = '''
import random
random.seed(8675309)
(fn,ntc) = ("Atc1.in",1000)
with open(fn,'wt') as fp :
    print(ntc, file=fp)
    for i in range(ntc) :
        pass
'''
    with open(fn,'wt') as fp :
        print(ttt,file=fp)

def parseCLArgs() :
    clargparse = argparse.ArgumentParser()
    clargparse.add_argument( '--dir', action='store', default='', help='Parent Directory for the preparations')
    clargs = clargparse.parse_args()
    if not clargs.dir  : raise Exception("Need to provide a --dir option.  Exiting...")
    if not os.path.exists(clargs.dir) : raise Exception(f"Directory '{clargs.dir}' does not exist.  Exiting...")
    return clargs


if __name__ == "__main__" :
    clargs = parseCLArgs()
    for (d,plist) in [ ('Qual',['A','B','C','D']),
                        ('1A',['A','B','C']),
                        ('1B',['A','B','C']),
                        ('1C',['A','B','C']),
                        ('2',['A','B','C','D']),
                        ('3',['A','B','C','D']),
                        ('WF',['A','B','C','D','E','F']) ]:
        if not os.path.exists(f"{clargs.dir}/{d}") :
            os.mkdir(f"{clargs.dir}/{d}")
        for problem in plist :
            Path(f"{clargs.dir}/{d}/{problem}.in").touch()
            mkStarterFile(f"{clargs.dir}/{d}/{problem}.jl")
            mkTcgenTemplate(f"{clargs.dir}/{d}/tcgen.py")

