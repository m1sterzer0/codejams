
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

function solve(N::I,L::I,words::VS)::String
    ## Calc the letters per position
    lettersPerPos::Vector{Set{String}}    = [Set{String}() for i in 1:L]
    substringsPerPos::Vector{Set{String}} = [Set{String}() for i in 1:L]
    for w::String in words
        for i::I in 1:L
            push!(lettersPerPos[i],w[i:i])
            push!(substringsPerPos[i],w[1:i])
        end
    end

    ans::String = ""
    comb::I = 1
    for i::I in 1:L
        comb *= length(lettersPerPos[i])
        if comb <= length(substringsPerPos[i]); continue; end
        prefixSet::Set{String} = i == 1 ? Set{String}([""]) : substringsPerPos[i-1]
        for prefix::String in prefixSet
            for postfix::String in lettersPerPos[i]
                if prefix*postfix ∉ substringsPerPos[i]
                    ans = prefix*postfix*words[1][i+1:L]
                    break
                end
            end
            if length(ans) > 0; break; end
        end
        if length(ans) > 0; break; end
    end
    return length(ans) == 0 ? "-" : ans
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N,L = gis()
        words::VS = [gs() for i in 1:N]
        ans = solve(N,L,words)
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

