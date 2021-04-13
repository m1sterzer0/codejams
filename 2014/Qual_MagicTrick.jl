
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

function solve(ans1::I,board1::Array{I,2},ans2::I,board2::Array{I,2})::String
    s1::SI = SI(board1[ans1,:])
    s2::SI = SI(board2[ans2,:])
    s3 = intersect(s1,s2)
    if length(s3) == 0; return "Volunteer cheated!"
    elseif length(s3) > 1; return "Bad magician!"
    else; ans = [x for x in s3][1]; return string(ans)
    end
end

function main(infn="")
    global infile
    infile = (infn != "") ? open(infn,"r") : length(ARGS) > 0 ? open(ARGS[1],"r") : stdin
    tt::I = gi()
    for qq in 1:tt
        print("Case #$qq: ")
        board1::Array{I,2} = fill(0,4,4)
        board2::Array{I,2} = fill(0,4,4)
        ans1 = gi()
        for i in 1:4; board1[i,:] = gis(); end
        ans2 = gi()
        for i in 1:4; board2[i,:] = gis(); end
        ans = solve(ans1,board1,ans2,board2)
        print("$ans\n")
    end
end

Random.seed!(8675309)
main()
