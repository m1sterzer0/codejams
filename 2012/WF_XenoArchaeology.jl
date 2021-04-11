
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

function gencase(Nmax::I,Cmax::I,Xmax::I,corruptThresh::F=0.9995)
    N = rand(1:Nmax)
    corrupt::Vector{Bool} = [rand() < corruptThresh for i in 1:N]
    cx = rand(-Cmax:Cmax)
    cy = rand(-Cmax:Cmax)
    spts::SPI = SPI()
    while length(spts) < N; push!(spts,(rand(-Xmax:Xmax),rand(-Xmax:Xmax))); end
    lpts::VPI = [(x,y) for (x,y) in spts]
    shuffle!(lpts)
    X::VI = [xx[1] for xx in lpts]
    Y::VI = [xx[2] for xx in lpts]
    C::Vector{Char} = fill('.',N)
    for i in 1:N
        d = max(abs(X[i]-cx),abs(Y[i]-cy))
        d2 = d % 2 == 0
        C[i] = d2 ^ corrupt[i] ? '.' : '#'
    end
    return (N,X,Y,C)
end

function test(ntc::I,Nmax::I,Cmax::I,Xmax::I,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (N,X,Y,C) = gencase(Nmax,Cmax,Xmax)
        ans2 = solveLarge(N,X,Y,C)
        if check
            ans1 = solveSmall(N,X,Y,C)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(N,X,Y,C)
                ans2 = solveLarge(N,X,Y,C)
            end
       else
           print("Case $ttt: $ans2\n")
       end
    end
    if check; print("$pass/$ntc passed\n"); end
end

function solveSmall(N::I,X::VI,Y::VI,C::Vector{Char})::PI
    ansx::I = 1_000_000_000_000_000_000
    ansy::I = 0
    manh::I = 1_000_000_000_000_000_000
    for x in -300:300
        for y in -300:300
            if abs(x)+abs(y) > manh; continue; end
            if abs(x)+abs(y) == manh && x < ansx; continue; end
            if abs(x)+abs(y) == manh && x == ansx && y < ansy; continue; end
            good = true
            for i in 1:N
                if C[i] == '#'
                    if max(abs(X[i]-x),abs(Y[i]-y)) & 1 == 0; good = false; break; end
                else
                    if max(abs(X[i]-x),abs(Y[i]-y)) & 1 == 1; good = false; break; end
                end
            end
            if good; ansx = x; ansy = y; manh = abs(x)+abs(y); end
        end
    end
    return (ansx,ansy)
end    

function checkpoint(N::I,X::VI,Y::VI,C::Vector{Char},x::I,y::I)
    for i in 1:N
        if C[i] == '#'
            if max(abs(X[i]-x),abs(Y[i]-y)) & 1 == 0; return false; end
        else
            if max(abs(X[i]-x),abs(Y[i]-y)) & 1 == 1; return false; end
        end
    end
    return true
end

function solveLarge(N::I,X::VI,Y::VI,C::Vector{Char})::PI
    ansx = 1_000_000_000_000_000_000
    ansy = 0
    manh = 1_000_000_000_000_000_000

    ## First check the origin and the points nearest the origin on each line

    pts2check::SPI = Set{Tuple{Int64,Int64}}()
    push!(pts2check,(0,0))
    for i in 1:N
        x=X[i]; y=Y[i]; s = x+y
        if x+y > 0; push!(pts2check,(x+y,0)); else; push!(pts2check,(0,x+y)); end
        if x-y > 0; push!(pts2check,(x-y,0)); else; push!(pts2check,(0,y-x)); end
    end

    for (x0,y0) in pts2check
        for dx in -2:2
            for dy in -2:2
                x=x0+dx; y=y0+dy
                if abs(x)+abs(y) > manh; continue; end
                if abs(x)+abs(y) == manh && x < ansx; continue; end
                if abs(x)+abs(y) == manh && x == ansx && y < ansy; continue; end
                if checkpoint(N,X,Y,C,x,y); ansx=x; ansy=y; manh = abs(x)+abs(y); end
            end
        end
    end

    ## Now for the regular points
    empty!(pts2check)
    for (dx,dy) in ((0,0),(0,1),(1,0),(1,1))
        id::VI = []
        good = true
        for i in 1:N
            req = C[i] == '.' ? 0 : 1
            if (X[i]-dx) & 1 == req && (Y[i]-dy) & 1 == req; continue; end ## All centers of this parity work
            if (X[i]-dx) & 1 != req && (Y[i]-dy) & 1 != req; good = false; break; end ## No center of this parity will work.
            push!(id,i)  ## These are the interesting cases
        end
        if !good; continue; end
        sums::VI = []
        push!(sums,-3_000_000_000_000_000)
        push!(sums, 3_000_000_000_000_000)
        for i in id; push!(sums, X[i]+Y[i]); end
        unique!(sort!(sums))
        for i in 1:length(sums)-1
            A,B = sums[i],sums[i+1]
            lb = -3_000_000_000_000_000
            ub = 3_000_000_000_000_000
            for j in id
                x=X[j]; y=Y[j]; c=C[j]
                req = c == '.' ? 0 : 1
                if (x-dx) & 1 == req
                    if x+y <= A; lb = max(lb,x-y); else; ub = min(ub,x-y); end
                else
                    if x+y <= A; ub = min(ub,x-y); else; lb = max(lb,x-y); end
                end
                if ub < lb; break; end
            end
            if ub < lb; continue; end
            ## Now solve the rectangle with A <= x+y <= B and lb <= x-y <= ub
            for (s,d) in ((A,lb),(A,ub),(B,lb),(B,ub))
                if s+d % 2 == 0; x = (s+d) ÷ 2; y = s-x; push!(pts2check,(x,y))
                else;            x = (s+d+1) ÷ 2; y = s-x; push!(pts2check,(x,y))
                end
            end
        end
    end

    for (x0,y0) in pts2check
        for dx in -3:3  #1 for the slop in the intersection, 1 for the parity of dx,dy
            for dy in -3:3
                x=x0+dx; y=y0+dy
                if abs(x)+abs(y) > manh; continue; end
                if abs(x)+abs(y) == manh && x < ansx; continue; end
                if abs(x)+abs(y) == manh && x == ansx && y < ansy; continue; end
                if checkpoint(N,X,Y,C,x,y); ansx=x; ansy=y; manh = abs(x)+abs(y); end
            end
        end
    end
    return (ansx,ansy)
end


function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X::VI = fill(0,N)
        Y::VI = fill(0,N)
        C::Vector{Char} = fill('.',N)
        for i in 1:N
            s = gss()
            X[i] = parse(Int64,s[1])
            Y[i] = parse(Int64,s[2])
            C[i] = s[3][1]
        end
        (xans,yans) = solveSmall(N,X,Y,C)
        #(xans,yans) = solveLarge(N,X,Y,C)
        if xans == 1_000_000_000_000_000_000; print("Too damaged\n"); continue; end
        print("$xans $yans\n")
    end
end

Random.seed!(8675309)
main()
#test(1000,4,300,100)
#test(1000,100,300,100)
#test(1000,1000,3_000_000_000_000_000,1_000_000_000_000_000,false)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

