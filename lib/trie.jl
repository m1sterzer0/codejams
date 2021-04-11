
const I = Int64; const VI = Vector{I}; const SI = Set{I}; const PI = NTuple{2,I};
const TI = NTuple{3,I}; const QI = NTuple{4,I}; const VPI = Vector{PI}; const SPI = Set{PI}
const F = Float64; const VF = Vector{F}; const PF = NTuple{2,F}

######################################################################################################
### BEGIN Trie (modified from DataStructures.jl)
######################################################################################################

mutable struct myTrie
    occurances::Int64
    ways::Int64
    children::Dict{Char,myTrie}
    is_key::Bool

    function myTrie()
        self = new()
        self.occurances = 0
        self.ways = 0
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
getNode(t::myTrie, key::AbstractString)::myTrie = return _mygenode(t,key,length(key))

######################################################################################################
### END Trie (from DataStructures.jl)
######################################################################################################
