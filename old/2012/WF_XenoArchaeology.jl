
function checkpoint(N::Int64,X::Vector{Int64},Y::Vector{Int64},C::Vector{Char},x::Int64,y::Int64)
    for i in 1:N
        if C[i] == '#'
            if max(abs(X[i]-x),abs(Y[i]-y)) & 1 == 0; return false; end
        else
            if max(abs(X[i]-x),abs(Y[i]-y)) & 1 == 1; return false; end
        end
    end
    return true
end

function solve(N::Int64,X::Vector{Int64},Y::Vector{Int64},C::Vector{Char})
    ansx = 1_000_000_000_000_000_000
    ansy = 0
    manh = 1_000_000_000_000_000_000

    ## First check the origin and the points nearest the origin on each line

    pts2check::Set{Tuple{Int64,Int64}} = Set{Tuple{Int64,Int64}}()
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
        id::Vector{Int64} = []
        good = true
        for i in 1:N
            req = C[i] == '.' ? 0 : 1
            if (X[i]-dx) & 1 == req && (Y[i]-dy) & 1 == req; continue; end ## All centers of this parity work
            if (X[i]-dx) & 1 != req && (Y[i]-dy) & 1 != req; good = false; break; end ## No center of this parity will work.
            push!(id,i)  ## These are the interesting cases
        end
        if !good; continue; end
        sums::Vector{Int64} = []
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
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        N = gi()
        X::Vector{Int64} = fill(0,N)
        Y::Vector{Int64} = fill(0,N)
        C::Vector{Char} = fill('.',N)
        for i in 1:N
            s = gss()
            X[i] = parse(Int64,s[1])
            Y[i] = parse(Int64,s[2])
            C[i] = s[3][1]
        end
        (xans,yans) = solve(N,X,Y,C)
        if xans == 1_000_000_000_000_000_000; print("Too damaged\n"); continue; end
        print("$xans $yans\n")
    end
end

main()

