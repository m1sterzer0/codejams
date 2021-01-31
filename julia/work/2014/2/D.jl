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

######################################################################################################
### BEGIN MAIN PROGRAM
### Key realizations:
### * The theoretical maximum is achievable
### * The way calculation is a bit of an exercise in complex combinatorics that can be rolled up
###   with a tree traversal.
######################################################################################################

mm(a::Int64,b::Int64)::Int64 = (a*b) % 1000000007
ma(a::Int64,b::Int64)::Int64 = (a+b) % 1000000007

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    M::Int64,N::Int64 = 0,0
    comb::Array{Int64,2} = fill(0,1001,1001)
    comb[1,1] = 1
    for i in 1:1000
        for j in 0:i
            comb[i+1,j+1] = j ==0 || j == i ? 1 : (comb[i,j] + comb[i,j+1]) % 1000000007
        end
    end

    function solvecomb(aa::Vector{Int64},slots::Int64)
        ans::Int64 = 1
        for a in aa; ans = mm(ans,comb[slots+1,a+1]); end
        return ans 
    end

    function traverse(t::myTrie)
        aa::Vector{Int64} = []
        if t.is_key; push!(aa,1); end
        w::Int64 = 1
        for (k::Char,v::myTrie) in t.children
            traverse(v)
            push!(aa,v.occurances)
            t.occurances += v.occurances
            w = mm(w,v.ways)
        end
        t.occurances = min(N,sum(aa))
        maxaa,sign,alloc = maximum(aa),1,0
        ## Use principle of inclusion-exclusion
        for i in t.occurances:-1:maxaa
            temp = solvecomb(aa,i)
            if sign == -1 && temp > 0; temp = 1000000007 - temp; end
            alloc = ma(alloc,mm(comb[t.occurances+1,i+1],temp))
            sign = -1*sign
        end
        t.ways = mm(w,alloc)
    end

    function traverse2(t::myTrie)::Int64
        ans = t.occurances
        for (k,v) in t.children; ans+=traverse2(v); end
        return ans
    end

    for qq in 1:tt
        print("Case #$qq: ")
        M,N = [parse(Int64,x) for x in split(readline(infile))]
        S::Vector{AbstractString} = [readline(infile) for i in 1:M]
        t = myTrie()
        for s in S; addNode(t,s); end
        traverse(t)
        ans1 = traverse2(t)
        ans2 = t.ways
        print("$ans1 $ans2\n")
    end
end

main()
