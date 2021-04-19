
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

######################################################################################################
### We think of the following relatively straightforward process that works for long digits
### Step1) Work from left to right until we find two consecutive digits i,j with j>i
### Step2) Change i --> i-1 and all digits >= j to 9
### Step3) Work back from right to left and if we find j,j+1 with c[j] > c[j+1], tranform to (c[j]-1,9)
### Step4) Strip off any leading zero as needed
######################################################################################################

function solve(N::I)::String
    S::String = string(N)
    carr::VC = [x for x in S]
    for i::I in 1:length(carr)-1
        if carr[i] <= carr[i+1]; continue; end
        carr[i] -= 1
        for j in i+1:length(carr); carr[j] = '9'; end
        for j in i-1:-1:1
            if carr[j] > carr[j+1]; carr[j+1] = '9'; carr[j] -= 1; end
        end
        break
    end
    return carr[1] == '0' ? join(carr[2:end],"") : join(carr[1:end],"")
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        ans = solve(N)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

