using SHA

outfile = "nbs.txt"
basedir = get(ENV, "DOCDIR", "docs") # Defaults to docs/
cachedir = get(ENV, "NBCACHE", ".cache") # Defaults to .cache/
nbs = String[]

# Collect the list of notebooks
for (root, dirs, files) in walkdir(basedir)
    for file in files
        if endswith(file, ".ipynb")
            nb = joinpath(root, file)
            shaval = read(nb, String) |> sha256 |> bytes2hex
            @info "Notebook $(nb): hash=$(shaval)"
            shafilename = joinpath(cachedir, root, splitext(file)[1] * ".sha")
            # Cache hit
            if isfile(shafilename) && read(shafilename, String) == shaval
                @info "Notebook $(nb) cache hits and will not be executed."
            # Cache miss
            else
                @info "Notebook $(nb) cache misses. Writing hash to $(shafilename)."
                mkpath(dirname(shafilename))
                write(shafilename, shaval)
                push!(nbs, nb)
            end
        end
    end
end

# Remove cached notebook and sha files if there is no respective notebook
for (root, dirs, files) in walkdir(cachedir)
    for file in files
        if endswith(file, ".ipynb") || endswith(file, ".sha")
            nb = joinpath(joinpath(splitpath(root)[2:end]), splitext(file)[1] * ".ipynb")
            if !isfile(nb)
                fullfn = joinpath(root, file)
                @info "Notebook $(nb) not found. Removing $(fullfn)."
                rm(fullfn)
            end
        end
    end
end

# Write the list of notebooks to be executed
open(outfile, "w") do f
    for i in nbs
        println(f, i)
    end
end
