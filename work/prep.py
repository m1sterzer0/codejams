import argparse
import os.path
from pathlib import Path

def mkStarterFile(fn) :
    ttt = '''
using Random
infile = stdin
## Type Shortcuts (to save my wrists and fingers :))
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function solveSmall()
    return 0
end

#function solveLarge()
#    return 0
#end

#function gencase()
#    return 0
#end

#function test(ntc::I,check::Bool=true)
#    pass = 0
#    for ttt in 1:ntc
#        (A) = gencase()
#        ans2 = solveLarge(A)
#        if check
#            ans1 = solveSmall(A)
#            if ans1 == ans2
#                 pass += 1
#            else
#                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\\n")
#                ans1 = solveSmall()
#                ans2 = solveLarge()
#            end
#       else
#           print("Case $ttt: $ans2\\n")
#       end
#    end
#    if check; print("$pass/$ntc passed\\n"); end
#end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        ans = solveSmall()
        #ans = solveLarge()
        print("$ans\\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")
'''
    with open(fn,'wt') as fp :
        print(ttt,file=fp)


def mkTcgenTemplate(fn) :
    ttt = '''
import random
random.seed(8675309)
ntc = 1000
goodids = []
with open("Atc1.in",'wt') as fp :
    with open("Atc1b.in",'wt') as fp2 :
        print(ntc, file=fp)
        print(len(goodids),file=fp2)
        for ttt in range(ntc) :
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
                        ('3',['A','B','C','D','E']),
                        ('WF',['A','B','C','D','E','F']) ]:
        if not os.path.exists(f"{clargs.dir}/{d}") :
            os.mkdir(f"{clargs.dir}/{d}")
        for problem in plist :
            Path(f"{clargs.dir}/{d}/{problem}.in").touch()
            mkStarterFile(f"{clargs.dir}/{d}/{problem}.jl")
            mkTcgenTemplate(f"{clargs.dir}/{d}/tcgen.py")

