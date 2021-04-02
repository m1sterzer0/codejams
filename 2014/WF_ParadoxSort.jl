######################################################################################################
### Observations required.
### Assume we have a directional graph where we have a --> b if, when presented with candies a & b, 
###    we prefer a.
### 1) (EASY) A candy can only precede T in a valid permutation if it can be reached in a DFS from T 
### 2) (HARDER) A post-order traversal of a DFS from T that hits every node is a valid permutation.
### 3) (HARDEST) Lets say we want to test if we have a valid prefix.  Then we remove all nodes in the
###              prefix, simulate the prefix to find the candy we are holding, and then do a DFS
###              search.  If the union of the nodes hit in the DFS + the remianing children of the
###              candy we are holding covers all remaining nodes, then we have a valid prefix. 
### Observation 3 sets forward the algorithm
###
### Algorithm is O^4, which will work with N == 100
###        
######################################################################################################

function dodfs(n::Int64,t::Int64,N::Int64,adjm::Array{Bool,2},sb::Vector{Int64})
    sb[n] = 1
    if n != t  ## Don't trace through t
        for i in 1:N
            if sb[i] == 0 && adjm[n,i]
                dodfs(i,t,N,adjm,sb)
            end
        end
    end
end

function tryit(perm::Vector{Int64},A::Int64,N::Int64,adjm::Array{Bool,2},sb::Vector{Int64})::Bool
    fill!(sb,0)
    cur = perm[1]; sb[cur] = 2
    for v in perm[2:end]
        if adjm[v,cur]; cur = v; end
        sb[v] = 2
    end
    if cur == A;
        for i in 1:N
            if sb[i] == 0 && adjm[i,A]; return false; end
        end
        return true
    end
    if sb[A] == 2; return false; end
    dodfs(A,cur,N,adjm,sb)
    if 0 ∉ sb; return true; end
    for i in 1:N
        if sb[i] == 0 && adjm[i,cur]; return false; end
    end
    return true
end


function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ans = 0
        N,A = [parse(Int64,x) for x in split(readline(infile))]
        A += 1
        adjm::Array{Bool,2} = fill(false,N,N)
        sb::Vector{Int64} = fill(0,N)
        for i in 1:N
            s = readline(infile)
            for (j,c) in enumerate(s)
                if c == 'Y'; adjm[i,j] = true; end
            end
        end
        dodfs(A,-1,N,adjm,sb)
        if 0 in sb; print("IMPOSSIBLE\n"); continue; end
        perm::Vector{Int64} = []
        for i in 1:N
            for j in 1:N
                if j in perm; continue; end
                push!(perm,j)
                if tryit(perm,A,N,adjm,sb); break; end
                pop!(perm)
            end
        end
        ans = join([x-1 for x in perm]," ")
        print("$ans\n")
    end
end

main()
