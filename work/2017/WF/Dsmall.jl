using Printf
using LinearAlgebra
######################################################################################################
### We just look at all N^2 planes and make sure that there are points on either side of the plane.
### WC: O(N^3).  Not "super inspired".  Special cases:
###     * We need to get rid of duplicates.  Use GCD
###     * If any two points are antipodes, we are done
###     * If we have a set of points that are all coplanar with the origin and all other points are on one side,
###         * we need to check if the points are all within the same semicircle
### Note by DUMB LUCK, this passes the both the small and large, but there are a couple of improvements
### to be made.
######################################################################################################

function reducePoints(points,N)
    uniquePoints = Set()
    for i in 1:N
        factor = gcd(gcd(points[i,1],points[i,2]),points[i,3])
        a = [points[i,1] ÷ factor, points[i,2] ÷ factor, points[i,3] ÷ factor]
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
        points=fill(0,N,3)
        for i in 1:N
            points[i,:] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end
        points2 = reducePoints(points,N)
        N2 = length(points2)
        omni = true
        omnitrue = false
        skipSet = Set{Tuple{Int64,Int64}}()
        for i in 1:N2-1
            for j in i+1:N2
                if (i,j) ∈ skipSet; continue; end
                coplanar = [i,j]
                avec = cross(vec(points2[i]),vec(points2[j]))
                if avec[1] == avec[2] == avec[3] == 0; omnitrue=true; break; end ## Antipodes, since we have already removed the same point numbers
                posfound = false
                negfound = false
                for k in 1:N2
                    if k == i || k == j; continue; end
                    x = dot(points2[k],avec)
                    if     x > 0; posfound=true;
                    elseif x < 0; negfound=true;
                    else   push!(coplanar,k)
                    end
                    if posfound && negfound; break; end
                end
                if posfound && negfound
                    continue
                elseif length(coplanar) > 2 && checkCoplanar(points2,coplanar,avec)
                    for ii in coplanar
                        for jj in coplanar
                            if ii == jj; continue; end
                            push!(skipSet,(min(ii,jj),max(ii,jj)))
                        end
                    end
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

function checkCoplanar(points2,coplanar,avec)
    ## We could do this in n log n, but there isn't a huge incentive,
    ## since we will be taking out more work than that out of the outer
    ## loop with the skipsets
    for i in coplanar
        bvec = cross(vec(avec),vec(points2[i]))
        posfound = false
        negfound = false
        for j in coplanar
            if i==j; continue; end
            x = dot(bvec,points2[j])
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

main()
