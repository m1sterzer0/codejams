
function solve(N::Int64,X::Vector{Int64},Y::Vector{Int64},C::Vector{Char})
    ansx = 1_000_000_000_000_000_000
    ansy = 0
    manh = 1_000_000_000_000_000_000

    ## Each point X,Y describes 2 lines, one with constant x+y and the other with constant x-y
    ## Want to check the following 4 types of points
    ## a) Origin
    ## b) Closest point to the origin on each line, subject to the tiebreakers in the problem
    ## c) Set of closest points to each line intersection
    pts2check::Set{Tuple{Int64,Int64}} = Set{Tuple{Int64,Int64}}()
    push!(pts2check,(0,0))
    for i in 1:N
        x=X[i]; y=Y[i]; s = x+y
        if x+y > 0; push!(pts2check,(x+y,0)); else; push!(pts2check,(0,x+y)); end
        if x-y > 0; push!(pts2check,(x-y,0)); else; push!(pts2check,(0,y-x)); end
        for j in 1:N
            x2=X[j]; y2=Y[j]; s = x+y; d = x2-y2
            if s+d % 2 == 0 && s-d % 2 == 0
                x3 = (s+d) ÷ 2; y3 = (s-d) ÷ 2
                push!(pts2check,(x3,y3))
            elseif s+d % 2 == 0
                x3 = (s+d) ÷ 2; y3a = s-x3; y3b = x3 - d
                push!(pts2check,(x3,y3a))
                push!(pts2check,(x3,y3b))
            elseif s-d % 2 == 0
                y3 = (s-d) ÷ 2; x3a = s - y3; x3b = d + y3;
                push!(pts2check,(x3a,y3))
                push!(pts2check,(x3b,y3))
            else
                x3a = (s+d-1) ÷ 2; x3b = x3a+1
                y3a = (s-d-1) ÷ 2; y3b = y3a+1
                push!(pts2check,(x3a,y3a))
                push!(pts2check,(x3a,y3b))
                push!(pts2check,(x3b,y3a))
                push!(pts2check,(x3b,y3b))
            end
        end
    end

    for (x0,y0) in pts2check
        for dx in (-2,-1,0,1,2)
            for dy in (-2,-1,0,1,2)
                x=x0+dx;y=y0+dy
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

