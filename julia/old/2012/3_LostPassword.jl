###############################################################################################
## Totally transcribed from the solutions
## The greedy solution was hard to see for sure, and min-cost-max-flow looked way too expensive
###############################################################################################

function main(infn="")
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    gs()::String = rstrip(readline(infile))
    gi()::Int64 = parse(Int64, gs())
    gf()::Float64 = parse(Float64,gs())
    gss()::Vector{String} = split(gs())
    gis()::Vector{Int64} = [parse(Int64,x) for x in gss()]
    gfs()::Vector{Float64} = [parse(Float64,x) for x in gss()]
    tt = parse(Int64,readline(infile))
    leet = Dict('o'=>'0','i'=>'1','e'=>'3','a'=>'4','s'=>'5','t'=>'7','b'=>'8','g'=>'9')
    for qq in 1:tt
        print("Case #$qq: ")
        k = gi()
        S = gs()
        craw::Set{String} = Set{String}()
        ls = length(S)
        for i in 1:ls-k+1; push!(craw,S[i:i+k-1]); end
        numcand = 0
        PP::Dict{String,Int64} = Dict{String,Int64}()
        SS::Dict{String,Int64} = Dict{String,Int64}()
        for cand in craw
            prefix = cand[1:k-1]
            suffix = cand[2:k]
            ic = count(x->x in "oieastbg",cand); candinc = 2^ic; numcand += candinc
            if haskey(PP,prefix); PP[prefix] += candinc; else; PP[prefix] = candinc; end
            if haskey(SS,suffix); SS[suffix] += candinc; else; SS[suffix] = candinc; end
        end
        x,i = 0,0
        while (true)
            myset = Set{String}()
            for pp in keys(PP); push!(myset,pp); end
            for ss in keys(SS)
                if ss ∉ myset; continue; end
                v = min(PP[ss],SS[ss])
                x += i*v
                PP[ss] -= v
                SS[ss] -= v
            end
            pkv = [(k,v) for (k,v) in PP]
            skv = [(k,v) for (k,v) in SS]
            empty!(PP)
            empty!(SS)
            for (pre,v) in pkv
                if v == 0; continue; end
                kk = pre[1:end-1]
                if !haskey(PP,kk); PP[kk] = v; else; PP[kk] += v; end
            end
            for (suf,v) in skv
                if v == 0; continue; end
                kk = suf[2:end]
                if !haskey(SS,kk); SS[kk] = v; else; SS[kk] += v; end
            end
            if length(PP) == 0 ; break; end
            i += 1
        end
        ## Can subtract off the last edge, but only if we added an edge
        ans = (k-1) + numcand + (x == 0 ? 0 : x-i)
        print("$ans\n")
    end
end

main()

