function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        A,B = [parse(BigInt,x) for x in split(rstrip(readline(infile)))]
        N,M = [parse(BigInt,x) for x in split(rstrip(readline(infile)))]
        V,W = [parse(BigInt,x) for x in split(rstrip(readline(infile)))]
        Y,X,Vy,Vx = [parse(BigInt,x) for x in split(rstrip(readline(infile)))]
        if Vy == 0 || Vx == 0; print("DRAW\n"); continue; end
        if Vy < 0; Y = A-Y; Vy = -Vy; end
        A *= Vx; Y *= Vx
        twoA = 2*A

        (curside::Char,curval::Int64) = Vx < 0 ? ('l',(Y+Vy*X) % twoA) : ('r', (Y+Vy*(B-X)) % twoA)
        leftrange = 2*V*B*N
        rightrange = 2*W*B*M
        ## Now to the simple sum
        lefthist::Vector{Int64} = []
        righthist::Vector{Int64} = []
        state::Set{Tuple{Char,Int64}} = Set{Tuple{Char,Int64}}()
        while true
            #print("DBG: ($curside,$curval)\n")
            if (curside,curval) in state; print("DRAW\n"); break; end
            push!(state,(curside,curval))
            (range::Int64,hist::Vector{Int64},nump::Int64) = curside == 'l' ? (leftrange,lefthist,N) : (rightrange,righthist,M)
            loc = curval <= A ? curval : twoA-curval
            push!(hist,loc)
            lastloc = length(hist) <= nump ? -1 : hist[end-nump]
            gap = length(hist) <= nump ? -1 : abs(hist[end]-hist[end-nump])
            #print("DBG: ($curside,$curval) nump:$nump loc:$loc histloc:$lastloc gap:$gap range:$range\n")
            if length(hist) > nump && abs(hist[end]-hist[end-nump]) > range
                side = curside == 'l' ? "RIGHT" : "LEFT"
                print("$side $(length(hist)-1)\n")
                break
            end
            (curside,curval) = (curside == 'l' ? 'r' : 'l', (curval + B*Vy)%twoA)
        end
    end
end

main()

