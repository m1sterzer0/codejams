using Printf

######################################################################################################
### BEGIN MAIN PROGRAM
######################################################################################################

function solveit(infile)
    P = parse(Int64,readline(infile))
    E = [parse(Int64,x) for x in split(readline(infile))]
    F = [parse(Int64,x) for x in split(readline(infile))]

    ## Calc number of elements of S
    Fsum = sum(F)
    N,Npset = 1,2
    while(Npset < Fsum); N += 1; Npset *= 2; end

    D = Dict{Int64,Int64}()
    for i in 1:P; D[E[i]] = F[i]; end
    EE = reverse(E)

    magnitudes = []
    idx1 = 1
    for i in 1:N
        while D[EE[idx1]] == 0
            idx1 += 1
        end
        idx2 = idx1
        while (D[EE[idx2]] == 0) || (idx1==idx2 && D[EE[idx1]]==1)
            idx2 += 1
        end
        mag = EE[idx1] - EE[idx2]
        for j in 1:length(EE)
            if D[EE[j]] == 0; continue; end
            if mag == 0
                D[EE[j]] ÷= 2
            else
                D[EE[j]-mag] -= D[EE[j]]
            end
        end
        push!(magnitudes,mag)
    end

    ## Now for the subset sum part
    ## This moves from NP-complete to tractable given that we have a short list of the allowable sums of powerset entries
    if EE[end] >= 0
        sort!(magnitudes)
        out = join(["$x " for x in magnitudes])[1:end-1]
        print("$out\n")
    elseif EE[1] <= 0
        mm = [-1*x for x in magnitudes]
        sort!(mm)
        out = join(["$x " for x in mm])[1:end-1]
        print("$out\n")
    else
        magnonzero = [x for x in magnitudes if x != 0]
        target = EE[1]
        sums = sort([x for x in Set([y for y in EE if y >=0])])
        sb = fill(Int8(0),length(magnonzero),length(sums))
        lookup = Dict{Int64,Int64}()
        for i in 1:length(sums); lookup[sums[i]] = i; end
        for i in 1:length(magnonzero)
            m = magnonzero[i]
            sb[i,1] = 1  ## Can always get zero
            if haskey(lookup,m); sb[i,lookup[m]] = 1; end
            if i == 1; continue; end
            for j in 1:length(sums)
                if sb[i-1,j] == 0; continue; end
                sb[i,j] = 1  ## Can always not use the current element
                if !haskey(lookup,sums[j]+m); continue; end
                sb[i,lookup[sums[j]+m]] = 1
            end
        end
        ## Now we have a scoreboard of which sums can be made from the N smallest non-zero magnitudes
        ## Now we make the positive target from the smallest magnitudes possible, leaving the larger magnitudes for negative numbers
        while target > 0
            j = lookup[target]
            for i in 1:length(magnonzero)
                if sb[i,j] == 1
                    target -= magnonzero[i]
                    magnonzero[i] *= -1
                    break
                end
            end
        end
        magnonzero = [-1*x for x in magnonzero]
        magneg = [x for x in magnonzero if x < 0]
        magzero = [x for x in magnitudes if x == 0]
        magpos = [x for x in magnonzero if x > 0]
        mm = vcat(sort(magneg),magzero,sort(magpos))
        out = join(["$x " for x in mm])[1:end-1]
        print("$out\n")
    end
end

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt = parse(Int64,readline(infile))
    for qq in 1:tt
        print("Case #$qq: ")
        solveit(infile)
    end
end

main()
