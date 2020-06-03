import os
import shutil
destfiles = [
        "Qual/A.jl",
        "Qual/B.jl",
        "Qual/C.jl",
        "Qual/D.jl",
        "1A/A.jl",
        "1A/B.jl",
        "1A/C.jl",
        "1B/A.jl",
        "1B/B.jl",
        "1B/C.jl",
        "1C/A.jl",
        "1C/B.jl",
        "1C/A.jl",
        "2/A.jl",
        "2/B.jl",
        "2/C.jl",
        "2/D.jl",
        "3/A.jl",
        "3/B.jl",
        "3/C.jl",
        "3/D.jl",
        "WF/A.jl",
        "WF/B.jl",
        "WF/C.jl",
        "WF/D.jl",
        "WF/E.jl" ]

for f in destfiles :
    if os.path.exists(f) : continue
    shutil.copyfile("template.jl",f)



