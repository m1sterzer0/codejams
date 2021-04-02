######################################################################################################
### S here is small enough to suppport an S^2 approach.
### -- We try starting at each signpost and try it two ways
### -- We keep walking until we find our first incompatible signpost
### -- We then set the other constraint
### -- Then we keep walking as far as we can
### Ironically, in Julia, this S^2 approach passes for both the Small and Large, but we still
### consider this is only a "Small" solution.
######################################################################################################

function mySearch(st::Int64,S::Int64,M::Vector{Int64},N::Vector{Int64})
    m = M[st]
    en = st
    while en < S && M[en+1] == m; en += 1; end
    if en < S
        en += 1
        n = N[en]
        while en < S && (M[en+1] == m || N[en+1] == n); en += 1; end
    end
    mbest = en-st+1
    return mbest
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        S::Int64 = parse(Int64,rstrip(readline(infile)))
        D,A,B = fill(0,S),fill(0,S),fill(0,S)
        for i in 1:S
            D[i],A[i],B[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        M::Vector{Int64} = D .+ A
        N::Vector{Int64} = D .- B
        best::Int64 = 0
        numbest::Int64 = 1
        for st::Int64 in 1:S
            if (S-st+1 < best); break; end
            mbest::Int64 = mySearch(st,S,M,N)
            nbest::Int64 = mySearch(st,S,N,M)
            mnbest::Int64 = max(mbest,nbest)
            if mnbest > best; (best,numbest) = (mnbest,1)
            elseif mnbest == best; numbest += 1
            end
        end
        print("$best $numbest\n")
    end
end

main()
