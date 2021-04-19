
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
### Greedy plan should work.
### 1) Take each ingredient and calculate a range of the number of packets it can make.  Put this range
###    in a vector for that ingredient and then sort.
### 2) Then we loop over the following procedure:
###    -- Check the bottom of the queues and see if those ingredient packets make a kit
###    -- If so remove them all and increment the kit counter
###    -- If not, there are one or more ingredinets whose maximum number of kits is less than the
###       minimum of some other ingredient.  Ditch those ingredients.
######################################################################################################

## min packages = floor( Qij / (1.1*Ri))

function solve(N::I,P::I,R::VI,Q::Array{I,2})
    ## Step 1
    QQ::Vector{VPI} = [VPI() for i in 1:N]
    for i::I in 1:N
        for j::I in 1:P
            minElem::I = (10 * Q[i,j] + 11 * R[i] - 1) ÷ (11 * R[i])  ### All integer ceiling function
            maxElem::I = (10 * Q[i,j]) ÷ (9 * R[i])
            if minElem > maxElem; continue; end
            push!(QQ[i],(minElem,maxElem))
        end
        sort!(QQ[i])
    end
        
    ## Step 2
    ans::I = 0
    while(true)
        if any(isempty,QQ); break; end
        mymin::I = maximum(QQ[i][1][1] for i in 1:N)
        mymax::I = minimum(QQ[i][1][2] for i in 1:N)
        if mymin <= mymax
            ans += 1
            foreach(popfirst!,QQ)
        else
            for i in 1:N
                if QQ[i][1][2] < mymin; popfirst!(QQ[i]); end
            end
        end
    end
    return ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,P = gis()
        R = gis()
        Q::Array{I,2} = fill(0,N,P)
        for i in 1:N; Q[i,:] = gis(); end
        ans = solve(N,P,R,Q)
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

