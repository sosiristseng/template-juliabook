#===
# Plotting with PythonPlot.jl

Using Literate.jl
===#
import PythonPlot as plt
using Random
Random.seed!(2022)

#---
plt.figure()
plt.plot(1:5, rand(1:6, 5))
plt.gcf()
