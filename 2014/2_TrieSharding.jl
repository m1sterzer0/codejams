
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
getNode(t::myTrie, key::AbstractString)::myTrie = return _mygetnode(t,key,length(key))

mm(a::Int64,b::Int64)::Int64 = (a*b) % 1000000007
ma(a::Int64,b::Int64)::Int64 = (a+b) % 1000000007

function solveSmall(M::I,N::I,S::VS)::PI
    ## Brute force with N^M possible assingments
    cases::Array{I,2} = fill(0,N^M,M)
    for j::I in 1:M
        i::I = 1
        for r::I in 1:(N^(M-j))
            for s::I in 1:N
                for p::I in 1:N^(j-1)
                    cases[i,j] = s; i += 1
                end
            end
        end
    end

    prefixset::Vector{Set{String}} = [Set{String}() for i in 1:M]
    for i in 1:M
        push!(prefixset[i],"")
        for j in 1:length(S[i])
            push!(prefixset[i],S[i][1:j])
        end
    end
    mysets::Vector{Set{String}} = [Set{String}() for i in 1:N]

    best,bestcnt = 0,0
    for i in 1:N^M
        assignments = cases[i,:]
        valid = true
        for j in 1:N
            if j ∉ assignments; valid = false; break; end
        end
        if !valid; continue; end
        for j in 1:N; empty!(mysets[j]); end
        for j in 1:M
            si = assignments[j]
            union!(mysets[si],prefixset[j])
        end
        trial = sum([length(x) for x in mysets])
        if trial > best; best = trial; bestcnt = 1
        elseif trial == best; bestcnt += 1
        end
    end
    return (best,bestcnt)
end

function solvecomb(aa::VI,slots::I,comb::Array{I,2})::I
    ans::Int64 = 1
    for a in aa; ans = mm(ans,comb[slots+1,a+1]); end
    return ans 
end


function traverse(N::I,comb::Array{I,2},t::myTrie)
    aa::Vector{Int64} = []
    if t.is_key; push!(aa,1); end
    w::Int64 = 1
    for (k::Char,v::myTrie) in t.children
        traverse(N,comb,v)
        push!(aa,v.occurances)
        t.occurances += v.occurances
        w = mm(w,v.ways)
    end
    t.occurances = min(N,sum(aa))
    maxaa,sign,alloc = maximum(aa),1,0
    ## Use principle of inclusion-exclusion
    for i in t.occurances:-1:maxaa
        temp = solvecomb(aa,i,comb)
        if sign == -1 && temp > 0; temp = 1000000007 - temp; end
        alloc = ma(alloc,mm(comb[t.occurances+1,i+1],temp))
        sign = -1*sign
    end
    t.ways = mm(w,alloc)
end

function traverse2(t::myTrie)::I
    ans = t.occurances
    for (k,v) in t.children; ans+=traverse2(v); end
    return ans
end

function solveLarge(M::I,N::I,S::VS,working)::PI
    (comb::Array{I,2},) = working
    t = myTrie()
    for s in S; addNode(t,s); end
    traverse(N,comb,t)
    ans1 = traverse2(t)
    ans2 = t.ways
    return (ans1,ans2)
end

function preworkLarge()
    comb::Array{Int64,2} = fill(0,1001,1001)
    comb[1,1] = 1
    for i in 1:1000
        for j in 0:i
            comb[i+1,j+1] = j ==0 || j == i ? 1 : (comb[i,j] + comb[i,j+1]) % 1000000007
        end
    end
    return (comb,)
end

function main(infn="")
    working = preworkLarge()
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        M,N = gis()
        S::VS = []
        for i in 1:M; push!(S,gs()); end
        #ans = solveSmall(M,N,S)
        ans = solveLarge(M,N,S,working)
        print("$(ans[1]) $(ans[2])\n")
    end
end

function gencase(Mmin::I,Mmax::I,Nmax::I)
    M = rand(Mmin:Mmax)
    N = rand(1:min(Nmax,M))
    letters::String = rand(["A","AB","ABC","ABCD"])
    letarr::VC = [x for x in letters]
    S::VS = []
    for j in 1:M
        word = ""
        while word == "" || word in S
            wlen = rand(1:10)
            word = join(rand(letarr,wlen))
        end
        push!(S,word)
    end
    return (M,N,S)
end

function test(ntc::I,Mmin::I,Mmax::I,Nmax::I,check::Bool=true)
    working = preworkLarge()
    pass = 0
    for ttt in 1:ntc
        (M,N,S) = gencase(Mmin,Mmax,Nmax)
        ans2 = solveLarge(M,N,S,working)
        if check
            ans1 = solveSmall(M,N,S)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(M,N,S)
                ans2 = solveLarge(M,N,S,working)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

Random.seed!(8675309)
main()
#test(1,1,8,4)
#test(10,1,8,4)
#test(100,1,8,4)
#test(1000,1,8,4)
