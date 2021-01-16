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
######################################################################################################

function parseSegment(p)
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

function solve1(s)
    wmin1,wmax1,md1,deltaarr1,totmoves1 = parseSegment(s)
    return totmoves1
end

function solve2(s1,s2,s3)
    wmin1,wmax1,md1,deltaarr1::Vector{UInt8},totmoves1 = parseSegment(s1)
    wmin2,wmax2,md2,deltaarr2::Vector{UInt8},totmoves2 = parseSegment(s2)
    wmin3,wmax3,md3,deltaarr3::Vector{UInt8},totmoves3 = parseSegment(s3)
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

function solve3(s1,s2,s3,s4,s5)
    return 0
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        prog = readline(infile)
        ## Parse program into p1(p2)p3(p4)p5
        p1,p2,p3,p4,p5 = parseProg(prog)

        ans = 0
        if length(p2) == 0 && length(p4) == 0
            ans = solve1(p1*p3*p5)
        elseif length(p4) == 0
            ans = solve2(p1,p2,p3*p5)
        elseif length(p2) == 0
            ans = solve2(p1*p3,p4,p5)
        else
            ans = solve3(p1,p2,p3,p4,p5)
        end
        print("$ans\n")
    end
end

main()

