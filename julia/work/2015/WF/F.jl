######################################################################################################
### BEGIN MAIN PROGRAM
### Key observations
### * Dealing with 0-255 is easier than 1-256, so we do that.
### * Note p1 will only change the values near the starting position.   Call this region the "base".
### * Note that if we widen the base a bit, when we execute p2, we will always end up in the base after executing p2.
### * After p2, the non-base will have a sequence with the period of the "move delta" of p2
### * For the small input
###   * We don't even have to keep track of what happens within the periodic non-base region.  We just have to count the interations to get through it.
###   * we don't really even have to simulate p3 either
### * For the large input
###   * After p1(p2)p3, we will have a large non-base region that is periodic with period lcm(md1,md2)
###   * Again, if we widen our original base region to cover enough area, we don't have to simulate the non-base stuff
######################################################################################################

mutable struct craneSegment
    wl::Int64
    wr::Int64
    c::Int64
    deltaarr::Vector{UInt8}
    totmoves::Int64
end

function parseSegment(p)::craneSegment
    if length(p) == 0; return craneSegment(0,0,0,[],0); end
    deltaarr::Vector{UInt8} = zeros(UInt8,1+2*length(p))
    startloc = length(p)+1
    wl,wr,c,totmoves = 0,0,0,0
    for cc in p
        if     cc == 'b'; c -= 1; wl=min(wl,c); totmoves += 1
        elseif cc == 'f'; c += 1; wr=max(wr,c); totmoves += 1
        elseif cc == 'u'; deltaarr[startloc+c] += UInt8(255)
        elseif cc == 'd'; deltaarr[startloc+c] += UInt8(1)
        end
    end
    return craneSegment(wl,wr,c,deltaarr[startloc+wl:startloc+wr],totmoves) 
end

function parseProg(s)
    p1,p2,p3,p4,p5 = "","","","",""
    lparenidx = findall(x->x=='(',s)
    rparenidx = findall(x->x==')',s)
    if length(lparenidx) == 0
        p1 = s
    elseif length(lparenidx) == 1
        if lparenidx[1] > 1; p1 = s[1:lparenidx[1]-1]; end
        if rparenidx[1]-lparenidx[1] > 1; p2 = s[lparenidx[1]+1:rparenidx[1]-1]; end
        if rparenidx[1] < length(s); p3 = s[rparenidx[1]+1:end]; end
    else
        if lparenidx[1] > 1; p1 = s[1:lparenidx[1]-1]; end
        if rparenidx[1]-lparenidx[1] > 1; p2 = s[lparenidx[1]+1:rparenidx[1]-1]; end
        if lparenidx[2]-rparenidx[1] > 1; p3 = s[rparenidx[1]+1:lparenidx[2]-1]; end
        if rparenidx[2]-lparenidx[2] > 1; p4 = s[lparenidx[2]+1:rparenidx[2]-1]; end
        if rparenidx[2] < length(s);      p5 = s[rparenidx[2]+1:end]; end
    end
    return p1,p2,p3,p4,p5
end

function solveit(prework,p1,p2,p3,p4,p5)
    left,right = sizebase(p1,p2,p3,p4,p5)          ## First pass to find the size of the non-base
    ans = dosim(prework,p1,p2,p3,p4,p5,left,right) ## Second pass to do the simulation
    print("$ans\n")    
end

function sizebase(p1,p2,p3,p4,p5)
    cs1,cs2,cs3,cs4,cs5 = [parseSegment(x) for x in [p1,p2,p3,p4,p5]]
    left,right = 0,0
    left = -cs1.wl -cs2.wl -cs3.wl -cs4.wl
    right = cs1.wr + cs2.wr + cs3.wr + cs4.wr
    period = 1
    if cs2.c < 0; period *= abs(cs2.c); left  += period; end
    if cs2.c > 0; period *= cs2.c;      right += period; end
    if cs4.c < 0; period *= abs(cs4.c); left  += period; end ## Could use lcm to pinch, but won't help with primes near 1k which will be limiting case (period ~ 1M)
    if cs4.c > 0; period *= cs4.c;      right += period; end

    ## Now we correct to make sure the periodic region is a multiple of the period
    basesize = left+right+1
    nonbasesize = ((2^40-basesize) ÷ period) * period
    right += 2^40 - basesize - nonbasesize
    return left,right
end

function dosim(prework,p1,p2,p3,p4,p5,left,right)::Int128
    cs1,cs2,cs3,cs4,cs5 = [parseSegment(x) for x in [p1,p2,p3,p4,p5]]
    ans::Int128 = 0
    d::Vector{UInt8} = zeros(UInt8,left+right+1)
    c = 1+left
    if length(p1) > 0
        d[c+cs1.wl:c+cs1.wr] += cs1.deltaarr
        c += cs1.c
        ans+=cs1.totmoves
    end
    if length(p2) > 0
        incans,c = solveloopadv(d,c,cs2,prework)
        ans += incans
        #print(stderr,"\nDBG: Loop2 done  incans:$incans c:$c d:$d\n")
    end
    if length(p3) > 0
        d[c+cs3.wl:c+cs3.wr] += cs3.deltaarr
        c += cs3.c
        ans+=cs3.totmoves
    end
    if length(p4) > 0
        incans,c = solveloopadv(d,c,cs4,prework)
        ans += incans
        #print(stderr,"\nDBG: Loop4 done\n")
     end
    ans += cs5.totmoves
    return ans
end

function solveloopadv(basearr::Vector{UInt8},cursor::Int64,cs::craneSegment,prework::Array{Int64,2})
    basesize = length(basearr)
    nonbasesize = 2^40 - basesize
    wraparoundmoves = cs.c == 0 ? 0 : (nonbasesize ÷ abs(cs.c)) * cs.totmoves

    sumarr = zeros(UInt8,basesize)
    movesPerLoop::Int128 = 0
    cursorDelta::Int64 = 0
    if abs(cs.c) > 0
        xx = gcd(2^40,abs(cs.c))
        sumoffsets = zeros(UInt8,length(cs.deltaarr))
        for i in 1:xx
            s::UInt8 = sum([cs.deltaarr[x] for x in i:xx:length(cs.deltaarr)]) % 256
            for j in i:xx:length(cs.deltaarr); sumoffsets[j] = s; end
        end
        coffset = 1 - cs.wl
        for c in cursor:basesize
            sumarr[c] = sumoffsets[coffset]
            coffset += 1
            if coffset > length(cs.deltaarr); coffset -= xx; end;
        end
        coffset = 1 - cs.wl
        for c in cursor:-1:1
            sumarr[c] = sumoffsets[coffset]
            coffset -= 1
            if coffset < 1; coffset += xx; end;
        end
        cursorDelta = Int64(sumarr[cursor])
        movesPerLoop = Int128(2^40 ÷ xx) * cs.totmoves
    end
    #print(stderr,"\nDBG basearr:$basearr cursor:$cursor cs.wl:$(cs.wl) cs.wr:$(cs.wr) movesPerLoop:$movesPerLoop sumarr:$sumarr cursorDelta:$cursorDelta\n")

    best::Int128 = typemax(Int128)
    bestc::Int64 = 0
    bestarr::Vector{UInt8} = zeros(UInt8,basesize)

    ans::Int128 = 0
    lendelta = length(cs.deltaarr)
    hist::Vector{Tuple{Int64,Int64,Int128}} = Vector{Tuple{Int64,Int64,Int128}}()
    firstcursor = -1
    while true
        if cursor + cs.wr > basesize
            seg1 = basesize-(cursor+cs.wl)+1
            seg2 = lendelta - seg1
            basearr[cursor+cs.wl:end] += cs.deltaarr[1:seg1]
            basearr[1:seg2] += cs.deltaarr[seg1+1:end]
        elseif cursor + cs.wl < 1
            seg2 = cursor + cs.wr
            seg1 = lendelta - seg2
            basearr[basesize-seg1+1:end] += cs.deltaarr[1:seg1]
            basearr[1:cursor+cs.wr] += cs.deltaarr[seg1+1:end]
        else
            basearr[cursor+cs.wl:cursor+cs.wr] += cs.deltaarr
        end
        cursor += cs.c
        ans += cs.totmoves
        if cursor < 1; cursor += basesize; ans += wraparoundmoves; end
        if cursor > basesize; cursor -= basesize; ans += wraparoundmoves; end
        if basearr[cursor] == 0; return ans,cursor; end

        if cursor == firstcursor && cs.c != 0; basearr[1:end] = bestarr; return best,bestc; end
        if firstcursor < 0; firstcursor = cursor; end

        loops = prework[Int64(basearr[cursor])+1,cursorDelta+1]
        if loops > 0
            trial = ans + loops * movesPerLoop
            if trial < best
                best = trial; bestc = cursor; bestarr = basearr + UInt8(loops)*sumarr
            end
        end
    end
end

function doprework()::Array{Int64,2}
    prework = fill(-1,256,256)
    for i in 0:255
        for j in 0:255
            if i == 0
                prework[i+1,j+1] = 0
            elseif j == 0
                prework[i+1,j+1] = -1
            else
                for k in 1:256
                    if (i + k * j) % 256 == 0
                        prework[i+1,j+1] = k
                        break
                    end
                end 
            end
        end
    end
    return prework
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    prework::Array{Int64,2} = doprework()
    for qq in 1:tt
        print("Case #$qq: ")
        prog = readline(infile)
        ## Parse program into p1(p2)p3(p4)p5
        p1,p2,p3,p4,p5 = parseProg(prog)
        solveit(prework,p1,p2,p3,p4,p5)
    end
end

main()

