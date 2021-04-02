
function solve(N::Int64,X::Vector{Int64},Y::Vector{Int64},C::Vector{Char})
    ansx = 1_000_000_000_000_000_000
    ansy = 0
    manh = 1_000_000_000_000_000_000
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

