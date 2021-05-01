
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
### BEGIN Trie (modified from DataStructures.jl)
######################################################################################################

mutable struct myTrie
    children::Dict{Char,myTrie}
    is_key::Bool

    function myTrie()
        self = new()
        self.children = Dict{Char,myTrie}()
        self.is_key = false
        return self
    end
end

function _myaddnode(t::myTrie, key::AbstractString, l::Int64)::myTrie
    if l == 0; t.is_key = true; return t; end
    c::Char = key[1]
    if !haskey(t.children,c); t.children[c] = myTrie(); end
    return _myaddnode(t.children[c],key[2:end],l-1)
end

function _mygetnode(t::myTrie, key::AbstractString, l::Int64)::myTrie
    if l == 0; return t; end
    c::Char = key[1]
    if !haskey(t.children,c); throw(KeyError("key not found: $key")); end
    return _myaddnode(t.children[c],key[2:end],l-1)
end

addNode(t::myTrie, key::AbstractString)::myTrie = _myaddnode(t,key,length(key))
getNode(t::myTrie, key::AbstractString)::myTrie = return _mygetnode(t,key,length(key))

######################################################################################################
### END Trie (from DataStructures.jl)
######################################################################################################

function traverse(tt::myTrie,first=false)::PI
    matches::I = 0; extra::I = 0
    for (c,v) in tt.children
        (m,e) = traverse(v)
        matches += m; extra += e
    end
    if tt.is_key; extra += 1; end
    if !first && extra >= 2; matches += 1; extra -= 2; end
    return (matches,extra) 
end

function solve(N::I,W::VS)::I
    tt = myTrie()
    for w in W; addNode(tt,reverse(w)); end
    (matches::I,residual::I) = traverse(tt,true)
    return 2*matches
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        W::VS = [gs() for i in 1:N]
        ans = solve(N,W)
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

