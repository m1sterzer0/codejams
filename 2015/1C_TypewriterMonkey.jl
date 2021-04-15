
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

function solve(K::I,L::I,S::I,kk::String,ll::String)::F
    ## Step 1: figure out if any prefix of the target lines up with any suffix, so we know where we reset to
    resetPos = 0
    for i in 1:(L-1)
        if ll[1:i] == ll[end-i+1:end]; resetPos = i; end
    end
    
    ## Step 2: calculate max bananas -- first need to see if the keyboard contains all of the necessary keys
    lset = Set(ll)
    kset = Set(kk)
    maxBananas = issubset(lset,kset) ? 1 + (S-L) ÷ (L-resetPos) : 0

    ## Step3 : now we need to create the state transition probability matrix
    ##       : we have L+1 states.  Between each state transition we will move the terms in the "complete" state (L+1) back to the reset position
    A = zeros(Int64,L+1,L+1)
    for i in 1:L
        for k in kk
            vv = (i==1 ? "" : ll[1:i-1]) * "$k"
            best = 0
            for j in 1:length(vv)
                if ll[1:j] == vv[end-j+1:end]; best = j; end
            end
            A[best+1,i] += 1
        end
    end
    Af = float(A) ./ K

    ## Step4 : Run the simulation for K steps and see what we get
    state = zeros(Float64,L+1); state[1] = 1.00
    expectedBananas = 0.00
    for i in 1:S
        state = Af * state
        expectedBananas += state[L+1]
        state[resetPos+1] += state[L+1]
        state[L+1] = 0.00
    end

    return maxBananas - expectedBananas

end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        K,L,S = gis()
        kk::String = gs()
        ll::String = gs()
        ans = solve(K,L,S,kk,ll)
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

