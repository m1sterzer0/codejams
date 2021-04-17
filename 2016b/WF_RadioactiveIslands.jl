
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
### Cool problem.
###
### 1) I believe the *intended* solution is the one that uses the Calculus of Variations, and in
###    particular the Euler-Lagrange equation.  This is the same equation that can be used to 
###    derive the Brachistochrone.  The attractiveness is that we get a 2nd-order differential
###    equation that we can numerically solve.
###
### 2) The challenge with this differential equation is that we really want to set the values
###    at the endpoints, but since we are doing this numerically, this isn't convenient.
###    We can easily set the initial heading.  Thus, we resolve to just sweep that inital
###    heading and look for solutions that come close to our endpoint.  We can binary search
###    as needed.  
######################################################################################################

###########################################################################################
### Do the math
###
## Calculate the second derivative
### L(x,y,yp)  = sqrt(yp^2+1) * (1 + sum(1 / (x^2 + (y-yi)^2)))
### Ly         = sqrt(yp^2+1) * sum(-2(y-yi)/(x^2 + (y-yi)^2)^2)
### Lyp        = yp / sqrt(yp^2+1) * (1 + sum(1 / (x^2 + (y-yi)^2)))
### d/dx (Lyp) = 1/sqrt(yp^2+1) * yp * sum( ((-2x - 2(y-yi) * yp) / (x^2 + (y-yi)^2)^2) +
###              1/sqrt(yp^2+1) * ypp * (1 + sum(1 / (x^2 + (y-yi)^2))) -
###              1/sqrt(yp^2+1)^3 * ypp * yp^2 * (1 + sum(1 / (x^2 + (y-yi)^2)))
###
### Now for some symbols:
### -- Let F = (1 + sum(1 / (x^2 + (y-yi)^2)))
### -- Let G = sum((y-yi) / (x^2 + (y-yi)^2)^2)
### -- Let H = sum(x / (x^2 + (y-yi)^2)^2)
### -- Let ds, ds2, ds3 = sqrt(yp^2+1), yp^2 + 1, (yp^2+1)^(3/2)
###
### L(x,y,p)   = ds * F
### Ly         = ds * (-2) * G
### Lyp        = yp / ds * F
### d/dx (Lyp) = 1/ds * yp * ( -2G * yp -2H ) + 1/ds * ypp * F + 1/ds3 * ypp * yp^2 * F
###
### Now we apply the euler lagrange equation: Ly = d/dx (Lyp)
### ds * (-2) * G = 1/ds * yp * ( -2G * yp -2H ) + 1/ds * ypp * F - 1/ds3 * ypp * yp^2 * F
### 
### Multiply by ds
### ds2 * (-2) * G = yp * ( -2G * yp - 2H ) + ypp * F - 1/ds2 * ypp * yp^2 * F
###
### Move ypp terms on the left and other terms on the right
### F * ypp * (1 - yp^2/ds2) = 2G * yp^2 + 2H yp - 2G * ds2
### ypp * F * 1/ds2 = 2 ((G * yp + H) * yp - G * ds2)
### ypp = 2 * ds2 * ((G * yp + H) * yp - G * ds2) / F
###
###########################################################################################

function ypp(C::VF,x::F,y::F,yp::F)::F
    ds2::F = yp*yp+1
    f::F,g::F,h::F = 1.0,0.0,0.0
    x2::F = x*x
    for yi::F in C
        ymyi::F = (y-yi)
        ymyi2::F = ymyi*ymyi
        denom::F = x2 + ymyi2
        rdenom::F = 1.0 / denom
        rdenom2::F = rdenom*rdenom
        f += rdenom
        g += ymyi * rdenom2
        h += x * rdenom2
    end
    return 2.0 * ds2 * ((g * yp + h) * yp - g * ds2) / f
end

#####################################################################
## For the diffeq solve, we used this reference:
## https://en.wikipedia.org/wiki/Runge%E2%80%93Kutta_methods
## We played around with {euler, midpoint, heun2, SSPRK3, and RK4}.
## euler had some divergence, so we are using midpoint method.
#####################################################################

function diffeqSolve(C::VF, y0::F, yp0::F, xstart::F,
                     xend::F, numpoints::I, yabsmax::F)::Tuple{Bool,VF,VF}
    good::Bool = true
    h::F = (xend-xstart) / (numpoints-1)
    halfh::F = 0.5 * h
    yarr::VF = fill(0.0,numpoints)
    xarr::VF = fill(0.0,numpoints)
    xarr[1] = xstart
    yarr[1] = y0
    x::F,y::F,yp::F = xstart,y0,yp0
    for i::I in 2:numpoints
        k1::F,l1::F = yp, ypp(C,x,y,yp)
        k2::F,l2::F = yp + halfh * l1, ypp(C,x+halfh,y+halfh*k1,yp+halfh*l1)
        x += h
        y += h * k2
        yp += h * l2
        xarr[i] = x
        yarr[i] = y
        if abs(y) > yabsmax; good=false; break; end
        if abs(x) < 0.2
            if abs(y-C[1]) < 0.2; good=false; break; end ## Flying too close to the sun
            if length(C) > 1 && abs(y-C[2]) < 0.2; good=false; break; end ## Flying too close to the sun
        end
    end
    return good,xarr,yarr
end

function slopeSearch(m1::F,m2::F,numpoints::I,A::F,B::F,C::VF)
    xarr::VF,yarr::VF = [],[]
    good1::Bool,xarr1::VF,yarr1::VF = diffeqSolve(C, A, m1, -10.0, 10.0, numpoints, 50.0)
    good2::Bool,xarr2::VF,yarr2::VF = diffeqSolve(C, A, m2, -10.0, 10.0, numpoints, 50.0)
    y1::F,y2::F = yarr1[end],yarr2[end]
    ## Ensure the we are braketing the points
    #print("m1:$m1 m2:$m2 good1:$good1 good2:$good2 y1:$y1 y2:$y2 B:$B\n")
    if good1 && y1 == B; return m1,m2,xarr1,yarr1; end
    if good2 && y2 == B; return m1,m2,xarr2,yarr2; end
    if !good1 || !good2 || (y1-B) * (y2-B) >= 0; print("ERROR!\n"); exit(1); end
    for i in 1:10
        mmid::F = 0.5 * (m1+m2)
        good,xarr,yarr = diffeqSolve(C, A, mmid, -10.0, 10.0, numpoints, 50.0)
        if yarr[end] == B; return m1,m2,xarr,yarr; end
        if (y1-B)*(yarr[end]-B) < 0; y2 = yarr[end]; m2 = mmid; 
        else                       ; y1 = yarr[end]; m1 = mmid;
        end
    end
    return m1,m2,xarr,yarr
end

function calcDose(xarr::VF,yarr::VF,C::VF)::F
    dose::F = 0.0
    for i::I in 2:length(xarr)
        h::F = xarr[i]-xarr[i-1]
        dy::F = yarr[i]-yarr[i-1]
        xmid::F = 0.5*(xarr[i]+xarr[i-1])
        ymid::F = 0.5*(yarr[i]+yarr[i-1])
        incdose::F = 1.0
        for p in C
            incdose += 1.0 / (xmid*xmid + (ymid-p)*(ymid-p))
        end
        inctime::F = sqrt(h*h+dy*dy)
        dose += incdose * inctime
    end
    return dose
end

function solve(N::I,A::F,B::F,C::VF)::F
    npoints = 10001
    ## First pass, do a fine search on the slopes, but with only 1001 points run
    searchPoints::Vector{Tuple{F,F}} = []
    lastgood::Bool,lastslope::F,lasty::F = false,-99,-99
    for m in [-4.0 + 0.0025x for x in 0:3200]
        good::Bool,xarr::VF,yarr::VF = diffeqSolve(C, A, m, -10.0, 10.0, npoints, 50.0)
        if good && lastgood && (lasty-B) * (yarr[end]-B) <= 0
            push!(searchPoints,(lastslope,m))
        end
        lastgood,lastslope,lasty = good,m,yarr[end]
    end
    best::F = 1e99
    ## Second pass, 
    for (m1::F,m2::F) in searchPoints
        m1,m2,xarr,yarr = slopeSearch(m1,m2,npoints,A,B,C)
        #print("Final m1:$m1 m2:$m2 y:{$(yarr[end])} B:{$B}\n")
        dose::F = calcDose(xarr,yarr,C)
        best = min(dose,best)
    end
    return best
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        xx::VS = gss()
        N = parse(Int64,xx[1])
        A = parse(Float64,xx[2])
        B = parse(Float64,xx[3])
        C = gfs()
        ans = solve(N,A,B,C)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

