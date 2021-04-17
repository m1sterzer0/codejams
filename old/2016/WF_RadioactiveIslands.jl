using Printf

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

function ypp(C::Vector{Float64},x::Float64,y::Float64,yp::Float64)::Float64
    ds2::Float64 = yp*yp+1
    f::Float64 = 1.0
    g::Float64 = 0.0
    h::Float64 = 0.0
    x2::Float64 = x * x
    for yi in C
        ymyi::Float64 = (y-yi)
        ymyi2::Float64 = ymyi*ymyi
        denom::Float64 = x2 + ymyi2
        rdenom::Float64 = 1.0 / denom
        rdenom2::Float64 = rdenom*rdenom
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

function diffeqSolve(C::Vector{Float64}, y0::Float64, yp0::Float64, xstart::Float64,
                     xend::Float64, numpoints::Int64, yabsmax::Float64)
    good = true
    h = (xend-xstart) / (numpoints-1)
    halfh = 0.5 * h
    yarr = fill(0.0,numpoints)
    xarr = fill(0.0,numpoints)
    xarr[1] = xstart
    yarr[1] = y0
    x,y,yp = xstart,y0,yp0
    for i in 2:numpoints
        k1,l1 = yp, ypp(C,x,y,yp)
        k2,l2 = yp + halfh * l1, ypp(C,x+halfh,y+halfh*k1,yp+halfh*l1)
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

function slopeSearch(m1,m2,numpoints,A,B,C)
    xarr,yarr = [],[]
    good1,xarr1,yarr1 = diffeqSolve(C, A, m1, -10.0, 10.0, numpoints, 50.0)
    good2,xarr2,yarr2 = diffeqSolve(C, A, m2, -10.0, 10.0, numpoints, 50.0)
    y1,y2 = yarr1[end],yarr2[end]
    ## Ensure the we are braketing the points
    #print("m1:$m1 m2:$m2 good1:$good1 good2:$good2 y1:$y1 y2:$y2 B:$B\n")
    if good1 && y1 == B; return m1,m2,xarr1,yarr1; end
    if good2 && y2 == B; return m1,m2,xarr2,yarr2; end
    if !good1 || !good2 || (y1-B) * (y2-B) >= 0; print("ERROR!\n"); exit(1); end
    for i in 1:10
        mmid = 0.5 * (m1+m2)
        good,xarr,yarr = diffeqSolve(C, A, mmid, -10.0, 10.0, numpoints, 50.0)
        if yarr[end] == B; return m1,m2,xarr,yarr; end
        if (y1-B)*(yarr[end]-B) < 0; y2 = yarr[end]; m2 = mmid; 
        else                       ; y1 = yarr[end]; m1 = mmid;
        end
    end
    return m1,m2,xarr,yarr
end

function calcDose(xarr::Vector{Float64},yarr::Vector{Float64},C::Vector{Float64})::Float64
    dose = 0.0
    for i in 2:length(xarr)
        h = xarr[i]-xarr[i-1]
        dy = yarr[i]-yarr[i-1]
        xmid = 0.5*(xarr[i]+xarr[i-1])
        ymid = 0.5*(yarr[i]+yarr[i-1])
        incdose = 1.0
        for p in C
            incdose += 1.0 / (xmid*xmid + (ymid-p)*(ymid-p))
        end
        inctime = sqrt(h*h+dy*dy)
        dose += incdose * inctime
        #print("xmid:$xmid ymid:$ymid dy:$dy h:$h incdose:$incdose inctime:$inctime dose:$dose\n")
    end
    return dose
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        arr = split(rstrip(readline(infile)))
        N = parse(Int64,arr[1])
        A = parse(Float64,arr[2])
        B = parse(Float64,arr[3])
        C = [parse(Float64,x) for x in split(rstrip(readline(infile)))]
        npoints = 10001


        ## First pass, do a fine search on the slopes, but with only 1001 points run
        searchPoints = []
        lastgood,lastslope,lasty = false,-99,-99
        for m in [-4.0 + 0.0025x for x in 0:3200]
            good,xarr,yarr = diffeqSolve(C, A, m, -10.0, 10.0, npoints, 50.0)
            #print("$m $good $(yarr[end])\n")
            if good && lastgood && (lasty-B) * (yarr[end]-B) <= 0
                push!(searchPoints,(lastslope,m))
            end
            lastgood,lastslope,lasty = good,m,yarr[end]
        end
        best = 1e99
        ## Second pass, 
        for (m1,m2) in searchPoints
            m1,m2,xarr,yarr = slopeSearch(m1,m2,npoints,A,B,C)
            #print("Final m1:$m1 m2:$m2 y:{$(yarr[end])} B:{$B}\n")
            dose = calcDose(xarr,yarr,C)
            best = min(dose,best)
        end
        @printf("%.5f\n",best)
    end
end
        
main()