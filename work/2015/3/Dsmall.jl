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
    sort!(magnitudes)
    out = join(["$x " for x in magnitudes])[1:end-1]
    print("$out\n")
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
