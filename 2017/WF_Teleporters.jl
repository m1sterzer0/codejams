
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

function solveSmall(N::I,Xs::I,Ys::I,Zs::I,Xf::I,Yf::I,Zf::I,
                    X::VI,Y::VI,Z::VI)::String
    Lprev::VI = fill(0,N)
    Uprev::VI = fill(0,N)
    Lcur::VI  = fill(0,N)
    Ucur::VI  = fill(0,N)

    Darr::Array{I,2} = fill(0,N,N)
    Ds::VI = fill(0,N)
    Df::VI = fill(0,N)
    for i::I in 1:N
        for j::I in i+1:N
            Darr[i,j] = Darr[j,i] = abs(X[j]-X[i]) + abs(Y[j]-Y[i]) + abs(Z[j]-Z[i])
        end
        Ds[i] = abs(Xs-X[i]) + abs(Ys-Y[i]) + abs(Zs-Z[i])
        Df[i] = abs(Xf-X[i]) + abs(Yf-Y[i]) + abs(Zf-Z[i])
    end

    ## Do the first
    first::Bool = false
    for i::I in 1:N
        if Ds[i] == Df[i]; first=true; break; end
        Lcur[i] = Ucur[i] = Ds[i] 
    end
    if first; return "1"; end 
    if N==1; return "IMPOSSIBLE"; end 

    ## Do the rest
    m::I = 1
    done::Bool = false
    while (true)
        m += 1
        (Lprev,Lcur) = (Lcur,Lprev)
        (Uprev,Ucur) = (Ucur,Uprev)
        for i::I in 1:N
            Lcur[i] = Lprev[i]
            Ucur[i] = Uprev[i]
            for j::I in 1:N
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
    return "$m"
end

######################################################################################################
### Now for the observations we need for the large.  In short, the biggest problem is that "M" factor.
### Note I didn't come up with most of this -- this is a summary of the given solution.
### g) Let's assume that we check for a 1 step solution beforehand.  Thus, we can assume we need to
###    take at least two steps.
### h) Now lets assume we have two teleporters, where one (say teleporter "u") is closer to the
###    starting planet (P), and one (say teleporter "v') is closer to the target planet (Q).  We claim
###    that when this is the case, we can always make it to the target planet in exactly 2 moves
###    by first using teleporter v and then using teleporter u.
###    --- To see this, we draw the L1-sphere around v that includes P.  This is where we can reach
###        on our first jump.
###    --- We also draw the L1 sphere around u that includes Q.  This represents the set of points from
###        which we can reach get to Q on the next jump.
###    --- We observe these two spheres intersect (technicals of the distance arguments omitted),
###        so there is an intermediate point we can use for the first hop.
### i) The previous observations suggests that there is a symmetry/reversability to the problem.  So we can
###    swap P and Q as needed such that all of the teleporters are closest to P.
### j) As per our discussion above in the short, U_i increases with steps, and L_i decreases with steps,
###    so after taking care of cases in (g) and (h) and perhaps switching the role so P/Q in (i), we
###    can assume that we are never limited by L_i (as Q isn't in the initial L_is, and the L_is shrink).
###    Thus, we only really have to worry about the U_is.
### k) Now we consider how the Ui terms grow.  The key observation is that if I start a path at i with Ui
###    and take several hops and end  at j, the "new Uj" is just the original Ui + the sum of the distances
###    of the hops I took.
### l) While we can't easily make an efficient dp for the "max possible" Ui, we can make a DP that calculates
###    the "longest path" from i to j in N hops.  The recursion that works is as follows
###    D[i,j,2^k] = max_x{D[i,x,2^(k-1)]+D[x,j,2^(k-1)]}.  We of course store the exponents (or 1+exponent
###    in the case of julia) as the 3rd index, but the recursion lets us get a set max distances for
###    binary hops in log(M)*N^3 time.
### m) After this, we just do a binary search on the number of hops which are needed
######################################################################################################

function solveLarge(N::I,Xs::I,Ys::I,Zs::I,Xf::I,Yf::I,Zf::I,
                    X::VI,Y::VI,Z::VI)::String

    Darr::Array{I,2} = fill(0,N,N)
    Ds::VI = fill(0,N)
    Df::VI = fill(0,N)
    for i::I in 1:N
        for j::I in i+1:N
            Darr[i,j] = Darr[j,i] = abs(X[j]-X[i]) + abs(Y[j]-Y[i]) + abs(Z[j]-Z[i])
        end
        Ds[i] = abs(Xs-X[i]) + abs(Ys-Y[i]) + abs(Zs-Z[i])
        Df[i] = abs(Xf-X[i]) + abs(Yf-Y[i]) + abs(Zf-Z[i])
    end

    ## Do the first
    first::Bool = false
    closerToF::Bool = false
    closerToS::Bool = false
    for i::I in 1:N
        if Ds[i] == Df[i]; first=true; break;
        elseif Ds[i] < Df[i]; closerToS=true;
        else;                 closerToF=true;
        end 
    end
    if first; return "1"; end
    if N==1; return "IMPOSSIBLE"; end 
    if closerToF && closerToS; return "2"; end
    if closerToF; (Ds,Df) = (Df,Ds); end

    ## Build the longest distance matrix
    ## There will be some overflow, but we can walk our way up
    ## to what we need and then walk our way back down.
    ## the overflow will only happen

    Dtarg = repeat(Df',N,1) .- repeat(Ds,1,N)
    D = Vector{Array{Int128,2}}()
    D1 = Int128.(Darr)
    push!(D,D1)

    k = 1
    Dtry = fill(zero(Int128),N,N)
    while !any(D[end] .>= Dtarg)
        k += 1
        Dnew = fill(zero(Int128),N,N)
        for x in 1:N
            Dnew .= max.(Dnew,D[end][:,x] .+ D[end][x,:]')
        end
        push!(D,Dnew)
    end

    if k==1; return "2"; end
    if k==2; return "3"; end
    Dub = copy(D[end])
    Dlb = copy(D[end-1])
    Dtest = fill(zero(Int128),N,N)
    ub = 2^(k-1)
    lb = 2^(k-2)
    for xidx in k-2:-1:1
        m = (ub+lb) ÷ 2
        fill!(Dtest,zero(Int128))
        for x in 1:N
            Dtest .= max.(Dtest,Dlb[:,x] .+ D[xidx][x,:]')
        end
        if any(Dtest .≥ Dtarg)
            Dub .= Dtest
            ub = m
        else
            Dlb .= Dtest
            lb = m
        end
    end
    return "$(ub+1)"
end

function gencase(Nmin::I,Nmax::I,Cmax::I,Cfmax::I)
    N = rand(Nmin:Nmax)
    pts = Set{TI}()
    while length(pts) < N+1
        x = rand(-Cmax:Cmax)
        y = rand(-Cmax:Cmax)
        z = rand(-Cmax:Cmax)
        push!(pts,(x,y,z))
    end
    lpts = shuffle([x for x in pts])
    (Xs,Ys,Zs) = popfirst!(lpts)
    Xf,Yf,Zf = rand(-Cfmax:Cfmax,3)
    X = [x[1] for x in lpts]
    Y = [x[2] for x in lpts]
    Z = [x[3] for x in lpts]
    return (N,Xs,Ys,Zs,Xf,Yf,Zf,X,Y,Z)
end

function test(ntc::I,Nmin::I,Nmax::I,Cmax::I,Cfmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,Xs,Ys,Zs,Xf,Yf,Zf,X,Y,Z) = gencase(Nmin,Nmax,Cmax,Cfmax)
        ans2 = solveLarge(N,Xs,Ys,Zs,Xf,Yf,Zf,X,Y,Z)
        if check
            ans1 = solveSmall(N,Xs,Ys,Zs,Xf,Yf,Zf,X,Y,Z)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,Xs,Ys,Zs,Xf,Yf,Zf,X,Y,Z)
                ans2 = solveLarge(N,Xs,Ys,Zs,Xf,Yf,Zf,X,Y,Z)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        Xs,Ys,Zs = gis()
        Xf,Yf,Zf = gis()
        X::VI = fill(0,N)
        Y::VI = fill(0,N)
        Z::VI = fill(0,N)
        for i in 1:N; X[i],Y[i],Z[i] = gis(); end
        #ans = solveSmall(N,Xs,Ys,Zs,Xf,Yf,Zf,X,Y,Z)
        ans = solveLarge(N,Xs,Ys,Zs,Xf,Yf,Zf,X,Y,Z)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#for ntc in (1,10,100,1000)
#    test(ntc,1,100,10,1000)
#    test(ntc,1,100,1000,1000)
#end
#test(200,1,150,1000,1_000_000_000_000,false)
#test(200,1,150,1_000_000_000_000,1_000_000_000_000,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

