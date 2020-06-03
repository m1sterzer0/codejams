using Printf

######################################################################################################
### The plan is to order the pairs by non-decreasing distance around the courtyard and merely
### "go left" and see what happens.  Like an old video game, we merely trace the wall with our hand
### and see what happens.  The devil is in the tedious details.
######################################################################################################

function processPP(PP::Array{Int64,1},perim::Int64)
    locpairs = []
    for (x,y) in zip(PP[1:2:length(PP)],PP[2:2:length(PP)])
        if x > y; x,y=y,x; end
        if y-x <= perim+x-y
            push!(locpairs,(y-x,(x,y)))
        else
            push!(locpairs,(perim+x-y,(y,x)))
        end
    end
    sort!(locpairs)
    return [xx[2] for xx in locpairs]
end

function convert(x::Int64,r::Int64,c::Int64)
    if     x <= c;    return (0,           x,         'S')
    elseif x <= r+c;  return (x-c,         c+1,       'W')
    elseif x <= r+2c; return (r+1,         c+r+c+1-x, 'N')
    else              return (c+r+c+r+1-x, 0,         'E')
    end
end

function move(y::Int64,x::Int64,d::Char,arr::Array{Char,2},r::Int64,c::Int64)
    ## Do the move
    (y,x) = (d == 'N') ? (y-1,x) :
            (d == 'S') ? (y+1,x) :
            (d == 'E') ? (y,x+1) : (y,x-1)

    ## Check for exit
    if y < 1 || y > r || x < 1 || x > c; return (y,x,d); end

    ## Place the hedge if necessary
    if arr[y,x] == ' '; arr[y,x] = d in "NS" ? '\\' : '/'; end

    ## Calculate the new direction
    if     (d == 'N'); d = arr[y,x] == '/' ? 'E' : 'W'
    elseif (d == 'E'); d = arr[y,x] == '/' ? 'N' : 'S'
    elseif (d == 'S'); d = arr[y,x] == '/' ? 'W' : 'E'
    else;              d = arr[y,x] == '/' ? 'S' : 'N'
    end

    return (y,x,d)
end

function goLeft(arr::Array{Char,2},p::Tuple{Int64,Int64},r::Int64,c::Int64)
    (s1,s2,d)     = convert(p[1],r,c)
    (e1,e2,dummy) = convert(p[2],r,c)
    while(true)
        (s1,s2,d) = move(s1,s2,d,arr,r,c)
        if s1 < 1 || s1 > r || s2 < 1 || s2 > c; break; end
    end
    return s1 == e1 && s2 == e2
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq:\n")
        R,C = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        PP = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        arr=fill(' ',R,C)
        pairs = processPP(PP,2*R+2*C)
        good = true
        for p in pairs
            res = goLeft(arr,p,R,C)
            if !res
                print("IMPOSSIBLE\n")
                good = false
                break
            end
        end
        if !good; continue; end
        ## Fill in all of the spaces with forward slash
        f(x) = x == ' ' ? '/' : x 
        arr = f.(arr)
        rows = [join(arr[i,:],"") for i in 1:R]
        ans = join(rows,"\n")
        print("$ans\n")
    end
end

main()