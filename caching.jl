using SHA

outfile = "nbs.txt"
basedir = get(ENV, "DOCDIR", "docs") # Defaults to docs/
cachedir = joinpath(get(ENV, "NBCACHE", ".cache"), basedir) # Defaults to .cache/docs/
mkpath(cachedir)

nbs = String[]

# Collect the list of notebooks
# FIXME: why .sha files get overwritten?
for (root, dirs, files) in walkdir(basedir)
    # Create respective folders in the cache
    for dir in dirs
        mkpath(joinpath(cachedir, dir))
    end
    for file in files
        if endswith(file, ".ipynb")
            nb = joinpath(root, file)
            shaval = read(nb, String) |> sha256 |> bytes2hex
            @info "$(nb): SHA256=$(shaval)"
            shafilename = joinpath(cachedir, file * ".sha")
            # Cache hit
            if isfile(shafilename) && read(shafilename, String) == shaval
                @info "Notebook $(nb) cache hits and will not be executed."
            # Cache miss
            else
                write(shafilename, shaval)
                push!(nbs, nb)
            end
        end
    end
end

# Remove cached notebook and sha files if there is no respective notebook
# for (root, dirs, files) in walkdir(cachedir)
#     for file in files
#         if endswith(file, ".ipynb") || endswith(file, ".sha")
#             nb = joinpath(basedir, file)
#             if !isfile(nb)
#                 rm(joinpath(root, file))
#             end
#         end
#     end
# end

open(outfile, "w") do f
    for i in nbs
        println(f, i)
    end
end
