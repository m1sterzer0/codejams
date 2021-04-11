
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

function solveSmall(H::I,W::I,D::I,board::Array{Char,2})::I
    sols::Set{PI} = Set{PI}()    
    ox,oy = 0,0
    for y in 1:H; for x in 1:W
        if board[y,x] == 'X'; oy=y; ox=x; end
    end; end
    dy = 2*(oy-1)-1
    dx = 2*(ox-1)-1
    for i in -50:50
        for j in -50:50
            for (yoff,xoff) in ((oy,ox),(oy-dy,ox),(oy,ox-dx),(oy-dy,ox-dx))
                x = 2*(W-2)*i+xoff
                y = 2*(H-2)*j+yoff
                if (x,y) == (ox,oy); continue; end
                if abs(x-ox) > D; continue; end
                if abs(y-oy) > D; continue; end
                if (x-ox)*(x-ox)+(y-oy)*(y-oy) > D*D; continue; end
                dirx = (x-ox); diry = (y-oy)
                g = gcd(dirx,diry); dirx ÷= g; diry ÷= g
                push!(sols,(dirx,diry))
            end
        end
    end
    return length(sols)
end

function solvepath(dy::I,dx::I)::VPI
    if dy == 0; return [(0,1) for i in 1:dx]; end
    if dx == 0; return [(1,0) for i in 1:dy]; end
    lastright = 0
    path::VPI = []
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

function tracepath(j::I,i::I,p::VPI,board::Array{Char,2})::PI
    my,mx = false,false
    (sj,si) = (j,i)
    #print("DBG: begin tracepath($j,$i,$p)\n")
    for (delj,deli) in p
        #print("DBG: j:$j i:$i my:$my mx:$mx delj:$delj deli:$deli\n")
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

function solveLarge(H::I,W::I,D::I,board::Array{Char,2})::I
    startx,starty = 0,0
    for y in 1:H; for x in 1:W
        if board[y,x] == 'X'; starty=y; startx=x; end
    end; end
    found::SPI = SPI()
    for dx in -50:50
        for dy in -50:50
            if dx == 0 && dy == 0; continue; end
            if dx*dx+dy*dy > D*D; continue; end
            (gdx,gdy) = (dx ÷ gcd(dx,dy),dy ÷ gcd(dx,dy))
            if (gdy,gdx) in found; continue; end
            adx,ady = abs(dx),abs(dy)
            p1::VPI = solvepath(ady,adx)
            (sy,sx) = (sign(dy),sign(dx))
            p::VPI = [(sy*y,sx*x) for (y,x) in p1]
            (j2,i2) = tracepath(starty,startx,p,board)
            if (j2,i2) == (starty,startx)
                push!(found,(gdy,gdx))
            end
        end
    end
    ans = length(found)
end

function gencase(Wmin::I,Wmax::I,Hmin::I,Hmax::I,Dmin::I,Dmax::I,fillmin::F,fillmax::F)
    W = rand(Wmin:Wmax)
    H = rand(Hmin:Hmax)
    D = rand(Dmin:Dmax)
    x = rand(2:W-1)
    y = rand(2:H-1)

    fillp = fillmin + (fillmax-fillmin) * rand()
    board::Array{Char,2} = fill('.',H,W)
    for i in 1:H; for j in 1:W
        if rand() < fillp; board[i,j] = '#'; end
    end; end
    board[y,x] = 'X'
    for i in 1:W; board[1,i] = '#'; board[H,i] = '#'; end
    for j in 1:H; board[j,1] = '#'; board[j,W] = '#'; end
    return (H,W,D,board)
end

function test(ntc::I,Wmin::I,Wmax::I,Hmin::I,Hmax::I,Dmin::I,Dmax::I,fillmin::F,fillmax::F,check::Bool=true)
    pass = 0
    for ttt in 1:ntc
        (H,W,D,board) = gencase(Wmin,Wmax,Hmin,Hmax,Dmin,Dmax,fillmin,fillmax)
        ans2 = solveLarge(H,W,D,board)
        if check
            ans1 = solveSmall(H,W,D,board)
            if ans1 == ans2
                 pass += 1
            else
                print("ERROR: ttt:$ttt ans1:$ans1 ans2:$ans2\n")
                ans1 = solveSmall(H,W,D,board)
                ans2 = solveLarge(H,W,D,board)
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
        H,W,D = gis()
        board::Array{Char,2} = fill('.',H,W)
        for y in 1:H
            ln = gs()
            board[y,:] = [x for x in ln]
        end
        ans = solveSmall(H,W,D,board)
        #ans = solveLarge(H,W,D,board)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
#test(100,3,4,3,4,1,50,0.00,0.00)

#using Profile, StatProfilerHTML
#Profile.clear()
#@profile main("B.in")
#Profile.clear()
#@profilehtml main("B.in")

