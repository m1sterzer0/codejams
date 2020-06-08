######################################################################################################
### -- We first count up all of the chocolate chips and make sure they are divisible by (H+1) and (V+1)
### -- Next, we need create row-sums and col-sum of the chocolate chips in each row/col respectively.
###    We use this to determine where we must make our cuts.
### -- Finally, we check each piece and make sure that they have the right number of chips
######################################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        R,C,H,V = [parse(Int64,x) for x in split(rstrip(readline(infile)))]
        g = fill('.',R,C)
        for i in 1:R
            g[i,:] = [c for c in rstrip(readline(infile))]
        end
        nchips = count(x->x=='@',g)
        if nchips == 0; print("POSSIBLE\n"); continue; end
        if nchips % ((H+1)*(V+1)) != 0; print("IMPOSSIBLE\n"); continue; end
        chipsPerPiece = nchips ÷ ((H+1)*(V+1))
        chipsPerRow = chipsPerPiece * (V+1)
        chipsPerCol = chipsPerPiece * (H+1)
        rowChips = [count(x->x=='@',g[i,:]) for i in 1:R]
        colChips = [count(x->x=='@',g[:,j]) for j in 1:C]

        good = true
        hcuts = Vector{Int64}()
        vcuts = Vector{Int64}()
        running = 0
        for i in 1:R
            running += rowChips[i]
            if running > chipsPerRow; good = false; break; end
            if running == chipsPerRow; push!(hcuts,i); running=0; end
        end
        running = 0
        for j in 1:C
            running += colChips[j]
            if running > chipsPerCol; good = false; break; end
            if running == chipsPerCol; push!(vcuts,j); running=0; end
        end
        if length(hcuts) != H+1; good = false; end
        if length(vcuts) != V+1; good = false; end
        if !good; print("IMPOSSIBLE\n"); continue; end
        pop!(hcuts)  ## should always get one extra cut
        pop!(vcuts)

        for ii in 1:H+1
            for jj in 1:V+1
                t = ii == 1   ? 1 : hcuts[ii-1]+1
                b = ii == H+1 ? R : hcuts[ii]
                l = jj == 1   ? 1 : vcuts[jj-1]+1
                r = jj == V+1 ? C : vcuts[jj]
                nchips = count(x->x=='@',g[t:b,l:r])
                if nchips != chipsPerPiece; good = false; end
            end
        end
        print(good ? "POSSIBLE\n" : "IMPOSSIBLE\n")
    end
end

main()
