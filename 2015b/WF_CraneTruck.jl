
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

mutable struct craneSegment
    wl::I; wr::I; c::I; deltaarr::Vector{UInt8}; totmoves::I
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

function parseSegmentSmall(p)
    if length(p) == 0; return 0,0,0,[],0; end
    deltaarr = zeros(UInt8,1+2*length(p))
    startloc = length(p)+1
    wl,wr,c,totmoves = 0,0,0,0
    for cc in p
        if     cc == 'b'; c -= 1; wl=min(wl,c); totmoves += 1
        elseif cc == 'f'; c += 1; wr=max(wr,c); totmoves += 1
        elseif cc == 'u'; deltaarr[startloc+c] += UInt8(255)
        elseif cc == 'd'; deltaarr[startloc+c] += UInt8(1)
        end
    end
    return wl,wr,c,deltaarr[startloc+wl:startloc+wr],totmoves
end

function solveSmall(prog::String)::I
    p1,p2,p3,p4,p5 = parseProg(prog)
    if length(p2) == 0 && length(p4) == 0; return solve1Small(p1*p3*p5)
    elseif length(p4) == 0; return solve2Small(p1,p2,p3*p5)
    elseif length(p2) == 0; return solve2Small(p1*p3,p4,p5)
    else; return 0
    end
end

function parseSegmentLarge(p)::craneSegment
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

function dosim(prework,p1,p2,p3,p4,p5,left,right)::Int128
    cs1,cs2,cs3,cs4,cs5 = [parseSegmentLarge(x) for x in [p1,p2,p3,p4,p5]]
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

function sizebase(p1,p2,p3,p4,p5)
    cs1,cs2,cs3,cs4,cs5 = [parseSegmentLarge(x) for x in [p1,p2,p3,p4,p5]]
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

function solveLarge(prog::String,prework)::I
    p1,p2,p3,p4,p5 = parseProg(prog)
    left,right = sizebase(p1,p2,p3,p4,p5)          ## First pass to find the size of the non-base
    return dosim(prework,p1,p2,p3,p4,p5,left,right) ## Second pass to do the simulation
end

function solve1Small(s)
    wmin1,wmax1,md1,deltaarr1,totmoves1 = parseSegmentSmall(s)
    return totmoves1
end

function solve2Small(s1,s2,s3)
    wmin1,wmax1,md1,deltaarr1::Vector{UInt8},totmoves1 = parseSegmentSmall(s1)
    wmin2,wmax2,md2,deltaarr2::Vector{UInt8},totmoves2 = parseSegmentSmall(s2)
    wmin3,wmax3,md3,deltaarr3::Vector{UInt8},totmoves3 = parseSegmentSmall(s3)
    ans::Int128 = totmoves1 + totmoves3

    wsize2 = wmax2-wmin2+1
    basemin = wmin1 - 2*wsize2
    basemax = wmax1 + 2*wsize2
    basesize = basemax-basemin+1
    nonbasesize = md2 == 0 ? (2^40-basesize) : ((2^40 - basesize) ÷ abs(md2)) * abs(md2)
    nonbaseiter = md2 == 0 ? (2^40-basesize) : nonbasesize ÷ abs(md2)
    residual = 2^40 - nonbasesize - basesize
    basesize += residual
    basemax += residual
    wraparoundmoves = totmoves2*nonbaseiter

    basearr::Vector{UInt8} = zeros(UInt8,basesize)
    cursor = 1 - basemin
    if length(deltaarr1) > 0
        basearr[cursor+wmin1:cursor+wmax1] += deltaarr1
        cursor += md1
    end

    while true
        if cursor + wmax2 > basesize
            seg1 = basesize-cursor-wmin2+1
            seg2 = length(deltaarr2) - seg1
            basearr[cursor+wmin2:basesize] += deltaarr2[1:seg1]
            basearr[1:seg2] += deltaarr2[seg1+1:end]
        elseif cursor + wmin2 < 1
            seg2 = cursor+wmax2
            seg1 = length(deltaarr2) - seg2
            basearr[basesize-seg1+1:basesize] += deltaarr2[1:seg1]
            basearr[1:cursor+wmax2] += deltaarr2[seg1+1:end]
        else
            basearr[cursor+wmin2:cursor+wmax2] += deltaarr2
        end
        cursor += md2
        ans += totmoves2
        if cursor < 1; cursor += basesize; ans += wraparoundmoves; end
        if cursor > basesize; cursor -= basesize; ans += wraparoundmoves; end
        if basearr[cursor] == 0; break; end
    end
    return ans
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
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    prework::Array{I,2} = doprework()
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        prog = gs()
        #ans = solveSmall(prog)
        ans = solveLarge(prog,prework)
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

