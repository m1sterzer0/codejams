
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
### We can't just simulate the process linearly for the large dataset, but we can still simulate
### things in batches.  Observations:
###  -- Note that "choosing a stall" is just the process of "bisecting" the remaining largest "stall gap"
###  -- We can gain efficiency by treating all available "stall distances" in a batch.
###  -- As we bisect the stall distances, one might worry that the pool of available stall distances
###     will grow.  However, we note this isn't the case.
###     -- After the first biesction we will end up with 1-2 stall distances.  If we have 2, they
###        only have a gap of 1.
###     -- After bisecting BOTH of those, we will also have just 1-2 remaining stall distances
###        (with possible more then one instance of each distance).  If we have 2, the gap will be one
###        between them.
###     -- After bisecting ALL of those, we will also just have 1-2 remaining stall distances (with all
###        gap of at-most 1)
### This suggest that can very quickly do the calculations for a factor of 2, so we can process
### the stall lengths in log time.
######################################################################################################

function solve(N::I,K::I)::PI
    sbig::I,cbig::I,ssmall::I,csmall::I = N+1,1,N,0
    K::I -= 1 ## We want the end state of this algorithm for sbig to contain the gap which the last entrant faced
    for i::I in 1:64  ## Range is just big enough to loop over a 64 bit uint -- we will break early
        if K >= (cbig + csmall)
            K -= (cbig+csmall)
            if sbig & 1 > 0
                (cbig,csmall) = (cbig,cbig+2*csmall)
                (sbig,ssmall) = (ssmall ÷ 2 + 1, ssmall ÷ 2)
            else 
                (cbig,csmall) = (2*cbig+csmall,csmall)
                (sbig,ssmall) = (sbig ÷ 2, sbig ÷ 2 - 1)
            end
        elseif K >= cbig; sbig = ssmall; break
        else; break
        end
    end
    ### Note we need to subtract one since they want # empty stalls instead of the size of the stall gap.
    (gbig,gsmall) = sbig & 1 > 0 ? (sbig ÷ 2 + 1 - 1, sbig ÷ 2 - 1) : (sbig ÷ 2 - 1, sbig ÷ 2 - 1) 
    return (gbig,gsmall)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,K = gis()
        ans = solve(N,K)
        print("$(ans[1]) $(ans[2])\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

