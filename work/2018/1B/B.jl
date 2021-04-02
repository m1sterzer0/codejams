######################################################################################################
### For the large, we're looking for either a O(S) or O(S*logS) solution.  Here we have a master
### theorem divide and conquer.  Note for NlogN, we can do linear work in the parent.  Note that
### one of our previous searches in the small was linear, so this what we do.
###
### -- We break the array into a left,center,right, where center == 1 element
### -- We recurse on the left and right side as per a typical divide and conquer solution
### -- In the parent, we calculate the largest set using the center element.  We do this
###    with 4 linear searches
###    --  (st1,en1) assming middle sets eastbound and westbound is forced by left path
###    --  (st2,en2) assming middle sets eastbound and westbound is forced by right path
###    --  (st3,en3) assming middle sets westbound and eastbound is forced by left path
###    --  (st4,en4) assming middle sets westbound and eastbound is forced by right path
######################################################################################################

function cSearch(st::Int64,cen::Int64,en::Int64,M::Vector{Int64},N::Vector{Int64},leftFirst=true)::Tuple{Int64,Int64}
    m::Int64,n::Int64 = M[cen],typemax(Int64)
    l::Int64,r::Int64 = cen,cen
    if leftFirst
        while l > st && M[l-1] == m; l -= 1; end
        if l > st
            l -= 1
            n = N[l]
            while l > st && (M[l-1] == m || N[l-1] == n); l -= 1; end
        end
        while r < en && (M[r+1] == m || N[r+1] == n); r += 1; end
    else
        while r < en && M[r+1] == m; r += 1; end
        if r < en
            r += 1
            n = N[r]
            while r < en && (M[r+1] == m || N[r+1] == n); r += 1; end
        end
        while l > st && (M[l-1] == m || N[l-1] == n); l -= 1; end
    end
    return (l,r)
end

function dnc(st::Int64,en::Int64,M::Vector{Int64},N::Vector{Int64})
    if en-st <= 1; return (en-st+1,1); end  ## Cover the case of a length 1 or length 2 segment
    center = (st+en) ÷ 2
    (bestl,numBestl) = dnc(st,center-1,M,N)
    (bestr,numBestr) = dnc(center+1,en,M,N)
    (best,numbest) = (bestl > bestr) ? (bestl,numBestl) : (bestr > bestl) ? (bestr,numBestr) : (bestl,numBestl+numBestr)
    (l1,r1) = cSearch(st,center,en,M,N,true)
    (l2,r2) = cSearch(st,center,en,M,N,false)
    (l3,r3) = cSearch(st,center,en,N,M,true)
    (l4,r4) = cSearch(st,center,en,N,M,false)
    for (l,r) in Set{Tuple{Int64,Int64}}([(l1,r1),(l2,r2),(l3,r3),(l4,r4)])
        lbest = r-l+1
        if lbest > best; (best,numbest) = (lbest,1)
        elseif lbest == best; numbest += 1
        end
    end
    return (best,numbest)
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
        (best,numbest) = dnc(1,S,M,N)
        print("$best $numbest\n")
    end
end

main()
