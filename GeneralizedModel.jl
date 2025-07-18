module GeneralizedModel

using Distributions
using UUIDs
using LinearAlgebra
using StatsBase

export gen_J, assign_lifespans, determine_trophic_levels

# -------------------------------------------------------------------------------------------------------------------

"""
gen_J()

Function that generates a Jacobian matrix of a stable system based on a Generalized Foodweb Model (based on the model in 
Gross and Feudel 2006)
"""
function gen_J(A)
    N = size(A, 1);

    trophic_levels = determine_trophic_levels(A)

    lifespans = assign_lifespans(trophic_levels)

    # Create an empty Jacobian with the same size as the interaction matrix
    J = zeros(size(A));

    # Fill the entries in the Jacobian matrix using a generalized food web model 
    # (for more information about the model read Gross & Feudel 2006)

    α = 1.0 ./ lifespans

    while maximum(real(eigvals(J))) >= 0 
        ϕ = rand(Uniform(0.0, 1.0), N)
        ρ = 1 .* (sum(A, dims = 2) .!= 0)[:]   # Fix: Use Interactions instead of Interaction
        ρ_tilde = 1 .- ρ
        γ = rand(Uniform(0.5, 1.5), N)
        λ = ones(N, N)  
        ψ = rand(Uniform(0.5,1.5), N)
        σ = 1 .* (sum(A, dims = 1) .!= 0)[:]
        σ_tilde = 1 .- σ
        μ = rand(Uniform(1.0, 2.0), N)

        β = A ./ norm.(eachcol(A), 1)'  # creates NaN when divisor is 0
        χ = A ./ norm.(eachrow(A), 1)

        β[isnan.(β)] .= 0.0;
        χ[isnan.(χ)] .= 0.0;

        for i = 1:N # loop over rows
            for j = 1:N # loop over columns

                if i == j # intraspecific dynamic
                    J[i,j] = ρ_tilde[i] * ϕ[i] +                                     # primary production
                             ρ[i] * (γ[i] * χ[i,i] * λ[i,i] + ψ[i]) -                # predation gain
                             σ_tilde[i] * μ[i]                                       # natural mortality
                    for k = 1:N
                        J[i,j] -= σ[i] * β[k,i] * λ[k,i] * ((γ[k] - 1) * χ[k,i] + 1) # predation loss
                    end
                else      # interspecific dynamic
                    J[i,j] = 0

                    if χ[i,j] != 0
                        J[i,j] = ρ[i] * γ[i] * χ[i,j] * λ[i,j] 
                    end

                    if β[j,i] != 0
                        J[i,j] -= σ[i] * β[j,i] * ψ[j]
                    end
    
                    for k = 1:N
                        if (β[k,i] != 0) && (χ[k,j] != 0)
                            J[i,j] -= σ[i] * (β[k,i] * λ[k,j] * (γ[k] - 1) * χ[k,j])
                        end
                    end
                end
    
                J[i, j] *= α[i]
            end
        end
    end

    return J
end

# Assign lifespans based on trophic levels
function assign_lifespans(trophic_levels)
    base_lifespan = 1.0  # Lifespan for the basal trophic level
    lifespan_increment = 3.0  # Increment for each higher trophic level

    lifespans = base_lifespan .+ (trophic_levels .- 1) .* lifespan_increment
    return lifespans
end

# Determine the trophic level
function determine_trophic_levels(Interactions)
    # Number of species
    n = size(Interactions, 1)

    # Initialize trophic levels with ones
    trophic_levels = ones(Float64, n)

    # Iteratively update trophic levels until convergence
    max_iterations = 1000
    tolerance = 1e-6

    for _ in 1:max_iterations
        new_trophic_levels = ones(Float64, n)
        for i in 1:n
            prey_indices = findall(x -> x == 1, Interactions[i, :])
            if !isempty(prey_indices)
                new_trophic_levels[i] += mean(trophic_levels[prey_indices])
            end
        end
        
        # Check for convergence
        if norm(new_trophic_levels - trophic_levels) < tolerance
            break
        end
        
        trophic_levels = new_trophic_levels
    end
    
    return trophic_levels
end

end # end module
