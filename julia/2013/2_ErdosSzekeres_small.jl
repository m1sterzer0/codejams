
## A sequence
## -------------------------------------------------------------------------------------------------------
## * For all i<j, if A[i] >= A[j], then X[i] > X[j]  (otherwise A[j] would be > A[i])
## * For all i w/ A[i] > 1, we must have a j with j < i, A[j] == A[i]-1, and X[i] > X[j].
##   --  Let ji denote all j s.g. A[j] == A[i]-1 && j < i.  Note that from the first condition
##       above, we have for j1 < j2 < ... < jn < i with A[ji] == A[i]-1, X[j1] > X[j2] > ... > X[jn],
##       so the condition is equivalent to X[i] > X[jn]
##
## B sequence
## -------------------------------------------------------------------------------------------------------
## * For all i<j, if B[i] >= B[j], then X[i] < X[j]  (otherwise B[j] would be > B[i])
## * For all i w/ B[i] > 1, we must have a j with j < i, B[j] == B[i]-1, and X[i] < X[j].
##   -- This is equivalent to X[i] < X[jn]

function solveit(A::Vector{Int64},B::Vector{Int64})

    ## Gen Inequalities
    N = length(A)
    ineq::Set{Tuple{Int64,Int64}} = Set{Tuple{Int64,Int64}}()
    lastnode::Vector{Int64} = fill(-1,N)
    for i in 1:N
        if A[i] > 1; jn = lastnode[A[i]-1]; push!(ineq,(i,jn)); end
        lastnode[A[i]] = i
        for j in i+1:N
            if A[i] >= A[j]; push!(ineq,(i,j)); end
        end
    end
    fill!(lastnode,-1)
    for i in N:-1:1
        if B[i] > 1; jn = lastnode[B[i]-1]; push!(ineq,(i,jn)); end
        lastnode[B[i]] = i
        for j in 1:i-1
            if B[i] >= B[j]; push!(ineq,(i,j)); end
        end
    end

    gtlist::Vector{Vector{Int64}} = [Vector{Int64}() for x in 1:N]
    ltlist::Vector{Vector{Int64}} = [Vector{Int64}() for x in 1:N]
    for (i,j) in ineq; push!(gtlist[i],j); push!(ltlist[j],i); end

    ## Now just implement a backtracking search with the inequality graph and 
    used = fill(false,N)
    ans = fill(-1,N)
    function doit(pos::Int64)::Bool
        minj = 1+length(gtlist[pos])
        maxj = N-length(ltlist[pos])
        for pos2 in gtlist[pos]
            if pos2 < pos; minj = max(minj,ans[pos2]+1); end
        end
        for pos2 in ltlist[pos]
            if pos2 < pos; maxj = min(maxj,ans[pos2]-1); end
        end
        for x in minj:maxj
            if used[x]; continue; end
            used[x] = true
            ans[pos] = x
            if pos == N; return true; end
            aa = doit(pos+1)
            if aa; return true; end
            ans[pos] = -1
            used[x] = false
        end
        return false
    end
    doit(1)
    ansstr = join(ans," ")
    return ansstr
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        ##M,N = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        N = parse(Int64,rstrip(readline(infile)))
        A = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        B = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        ansstr = solveit(A,B)
        print("$ansstr\n")
    end
end

main()




