# FunctionalMotifs
Code to the paper "Functional Motifs in Foodwebs and Networks"

MotifFinder.jl
    The code of the module that uses interaction matrices to find a number of different motifs in food webs that have been associated with foodweb stability in previous studies and combinations of those motifs. 
    Those motifs are:
    
    2 species:
      predator-prey
      mutualism (in apparent competition motifs)
    
    3 species:
      apparent competition (two prey species that share the same predator)
      exploitative competition (two predator species that share the same prey)
      omnivory (one species eats both species in a predator-prey pair)
      tri-trophic foodchains
    
    4 species:
      four species foodchains
      bifan (combination of two exploitative competition motifs with the same predators)
      diamond (combination of apparent competition and exploitative competition motifs)
      combined tri-trophic foodchains (two tri-trophic chains that share the same top predator)

Reactivity.jl
    The code to a module that calculates the reactivity of a symmetric Jacobian and motifs of interest.

GeneralizedModel.jl
    Code to generate Jacobian matrices of stable systems based on a Generalized Foodweb Model.

ex_intmat.csv
    The interaction matrix of the example network. (i,j)th element = 1, if i eats j.
