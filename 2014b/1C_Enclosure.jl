
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

function solve(N::I,M::I,K::I)::I
    if M<N; (N,M) = (M,N); end
    ## If the smallest dimension is <= 2, we can only enclose stones 
    if N <= 2 || K <= 4; return K; end
    best = K
    for base1 in 1:N  ## Assume base1 is the bigger base
        for base2 in 1:base1
            for ht in 3:M
                if base1-base2 > 2*(ht-1); continue; end
                s = base1+base2+(ht-2)*2
                if s >= best; continue; end
                k,w = base1+base2,base1
                for i in 2:ht-1
                    w = min(base2+2*(ht-i),w+2,N)
                    k += w
                end
                if k >= K;
                    best = s;
                end
            end
        end
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,M,K = gis()
        ans = solve(N,M,K)
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

