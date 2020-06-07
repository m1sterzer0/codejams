using Printf
using LinearAlgebra
######################################################################################################
### We just look at all N^2 planes and make sure that there are points on either side of the plane.
### WC: O(N^3)..  pecial cases:
###     * We need to get rid of duplicates.  Use GCD
###     * If any two points are antipodes, we are done
###     * If we have a set of points that are all coplanar with the origin and all other points are on one side,
###         * we need to check if the points are all within the same semicircle
### Originally, I wrote this to just tackle the small, but it is fast enough to pass the whole thing.
### It is lightning fast once I properly typed this (300s limit -- 7s execution) 
######################################################################################################

const Pt =    Tuple{Int64,Int64,Int64}
const Pt128 = Tuple{Int128,Int128,Int128}
Pt128(x::Pt) = (Int128(x[1]),Int128(x[2]),Int128(x[3]))

function reducePoints(points::Vector{Pt})::Vector{Pt}
    uniquePoints = Set{Pt}()
    for p in points
        factor = gcd(gcd(p[1],p[2]),p[3])
        a::Pt =(p[1] ÷ factor, p[2] ÷ factor, p[3] ÷ factor)
        if a in uniquePoints; continue; end
        push!(uniquePoints,a)
    end
    return collect(uniquePoints)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        points::Vector{Pt}=fill((0,0,0),N)
        for i in 1:N
            points[i] = Tuple([parse(Int64,x) for x in split(rstrip(readline(infile)))])
        end
        points2 = reducePoints(points)
        N2 = length(points2)
        omni = true
        omnitrue = false
        coplanar::Vector{Int64} = Vector{Int64}()
        for i::Int64 in 1:N2-1
            for j::Int64 in i+1:N2
                resize!(coplanar,2)
                coplanar[1] = i
                coplanar[2] = j
                avec = mycross(points2[i],points2[j])
                if avec[1] == avec[2] == avec[3] == 0; omnitrue=true; break; end ## Antipodes, since we have already removed the same point numbers
                posfound::Bool = false
                negfound::Bool = false
                for k in 1:N2
                    if k == i || k == j; continue; end
                    x = mydot(points2[k],avec)
                    if     x > 0; posfound=true;
                    elseif x < 0; negfound=true;
                    else   push!(coplanar,k)
                    end
                    if posfound && negfound; break; end
                end
                if posfound && negfound || (length(coplanar) > 2 && checkCoplanar(points2,coplanar,avec))
                    continue 
                else
                    omni=false
                    break
                end
            end
            if omnitrue || !omni; break; end
        end
        ans = omni ? "YES" : "NO"
        print("$ans\n")
    end
end

#function checkCoplanar(points2::Vector{Vector{Int64}},coplanar::Vector{Int64},avec::Vector{Int64})::Bool
function checkCoplanar(points2::Vector{Pt},coplanar::Vector{Int64},avec::Pt)::Bool

    ## We could do this in n log n, but there isn't a huge incentive,
    ## since we will be taking out more work than that out of the outer
    ## loop with the skipsets
    ## Note there is an overflow problem here, so we need to bump up to Int128s
    for i in coplanar
        bvec::Pt128 = mycross(Pt128(avec),Pt128(points2[i]))
        posfound::Bool = false
        negfound::Bool = false
        for j in coplanar
            if i==j; continue; end
            x::Int128 = mydot(bvec,Pt128(points2[j]))
            if x == 0; return true;  ## antipodal
            elseif x > 0; posfound = true
            else   x < 0; negfound = true
            end
            if posfound && negfound; break; end
        end
        if !posfound || !negfound; return false; end
    end
    return true
end

function mydot(a::Pt,b::Pt)::Int64
    return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]
end

function mydot(a::Pt128,b::Pt128)::Int128
    return a[1]*b[1]+a[2]*b[2]+a[3]*b[3]
end

function mycross(a::Pt,b::Pt)::Pt
    return (a[2]*b[3]-b[2]*a[3], a[3]*b[1]-b[3]*a[1], a[1]*b[2]-b[1]*a[2])
end

function mycross(a::Pt128,b::Pt128)::Pt128
    return (a[2]*b[3]-b[2]*a[3], a[3]*b[1]-b[3]*a[1], a[1]*b[2]-b[1]*a[2])
end

#@time begin
main()
#end