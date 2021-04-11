
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

function prework()
    s1a = "ejp mysljylc kd kxveddknmc re jsicpdrysi"
    s2a = "rbcpc ypc rtcsra dkh wyfrepkym veddknkmkrkcd"
    s3a = "de kr kd eoya kw aej tysr re ujdr lkgc jv"
    s4a = "yeq"
    s5a = "z"
    
    s1b = "our language is impossible to understand"
    s2b = "there are twenty six factorial possibilities"
    s3b = "so it is okay if you want to just give up"
    s4b = "aoz"
    s5b = "q"

    d::Dict{Char,Char} = Dict{Char,Char}()
    for (sa,sb) in [(s1a,s1b),(s2a,s2b),(s3a,s3b),(s4a,s4b),(s5a,s5b)]
        for (x,y) in zip(sa,sb)
            d[x] = y
        end
    end
    return d
end   

function solveSmall(d::Dict{Char,Char},s::AbstractString)::String
    a::Vector{Char} = [d[x] for x in s]
    ans::String = join(a,"")
    return ans
end

function main(infn="")
    d::Dict{Char,Char} = prework()
    ## Just to check that we got all of the letters
    solveSmall(d,"abcdefghijklmnopqrstuvwxyz ")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        s = gs()
        ans = solveSmall(d,s)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

