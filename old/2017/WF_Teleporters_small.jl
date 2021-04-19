using Printf

######################################################################################################
### The key observations here are the following
### a) The only way we can reach the target planet in 1 step is if a teleporter is equidistant from
###    the starter planet and the current planet.
### b) If we only have one teleporter and we can't reach the planet in one hop, then we can't reach
###    the planet in infinite hops, because we are stuck on the surface of the L1-sphere around
###    the only teleporter, and the planet isn't on the surface of that sphere.
### c) If we can't reach the planet in one hop, the set of possible positions is the union of L1-spheres
###    each of which is centered around a teleporter.  Note these L1-spheres have a radius of the
###    distance of the starting planet to the teleporter.  Furthermore, since the starting planet
###    is in EACH of these spheres, the entire network is CONNECTED.
### d) Now, consider a second hop using teleporter i.  We consider the CONNECTED set of possible
###    starting positions before this 2nd hop, and we realize that this connected set has a minimum
###    distance from teleporter i and a maximum distance from teleporter i.  Since that graph is
###    connected and since the distance function is continuous, it is possible to hop to any distance
###    from teleporter i between these two extreme.  Thus, the set of points where I can get using
###    teleporter i is the space between the surfaces of 2 concentric L-1 spheres centered at teleporter
###    i.
### e) This sets up a sort of dynamic programming approach.  We can calculate the next set of inner-outer
###    radii based on the previous set.  We notice that the outer radii will all increase at each step, and
###    the inner radii will decrease, so we will eventually hit the target planet.
###
###    --- Outer radii can be calculated as Ui = max_j{U_j + D_i,j}
###    --- Inner radii can be calculated as Li = min_J{ L_j > D_j ? L_j - D_j : U_j < D_j ? D_j - U_j : 0}
### f) The worst case here is when U_i == U_j and D_i,j = 1.  Then U_i and U_j will grow by 1 each step
###    so it will take 6000 steps to get from one end of the space to the other, so this is O(N^2*M)
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = parse(Int64,rstrip(readline(infile)))
        Xs,Ys,Zs = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        Xf,Yf,Zf = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        X,Y,Z = fill(0,N),fill(0,N),fill(0,N)
        for i in 1:N
            X[i],Y[i],Z[i] = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        end

        Lprev = fill(0,N)
        Uprev = fill(0,N)
        Lcur  = fill(0,N)
        Ucur  = fill(0,N)

        Darr = fill(0,N,N)
        Ds = fill(0,N)
        Df = fill(0,N)
        for i in 1:N
            for j in i+1:N
                Darr[i,j] = Darr[j,i] = abs(X[j]-X[i]) + abs(Y[j]-Y[i]) + abs(Z[j]-Z[i])
            end
            Ds[i] = abs(Xs-X[i]) + abs(Ys-Y[i]) + abs(Zs-Z[i])
            Df[i] = abs(Xf-X[i]) + abs(Yf-Y[i]) + abs(Zf-Z[i])
        end

        ## Do the first
        first = false
        for i in 1:N
            if Ds[i] == Df[i]; first=true; break; end
            Lcur[i] = Ucur[i] = Ds[i] 
        end
        if first; print("1\n"); continue; end
        if N==1; print("IMPOSSIBLE\n"); continue; end 

        ## Do the rest
        m = 1
        done = false
        while (true)
            m += 1
            (Lprev,Lcur) = (Lcur,Lprev)
            (Uprev,Ucur) = (Ucur,Uprev)
            for i in 1:N
                Lcur[i] = Lprev[i]
                Ucur[i] = Uprev[i]
                for j in 1:N
                    if i == j; continue; end
                    ## Jumping from j to i, so max is D[i,j] + U[j]
                    Ucur[i] = max(Ucur[i],Darr[i,j]+Uprev[j])
                    if Lprev[j] > Darr[i,j]
                        Lcur[i] = min(Lcur[i],Lprev[j]-Darr[i,j])
                    elseif Darr[i,j] > Uprev[j]
                        Lcur[i] = min(Lcur[i],Darr[i,j]-Uprev[j])
                    else
                        Lcur[i] = 0
                    end
                end
                if Lcur[i] <= Df[i] <= Ucur[i]
                    done=true
                    break
                end
            end
            if done; break; end
        end
        print("$m\n")
    end
end

main()
