
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

function solve(N::I,M::I,B::Array{Int64,2})::String
    ## Key observation is that we can't mow any row/col shorter than the tallest entry contained
    ## therein, and there is no incentive to mow the row/col taller than that.  Thus, we just
    ## set the mow height of each row/col above and then check to see that each square's final
    ## height is the minimum of the row mow height and the col mow height
    colheight = [maximum(B[:,j]) for j in 1:M]
    rowheight = [maximum(B[i,:]) for i in 1:N]
    good = true
    for i in 1:N
        for j in 1:M
            if B[i,j] != min(rowheight[i],colheight[j]); good = false; end
        end
    end
    return good ? "YES" : "NO"
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,M = gis()
        B::Array{Int64,2} = fill(0,N,M)
        for i in 1:N
            B[i,:] = gis()
        end
        ans = solve(N,M,B)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
