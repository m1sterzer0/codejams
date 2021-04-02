######################################################################################################
### a) The problem seems much more tractible if we do it in reverse (i.e. we start with a possible
###    end state and work backwards).
### b) The key of the problem is "given a plane that forms a 'roof' and 2 points int that plane that
###    will remain, find a third point such that the resultant plane will retain the 'roof' property
###    (i.e. remaining over all of the other columns).  The key is to minimize the angle between the
###    old and new planes, and this can be done with a linear search.
### c) Finally, finding 3 points to start can be a bit of a challenge, but we can make it easy by
###    adding additional pillars at the same height as our tallest pillar such that the plane starts
###    as a flat roof.  We just need to rememebr to discount these artificial planes in our answer.
######################################################################################################
mutable struct Pt3; x::Int128; y::Int128; z::Int128; end
Pt3() = Pt3(Int128(0),Int128(0),Int128(0))
Base.:+(a::Pt3,b::Pt3)::Pt3 =   Pt3(a.x+b.x,a.y+b.y,a.z+b.z)
Base.:-(a::Pt3,b::Pt3)::Pt3 =   Pt3(a.x-b.x,a.y-b.y,a.z-b.z)
Base.:*(a::Int64,b::Pt3)::Pt3 = Pt3(a*b.x,a*b.y,a*b.z)
Base.:*(b::Pt3,a::Int64)::Pt3 = Pt3(a*b.x,a*b.y,a*b.z) 
cross(a::Pt3,b::Pt3)::Pt3  = Pt3(a.y*b.z-b.y*a.z,a.z*b.x-b.z*a.x,a.x*b.y-b.x*a.y)
dot(a::Pt3,b::Pt3)::Int128 = a.x*b.x + a.y*b.y + a.z*b.z

mutable struct Pt2; x::Int128; y::Int128; end
Pt2() = Pt2(Int128(0),Int128(0))
Base.:+(a::Pt2,b::Pt2)::Pt2 =   Pt2(a.x+b.x,a.y+b.y)
Base.:-(a::Pt2,b::Pt2)::Pt2 =   Pt2(a.x-b.x,a.y-b.y)
Base.:*(a::Int64,b::Pt2)::Pt2 = Pt2(a*b.x,a*b.y)
Base.:*(b::Pt2,a::Int64)::Pt2 = Pt2(a*b.x,a*b.y) 
dot(a::Pt2,b::Pt2)::Int128 = a.x*b.x + a.y*b.y

function findNext(ptarr::Vector{Pt3},used::Vector{Bool},a::Pt3,b::Pt3)
    best = -1
    nvec = Pt3()
    for i in 1:length(ptarr)
        pt = ptarr[i]
        if !used[i] && (best == -1 || dot(nvec,pt-a) > 0) ## This means our roof crosses this pillar, so try a different point
            best = i
            nvec = cross(b-a,pt-a)
            if nvec.z < 0; nvec = -1 * nvec; end  ## Orient the normal to point to the sky
        end
    end
    return best
end

function prework(ptarr::Vector{Pt3},ansstack::Vector{Int64},used::Vector{Bool})
    maxh = maximum([x.z for x in ptarr])
    maxhIndices = [i for i in 1:length(ptarr) if ptarr[i].z == maxh]
    for i in maxhIndices; used[i] = true; push!(ansstack,i); end
    
    a = Pt3()
    b = Pt3()

    if length(maxhIndices) == 1
        b = ptarr[maxhIndices[1]]
        a = Pt3(b.x+1,b.y,b.z)
    elseif length(maxhIndices) == 2
        b = ptarr[maxhIndices[2]]
        a = ptarr[maxhIndices[1]]
    else
        b = ptarr[maxhIndices[3]]
        a = ptarr[maxhIndices[2]]
    end

    return a,b
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        X = fill(zero(Int128),N)
        Y = fill(zero(Int128),N)
        H = fill(zero(Int128),N)
        for i in 1:N
            X[i],Y[i],H[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end

        ptarr::Vector{Pt3} = [Pt3(X[i],Y[i],H[i]) for i in 1:N]
        ansstack::Vector{Int64} = Vector{Int64}()
        used::Vector{Bool} = fill(false,N)
        a::Pt3,b::Pt3 = prework(ptarr,ansstack,used)
        ### Do more here
        while length(ansstack) < N
            idx = findNext(ptarr,used,a,b)
            (a,b) = (b,ptarr[idx])
            push!(ansstack,idx)
            used[idx] = true
        end
        ans = join(reverse(ansstack)," ")
        print("$ans\n")
    end
end

main()
