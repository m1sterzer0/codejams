
function solvepath(dy::Int64,dx::Int64)::Vector{Tuple{Int64,Int64}}
    if dy == 0; return [(0,1) for i in 1:dx]; end
    if dx == 0; return [(1,0) for i in 1:dy]; end
    lastright = 0
    path::Vector{Tuple{Int64,Int64}} = []
    for i in 0:dx
        rawleft = (2i-1) * dy ÷ dx
        rawright = ((2i+1) * dy - 1) ÷ dx
        left = i == 0 ? 0 : (rawleft+1) ÷ 2
        right = i == dx ? dy : (rawright+1) ÷ 2
        if i > 0 
            if left == lastright; push!(path,(0,1)); else; push!(path,(1,1)); end
        end
        for _i in left:right-1; push!(path,(1,0)); end
        lastright = right
    end
    return path
end

function findx(board,H,W)
    for j in 1:H
        for i in 1:W
            if board[j,i] == 'X'; return (j,i); end
        end
    end
    return (0,0)
end

function tracepath(j,i,p,board)
    my,mx = false,false
    (sj,si) = (j,i)
    for (delj,deli) in p
        if my; delj = -delj; end
        if mx; deli = -deli; end
        if board[j+delj,i+deli] != '#'
            i += deli; j += delj
        elseif delj == 0 || deli == 0
            if deli != 0; mx = !mx; end
            if delj != 0; my = !my; end
        else
            cns = board[j+delj,i]
            cew = board[j,i+deli]
            if      cns != '#' && cew != '#'; return(0,0)
            elseif  cns == '#' && cew == '#'; mx = !mx; my = !my
            elseif  cns == '#'; my = !my; i += deli
            else;               mx = !mx; j += delj
            end
        end
    end
    return (j,i)
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        H,W,D = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        board::Array{Char,2} = fill('.',H,W)
        for y in 1:H; board[y,:] = [x for x in rstrip(readline(infile))]; end
        (starty,startx) = findx(board,H,W)
        found = Set{Tuple{Int64,Int64}}()
        for dx in -50:50
            for dy in -50:50
                if dx == 0 && dy == 0; continue; end
                if dx*dx+dy*dy > D*D; continue; end
                (gdx,gdy) = (dx ÷ gcd(dx,dy),dy ÷ gcd(dx,dy))
                if (gdy,gdx) in found; continue; end
                adx,ady = abs(dx),abs(dy)
                p1 = solvepath(ady,adx)
                (sy,sx) = (sign(dy),sign(dx))
                p = [(sy*y,sx*x) for (y,x) in p1]
                (j2,i2) = tracepath(starty,startx,p,board)
                if (j2,i2) == (starty,startx)
                    push!(found,(gdy,gdx))
                end
            end
        end
        ans = length(found)
        print("$ans\n")
    end
end

main()   
