
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

function solve(R::I,C::I,S::Array{I,2})
    ## Initialize the sum and pointer arrays
    ll::Array{I,2} = fill(0,R,C)
    rr::Array{I,2} = fill(0,R,C)
    uu::Array{I,2} = fill(0,R,C)
    dd::Array{I,2} = fill(0,R,C)
    for i in 1:R
        for j in 1:C
            ll[i,j] = j==1 ? 0 : j-1
            rr[i,j] = j==C ? 0 : j+1
            uu[i,j] = i==1 ? 0 : i-1
            dd[i,j] = i==R ? 0 : i+1
        end
    end
    ans::I = 0
    cursum::I = sum(S)
    evaluate::VPI  = [(i,j) for i::I in 1:R for j::I in 1:C]
    eliminate::VPI = []
    while (true)
        ans += cursum

        ## Evaluate phase
        empty!(eliminate)
        for (i,j) in evaluate
            if S[i,j] == 0; continue; end
            cmpsum,cmpcnt = 0,0
            k = ll[i,j]; if k > 0; cmpcnt += 1; cmpsum += S[i,k]; end
            k = rr[i,j]; if k > 0; cmpcnt += 1; cmpsum += S[i,k]; end
            k = uu[i,j]; if k > 0; cmpcnt += 1; cmpsum += S[k,j]; end
            k = dd[i,j]; if k > 0; cmpcnt += 1; cmpsum += S[k,j]; end
            if cmpcnt > 0 && S[i,j]*cmpcnt < cmpsum; push!(eliminate,(i,j)); end
        end

        if isempty(eliminate); return ans; end

        ## Eliminate phase
        empty!(evaluate)
        for (i,j) in eliminate
            if S[i,j] == 0; continue; end
            cursum -= S[i,j]
            S[i,j] = 0
            ## Stich up the neighbor pointers
            kl,kr = ll[i,j],rr[i,j]
            if kl > 0; rr[i,kl] = kr; push!(evaluate,(i,kl)); end
            if kr > 0; ll[i,kr] = kl; push!(evaluate,(i,kr)); end
            ku,kd = uu[i,j],dd[i,j]
            if ku > 0; dd[ku,j] = kd; push!(evaluate,(ku,j)); end
            if kd > 0; uu[kd,j] = ku; push!(evaluate,(kd,j)); end
        end
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        R,C = gis()
        S::Array{I,2} = fill(0,R,C)
        for i in 1:R; S[i,:] = gis(); end
        ans = solve(R,C,S)
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

