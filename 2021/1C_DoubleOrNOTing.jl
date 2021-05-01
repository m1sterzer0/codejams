
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

## Observations
## NOTIng -- decreases the number of inversions by 1, as it chops off the leading zero
##   zero is a special case
## Doubling -- either retains inversions or adds an inversion if digit is 1
## Annotate consecutive sequences
## e.g. 10001 is [1,3,1].  111 is [3]
## Inverting chops off the the leftmost entry
## Doubling adds a 1 to thr right if the list is odd
## Double increments the last digit if the list is even
## Outside of corner cases, the algorithm is
## -- Get to an even number of digits
## -- Invert to chop off a digit
## -- Build the next term in the sequence with doubles (getting us back to an even number of terms)
## -- Invert
## 

function enc(S::String)::VI
    ans::VI = VI()
    rl = 1
    for i in 2:length(S)
        if S[i] == S[i-1]; rl += 1; else; push!(ans,rl); rl = 1; end
    end
    push!(ans,rl)
    return ans
end

## Assumes we have an even number in se
function findPrefix(se,ee)
    best = 1
    for j in 2:length(ee)
        good = true
        for i in 1:j-1
            if se[end-j+i] != ee[i]; good = false; break; end
        end
        if good && se[end] <= ee[j]; best = j; end
    end
    return best
end

function solve(S::String,E::String)
    ## Base cases
    ## S == 0, E == 0, 
    if S == E; return "0"; end
    if E == "0"; return string(length(enc(S))); end
    if S == "0"
        xx = solve("1",E)
        return xx == "IMPOSSIBLE" ? xx : string(1+parse(Int64,xx))
    end
    se::VI = enc(S); ee::VI = enc(E)

    ans = 0
    while true
        if se == ee; break; end
        if length(se) % 2 == 0
            if length(ee) > length(se); return "IMPOSSIBLE"; end
            if length(ee) % 2 == 0 && length(se) > length(ee)
                ans += 1; popfirst!(se)
            elseif length(ee) % 2 == 1 && length(se) - length(ee) > 1
                ans += 1; popfirst!(se)
            else
                xx = findPrefix(se,ee)
                if se[end] < ee[xx]; ans += ee[xx]-se[end]; se[end] = ee[xx]; end
                if se == ee; break; end
                ans += 1; popfirst!(se)
            end 
        else 
            if length(se)+1 < length(ee); return "IMPOSSIBLE"; end
            if length(se) > length(ee)
                ans += 1; popfirst!(se)
            else
                ans += 1; push!(se,1)
            end
        end
    end
    return string(ans)
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        S::String,E::String = gss()
        ans = solve(S,E)
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

