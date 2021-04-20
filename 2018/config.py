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
const VC = Vector{Char}; const VS = Vector{String}; VB = Vector{Bool}; VVI = Vector{Vector{Int64}}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

gs()::String = rstrip(readline(infile))
gi()::Int64 = parse(Int64, gs())
gf()::Float64 = parse(Float64,gs())
gss()::Vector{String} = split(gs())
gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]

function solve()
    return 0
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        ans = solve()
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
        print(ttt, file=fp)

def parseCLArgs() :
    clargparse = argparse.ArgumentParser()
    clargparse.add_argument( '--dir', action='store', default='', help='Parent Directory for the preparations')
    clargs = clargparse.parse_args()
    if not clargs.dir  : raise Exception("Need to provide a --dir option.  Exiting...")
    if not os.path.exists(clargs.dir) : raise Exception(f"Directory '{clargs.dir}' does not exist.  Exiting...")
    return clargs

if __name__ == "__main__" :
    clargs = parseCLArgs()
    probList = [
        "1A_BitParty",
        "1A_EdgyBaking",
        "1A_WaffleChoppers",
        "1B_MysteriousRoadSigns",
        "1B_RoundingError",
        "1B_Transmutation",
        "1C_AntStack",
        "1C_AWholeNewWorld",
        "1C_LollipopShop",
        "2_CostumeChange",
        "2_FallingBalls",
        "2_GracefulChainsawJugglers",
        "2_Gridception",
        "3_FenceConstruction",
        "3_FieldTrip",
        "3_NamePreservingNetwork",
        "3_RaiseTheRoof",
        "Qual_SavingTheUniverseAgain",
        "Qual_TroubleSort",
        "Qual_GoGopher",
        "Qual_CubicUFO",
        "WF_GoGophers",
        "WF_JuristictionRestrictions",
        "WF_Swordmaster",
        "WF_TheCartesianJob",
        "WF_TwoTiling",
    ]

    for prob in probList :
        if not os.path.exists(f"{clargs.dir}/{prob}.jl") :
            Path(f"{clargs.dir}/{prob}.jl").touch()
            mkStarterFile(f"{clargs.dir}/{prob}.jl")


