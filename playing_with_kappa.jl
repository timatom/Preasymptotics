using SpecialFunctions
using Random
using Distributions
using Statistics
using Plots

#########################################################################################################################
# Setting up the plot formatting for the plots below.                                                                   #
#########################################################################################################################

# Define tick marks and labels, removing the tick at 0.0
xticks = 0.1:0.1:3
yticks = 0.05:0.05:1.0 # Adjusted to end at 1.0

xlabels = 0.5:0.5:3
ylabels = 0.2:0.2:1.0 # Adjusted to end at 1.0

# Custom tick settings
xtick_labels = [i in xlabels ? string(i) : "" for i in xticks]
ytick_labels = [i in ylabels ? string(i) : "" for i in yticks]

#########################################################################################################################
# Exploring the relationship between κ₁ and ρ using the closed-form expression of κ₁ (n=2) for lognormal distributions. #
#########################################################################################################################

# Define the range for ρ
rho_values = 0:0.01:3

# Calculate κ₁ for each ρ
kappa_1_values = [2 - log(2) / log(2 * erf(sqrt(log(0.5 * (exp(rho^2) + 1))) / (2 * sqrt(2))) / erf(rho / (2 * sqrt(2)))) for rho in rho_values]

# Plotting with axes intersecting at 0 and no label
plot(rho_values, kappa_1_values, xlabel="ρ", ylabel="κ₁", title="κ₁ vs. ρ", grid=true,

xticks=(xticks, xtick_labels), yticks=(yticks, ytick_labels),
xlims=(0, 3), ylims=(0, 1), label="")

#########################################################################################################################
# Exploring the relationship between κ₁ and ρ using numerical calculations of κ₁ (n=2) for lognormal distributions.     #
#########################################################################################################################

# Define the number of sets and the number of observations per set
n = 2 # Number of sets
num_observations = 400000 # Observations per set

# Define the mean of the underlying normal distribution
μ = 1.0 # Mean

# Define the range of rho values
rho_values = 0:0.05:3
kappa_values = Float64[]

# Iterate over each rho value
for ρ in rho_values
	σ = ρ # Standard deviation changes with rho

	# Generate the lognormal data for n sets
	lognormal_data = [rand(LogNormal(μ, σ), num_observations) for _ in 1:n]

	# Calculate the summands S_n
	S_n = [sum(lognormal_data[i][j] for i in 1:n) for j in 1:num_observations]

	# Calculate the mean of S_n
	mean_S_n = mean(S_n)

	# Calculate the absolute deviations from the mean
	absolute_deviations = abs.(S_n .- mean_S_n)

	# Calculate the mean absolute deviation (MAD)
	MAD_n = mean(absolute_deviations)

	# Calculate MAD for n = 1 (M_n0)
	lognormal_data_n0 = rand(LogNormal(μ, σ), num_observations)
	mean_S_n0 = mean(lognormal_data_n0)
	absolute_deviations_n0 = abs.(lognormal_data_n0 .- mean_S_n0)
	MAD_n0 = mean(absolute_deviations_n0)

	# Calculate the kappa metric
	kappa = 2 - (log(n)) / log(MAD_n / MAD_n0)

	# Store the kappa value for the current rho
	push!(kappa_values, kappa)
end

# Plot kappa vs. rho with custom formatting
plot(rho_values, kappa_values, xlabel="ρ", ylabel="κ₁", title="κ₁ vs. ρ", grid=true,
     xticks=(xticks, xtick_labels), yticks=(yticks, ytick_labels),
     xlims=(0, 3), ylims=(0, 1), label="", legend=:topright)