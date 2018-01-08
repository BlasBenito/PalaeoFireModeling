;;AUTHORS
;;Graciela Gil-Romera, Blas M. Benito

;;LOADING EXTENSIONS
;;##################
extensions [gis]


;;################
;;GLOBAL VARIABLES
;;################
globals
[
  ;landscape globals
  landscape-area ;extension and resolution of the landscape coming from a GIS map
  environmental-stochasticity-changed ;1 if stochasticity changed, 0 otherwise

  ;fire globals
  ;Fire-probability-per-year ;constant equal to 1/resolution of fire data, around 1/18
  fire-charcoal-this-year ;charcoal accumulation rate (was converted to [0, 1])
  ;fire-ignitions-amplification-factor ; constant to increment or diminish the amount of ignitions given by the charcoal data
  ;fire-this-year? ;result of the random test to decide if there is fire this year or not
  fire-ignitions-this-year ;number of ignitions, coming from the expression fire-charcoal-this-year * fire-ignitions-amplification-factor

  ;age globals
  age-first   ;oldest date of time-series-age
  age-last    ;more recent date of time-series-age
  age-range   ;years between age-first and age-last
  age-current ;current year

  ;time series
  time-series-temperature-minimum-average  ;TraCe temperature data
  time-series-age  ;TraCe age data
  time-series-fire ;real charcoal accumulation rate

  ;;defines the patches within the relevant source area of pollen (RSAP), that can be modified with the slider RSAP-radius
  RSAP-area

  ;counts the iterations happening during burn-in
  Burn-in-counter

  ;agentset of patches in the limits of the study area. This agentset is used to regenerate species that become locally extinct during the simulation
  region-limits

  ;output temperature
  output-temperature-minimum-average

  ;output pollen
  output-pollen-vegetation-species-A
  output-pollen-vegetation-species-B
  output-pollen-vegetation-species-C
  output-pollen-vegetation-species-D
  output-pollen-vegetation-species-E

  ;output charcoal
  output-charcoal-vegetation-species-A
  output-charcoal-vegetation-species-B
  output-charcoal-vegetation-species-C
  output-charcoal-vegetation-species-D
  output-charcoal-vegetation-species-E
  output-charcoal-vegetation-sum

  ;output biomass
  output-biomass-vegetation-species-A
  output-biomass-vegetation-species-B
  output-biomass-vegetation-species-C
  output-biomass-vegetation-species-D
  output-biomass-vegetation-species-E
  output-biomass-vegetation-sum

  ;output life-stage
  output-seeds-vegetation-species-A
  output-seeds-vegetation-species-B
  output-seeds-vegetation-species-C
  output-seeds-vegetation-species-D
  output-seeds-vegetation-species-E

  output-seedlings-vegetation-species-A
  output-seedlings-vegetation-species-B
  output-seedlings-vegetation-species-C
  output-seedlings-vegetation-species-D
  output-seedlings-vegetation-species-E

  output-adults-vegetation-species-A
  output-adults-vegetation-species-B
  output-adults-vegetation-species-C
  output-adults-vegetation-species-D
  output-adults-vegetation-species-E

  ;monitored patch and individuals
  monitored-patch
  monitored-turtles

 ;growth parameters
 interaction-term
 current-growth-rate

]



;;###############
;;PATCH VARIABLES
;;###############
patches-own
[
  ;topographic features
  landscape-slope
  landscape-elevation
  landscape-topography
  landscape-aspect
  landscape-northness

  ;maps to correct TraCe temperature data
  correction-map-temperature-minimum-average

  ;temperature data
  landscape-temperature-minimum-average

  ;random number for binomial trials
  landscape-random

  ;biomass per patch
  landscape-current-biomass

]



;;###############
;;BREEDS VARIABLES
;;###############
breed [vegetation-species-As vegetation-species-A]
breed [vegetation-species-Bs vegetation-species-B]
breed [vegetation-species-Cs vegetation-species-C]
breed [vegetation-species-Ds vegetation-species-D]
breed [vegetation-species-Es vegetation-species-E]



;;################
;;TURTLE VARIABLES
;;################
turtles-own
[
  vegetation-species

  ;biological traits
  vegetation-traits-current-age
  vegetation-traits-maximum-age ;senescence age.
  vegetation-traits-sexual-maturity-age
  vegetation-traits-dispersal-distance ;in number of patches
  vegetation-traits-pollen-productivity ;a number in the range [0, 1]
  vegetation-traits-current-pollen-production ;computed as vegetation-traits-pollen-productivity * vegetation-traits-current-biomass
  vegetation-traits-current-biomass ;relative measure of biomass
  vegetation-traits-growth-rate
  vegetation-traits-maximum-biomass
  vegetation-traits-heliophilia ;level of heliophilia between 0.5 and 1
  vegetation-traits-seedling-tolerance ;maximum number of years tolerating unsuitable conditions for a seedling
  vegetation-traits-adult-tolerance ;maximum number of years tolerating unsuitable conditions for an adult
  vegetation-traits-seedling-mortality ;frequency of random mortality in seedlings (simulating herbivory)
  vegetation-traits-adult-mortality ;frequency of random mortality in seedlings (simulating pests)
  vegetation-life-stage ;qualitative status of life stage

  ;environmental limits
  vegetation-niche-min-temperature-minimum-average
  vegetation-niche-max-temperature-minimum-average
  vegetation-niche-min-slope
  vegetation-niche-max-slope

  ;glm coefficients to compute habitat suitability
  vegetation-glm-coef-intercept
  vegetation-glm-coef-temperature-minimum-average
  vegetation-glm-habitat-suitability

  ;checking if habitat is suitable or not
  vegetation-is-habitat-suitable? ;1 if suitable, 0 if not.
  vegetation-years-with-unsuitable-habitat ;number of years with unsuitable habitat

  ;fire
  vegetation-burnt-this-year? ;1 if the individual was burned, 0 otherwise.
  vegetation-resprouts-after-fire? ;1 if it does, 0 otherwise
  vegetation-resprouted? ;1 if the plant resprouted after fire, 0 otherwise

  ;decay
  vegetation-decay? ;1 if the plant dies due to maximum age or other sources of mortality (but fire), 0 otherwise

  ;graphics
  vegetation-graphics-color
  vegetation-graphics-shape
  vegetation-graphics-size-seed
  vegetation-graphics-size-seedling
  vegetation-graphics-size-adult
]



;;##################################################
;;##################################################
;;SETUP SIMULATION
;;##################################################
;;##################################################
to simulation-setup

  ;cleaning the landscape
  clear-all

  ;reset ticks to 0
  reset-ticks

  ;setting random seed
  if Randomness-settings = "Free seed, non-deterministic results" [random-seed random 2147483647]
  if Randomness-settings = "Fixed seed, deterministic results" [random-seed 10000]

  ;exporting interface (to have a record of the parameters used)
  export-interface word Output-path "/model_fire2_v12_configuration.png"

  ;LOADING GIS DATA
  input-load-gis-data

  ;LOADING TIME SERIES
  input-load-time-series-age
  input-load-time-series-temperature
  input-load-time-series-fire

  ;TIME VARIABLES
  set age-range length time-series-age
  set age-first item 0 time-series-age
  set age-last (age-first + age-range - 1) ;-1 because the count starts in 0
  set age-current age-first

  ;COMPUTING TEMPERATURE
  abiotic-compute-temperature

  ;DEFINES THE AGENTSET OF PATCHES IN THE BORDERS OF THE STUDY AREA USED TO REGENERATE SPECIES PRESENCE AFTER LOCAL EXTINCTION
  set region-limits no-patches
  ask patches with [pycor >= -1 or pycor <= -110][set region-limits (patch-set region-limits self)]

  ;SETTING SOME LANDSCAPE VALUES
  ask patches
  [
    ;random values for binomial trials
    set landscape-random random-float 1

    ;setting biomass related values
    set landscape-current-biomass 0
  ]

  ;setting up "relevant source area of pollen" and coring-site
  ask patch 78 -54 [set pcolor blue set RSAP-area patches in-radius RSAP-radius]
  ask RSAP-area [set pcolor gray - 2]

  ;generating output file
  output-create-file

  ;GENERATING INITIAL SPECIES POPULATIONS WITH AVERAGE TRAITS
  ask patches
  [
    if P.sylvestris? [biotic-generate-species-A]
    if P.uncinata? [biotic-generate-species-B]
    if B.pendula? [biotic-generate-species-C]
    if Q.petraea? [biotic-generate-species-D]
    if C.avellana? [biotic-generate-species-E]
    ]

  ;PLOT TURTLES
  output-plot-turtles

  ;DEFINES A MONITORED PATCH AND SELECTS THE TURTLES ON IT
  set monitored-patch (patch-set patch monitored-x monitored-y)
  ask monitored-patch [set pcolor white]

  ;BURN-IN (initiates population dynamics under the initial climatic conditions)
  set Burn-in-counter 0
  while [Burn-in-counter < Burn-in-iterations]
  [
    ;controlling iterations
    set Burn-in-counter (Burn-in-counter + 1)

    ;CHANGING ENVIRONMENTAL STOCHASTICITY (only every ten years)
    abiotic-environmental-stochasticity

    ;COMPUTE HABITAT SUITABILITY (we have to use "ask turtles" because biotic-compute-habitat-suitability was designed for single turtles)
    ask turtles [biotic-compute-habitat-suitability]

    ;SIMULATE POPULATION DYNAMICS
    biotic-population-dynamics

    ;SIMULATING SEED DISPERSAL
    biotic-seed-dispersal

    ;LIMITING EDGE EFFECT
    biotic-regenerate-from-edges

    ;plot turtles
    output-plot-turtles

    ;CAPTURE PROXY DATA
    output-capture-proxy-data

    ;couting ticks
    tick

    ]

  ;reset ticks
  reset-ticks

end


;;##################################################
;;##################################################
;;RUN THE MODEL
;;##################################################
;;##################################################
to simulation-run

  ;AGE
  set age-current item ticks time-series-age

  ;COMPUTING TEMPERATURE
  abiotic-compute-temperature

  ;DRAWING TERRAIN
  output-draw-topography

  ;CHANGING ENVIRONMENTAL STOCHASTICITY (every ~ten years)
  abiotic-environmental-stochasticity

  ;LIMITING EDGE EFFECT
  biotic-regenerate-from-edges

  ;COMPUTE HABITAT SUITABILITY (we have to use "ask turtles" because biotic-compute-habitat-suitability was designed for single turtles)
  ask turtles [biotic-compute-habitat-suitability]

  ;SIMULATE POPULATION DYNAMICS
  biotic-population-dynamics

  ;SIMULATING SEED DISPERSAL
  biotic-seed-dispersal

  ;plot turtles
  output-plot-turtles

  ;FIRE
  abiotic-fire

  ;SNAPSHOT
  output-snapshots

  ;CAPTURE PROXY DATA
  output-capture-proxy-data

  ;WRITE THE DATA TO A FILE
  output-write-file

  ;POST FIRE RESPONSE
  biotic-post-fire-response

  ;UPDATES MONITORED TURTLES
  ask monitored-patch [set pcolor white]
  set monitored-turtles turtles-on monitored-patch

  ;END SIMULATION
  if age-current = age-last
  [
    export-interface word Output-path "/model_fire_final.png"
    stop
    ]

  ;couting ticks
  tick
end



;;##################################################
;;##################################################
;;ABIOTIC PROCEDURES
;;##################################################
;;##################################################


;;########################
;;COMPUTE TEMPERATURE MAPS
;;########################
to abiotic-compute-temperature

  ;applies correction map to the TraCe temperature time series to obtain a temperature map
  ask patches [set landscape-temperature-minimum-average item ticks time-series-temperature-minimum-average + correction-map-temperature-minimum-average]

end


;;##################################
;;CHANGE ENVIRONMENTAL STOCHASTICITY
;;##################################
;it generates a random number in [0, 1] for the patch to be compared with the habitat suitability for the individual.
;the random number changes every ~10 years following a random walk.
to abiotic-environmental-stochasticity

   ;only changes environmental stochasticity around every 10 years or more
   ifelse random 100 < random 10

   ;the value landscape-random is updated
   [
     ;confirming that the pattern has changed in the plot
     set environmental-stochasticity-changed -10

     ;changing the pattern of spatial stochasticity
     ask patches
     [
     ;changes the pattern but using the previous value as reference
     set landscape-random random-normal landscape-random 0.01

     ;making sure the number is not going out of bounds
     if landscape-random > 1 [set landscape-random 1]
     if landscape-random < 0 [set landscape-random 0]
     ]
   ]

   ;environmental stochasticity doesn't change (applying -15 to avoid plotting it)
   [set environmental-stochasticity-changed -15]

end


;;######################
;;IGNITE AND SPREAD FIRE
;;######################
to abiotic-fire

   ;COMPUTING NUMBER OF IGNITIONS
   ifelse Fire?

   ;FIRE INTERRUPTOR ACTIVE
   [
     ;reads fire data
     set fire-charcoal-this-year item ticks time-series-fire

     ;DECIDING IF THERE IS GOING TO BE FIRE THIS YEAR
     ifelse random-float 1 < Fire-probability-per-year

       ;FIRE THIS YEAR
       [
         ;convert into number of ignitions
         set fire-ignitions-this-year round (fire-charcoal-this-year * Fire-ignitions-amplification-factor)

         ;basal fire rate during the hiatus
         if age-current > -12500 and age-current < -9800 [set fire-ignitions-this-year 1]

         ;basal fire rate when there is no charcoal data (JUST AN EXPERIMENT TO LIMIT THE GROWHT OF BIOMASS AT THE END OF THE SIMULATION)
         if age-current > -7650 and age-current < -5702 [set fire-ignitions-this-year 1]

         ]

       ;NO FIRE THIS YEAR
       [set fire-ignitions-this-year 0]

     ]

   ;FIRE INTERRUPTOR NOT ACTIVE
   [set fire-ignitions-this-year 0]


  ;FIRE IGNITION AND SPREAD
  ;CANDIDATES FOR IGNITION: NON-BURNT ADULTS
  let fire-candidates-for-ignition turtles with [vegetation-life-stage = "adult"]

    ;checks the size of fire-candidates-for-ignition, and uses its count as fire-ignitions-this-year if required
    if fire-ignitions-this-year > count fire-candidates-for-ignition [set fire-ignitions-this-year count fire-candidates-for-ignition]

    ;selects a random turtle to start the fire
    ask n-of fire-ignitions-this-year fire-candidates-for-ignition
    [
      ;defines the selected turtles as a fire-front
      let fire-front turtle-set self ;; a new fire-front

      ;spread fire while there are fire fronts
      while [any? fire-front]
      [
        ;defines an empty agentset (is a local variable) to store the patches that will be fire fronts
        let fire-new-fire-front turtle-set nobody

        ;spreads fire from the fire front
        ask fire-front
        [

            ask turtles-here
            [
            set pcolor red
            set vegetation-burnt-this-year? 1
              ]

          ;creates the agentset fire-neighbors-of-fire-front with the neighbors of the current fire front that are not seeds, haven't been already burnt this year, and have a random number [0, 100] > than 10 of this patch
          let fire-neighbors-of-fire-front turtles in-radius 1 with
          [
            vegetation-burnt-this-year? = 0
            and vegetation-life-stage = "adult"                 ;adults, because they have more biomass
            and random-float 1 > landscape-northness            ;preference to south faced hills
            ]

          ;spread fire to the selected number of ignited neighbors
          ask fire-neighbors-of-fire-front
          [
            ;extends the patches of the agentset new-fire-front  with the patches of eighbors-of-fire-front
            set fire-new-fire-front (turtle-set fire-new-fire-front self)

            ;configure variables for burnt turtles and patches
            ask turtles-here
            [
            set pcolor red
            set vegetation-burnt-this-year? 1
              ]

            ] ;end of ask fire-neighbors-of-fire-front

            ;the new fire-front
            set fire-front fire-new-fire-front

          ] ;end of ask fire-front

        ] ;end of while clause

      ] ;end of ask n-of fire-ignitions-this-year

end





;;##################################################
;;##################################################
;;BIOTIC PROCEDURES
;;##################################################
;;##################################################



;;##################################################
;;CREATING SPECIES
;;##################################################

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;species A
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to biotic-generate-species-A

  sprout-vegetation-species-As 1
  [
  set vegetation-species "Pinus sylvestris"

  ;graphics
  set vegetation-graphics-color green + 2
  set vegetation-graphics-shape "circle"
  set vegetation-graphics-size-seed 0.1
  set vegetation-graphics-size-seedling 0.6
  set vegetation-graphics-size-adult 1

  ;biological traits
  set vegetation-traits-maximum-age round random-normal Ps-max-age 10
  set vegetation-traits-current-age 0.1
  set vegetation-traits-sexual-maturity-age round random-normal Ps-maturity-age 2
  set vegetation-traits-dispersal-distance 1
  set vegetation-traits-pollen-productivity Ps-pollen-productivity
  set vegetation-traits-growth-rate Ps-growth-rate
  set vegetation-traits-maximum-biomass Ps-max-biomass
  set vegetation-traits-current-biomass 1
  set vegetation-traits-current-pollen-production 0
  set vegetation-traits-heliophilia Ps-heliophilia
  set vegetation-traits-seedling-tolerance Ps-seedling-tolerance
  set vegetation-traits-adult-tolerance Ps-adult-tolerance
  set vegetation-life-stage "seed"

  ;MORTALITY: we transform the probability of transition between life stages into an annual probability of death
  set vegetation-traits-seedling-mortality Ps-seedling-mortality ;(Ps-seedling-mortality / Ps-maturity-age)
  set vegetation-traits-adult-mortality Ps-adult-mortality ;(Ps-adult-mortality / (Ps-max-age - Ps-maturity-age))

  ;PERCENTILE 05 and 95
  set vegetation-niche-min-temperature-minimum-average -4.6
  set vegetation-niche-max-temperature-minimum-average 6.8
  set vegetation-niche-min-slope 4.2
  set vegetation-niche-max-slope 31.4

  ;coefficients of glm equation to compute habitat suitability
  set vegetation-glm-coef-intercept 2.02131
  set vegetation-glm-coef-temperature-minimum-average 0.36198

  ;perturbation variables
  set vegetation-years-with-unsuitable-habitat 0
  set vegetation-burnt-this-year? 0
  set vegetation-resprouts-after-fire? Ps-resprout-after-fire
  set vegetation-resprouted? 0
  set vegetation-decay? 0

  ;kills the agent if the habitat is unsuitable
  biotic-compute-habitat-suitability
  if vegetation-is-habitat-suitable? = 0 [die]
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;species B
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to biotic-generate-species-B

  sprout-vegetation-species-Bs 1
  [
  set vegetation-species "Pinus uncinata"

  ;graphics
  set vegetation-graphics-color green - 1
  set vegetation-graphics-shape "circle"
  set vegetation-graphics-size-seed 0.1
  set vegetation-graphics-size-seedling 0.5
  set vegetation-graphics-size-adult 0.9

  ;biological traits
  set vegetation-traits-maximum-age round random-normal Pu-max-age 10
  set vegetation-traits-current-age 0.1
  set vegetation-traits-sexual-maturity-age round random-normal Pu-maturity-age 2
  set vegetation-traits-dispersal-distance 1
  set vegetation-traits-pollen-productivity Pu-pollen-productivity
  set vegetation-traits-growth-rate Pu-growth-rate
  set vegetation-traits-maximum-biomass Pu-max-biomass
  set vegetation-traits-current-biomass 1
  set vegetation-traits-current-pollen-production 0
  set vegetation-traits-heliophilia Pu-heliophilia
  set vegetation-traits-seedling-tolerance Pu-seedling-tolerance
  set vegetation-traits-adult-tolerance Pu-adult-tolerance
  set vegetation-life-stage "seed"

  ;MORTALITY: we transform the probability of transition between life stages into an annual probability of death
  set vegetation-traits-seedling-mortality Pu-seedling-mortality ; (Pu-seedling-mortality / Pu-maturity-age)
  set vegetation-traits-adult-mortality  Pu-adult-mortality ;(Pu-adult-mortality / (Pu-max-age - Pu-maturity-age))

  ;PERCENTILE 05 and 95
  set vegetation-niche-min-temperature-minimum-average -1.1
  set vegetation-niche-max-temperature-minimum-average 7.4
  set vegetation-niche-min-slope 7.1
  set vegetation-niche-max-slope 36.5

  ;coefficients of glm equation to compute habitat suitability
  set vegetation-glm-coef-intercept 0.26950
  set vegetation-glm-coef-temperature-minimum-average 0.61790

  ;perturbation variables
  set vegetation-years-with-unsuitable-habitat 0
  set vegetation-burnt-this-year? 0
  set vegetation-resprouts-after-fire? Pu-resprout-after-fire
  set vegetation-resprouted? 0
  set vegetation-decay? 0

  ;kills the agent if the habitat is unsuitable
  biotic-compute-habitat-suitability
  if vegetation-is-habitat-suitable? = 0 [die]
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;species C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to biotic-generate-species-C

  sprout-vegetation-species-Cs 1
  [
  set vegetation-species "Betula pendula"

  ;graphics
  set vegetation-graphics-color yellow - 1
  set vegetation-graphics-shape "circle"
  set vegetation-graphics-size-seed 0.1
  set vegetation-graphics-size-seedling 0.4
  set vegetation-graphics-size-adult 0.8

  ;biological traits
  set vegetation-traits-maximum-age round random-normal Bp-max-age 10
  set vegetation-traits-current-age 0.1
  set vegetation-traits-sexual-maturity-age round random-normal Bp-maturity-age 2
  set vegetation-traits-dispersal-distance 2
  set vegetation-traits-pollen-productivity Bp-pollen-productivity
  set vegetation-traits-growth-rate Bp-growth-rate
  set vegetation-traits-maximum-biomass Bp-max-biomass
  set vegetation-traits-current-biomass 1
  set vegetation-traits-current-pollen-production 0
  set vegetation-traits-heliophilia Bp-heliophilia
  set vegetation-traits-seedling-tolerance Bp-seedling-tolerance
  set vegetation-traits-adult-tolerance Bp-adult-tolerance
  set vegetation-life-stage "seed"
  ;MORTALITY: we transform the probability of transition between life stages into an annual probability of death
  set vegetation-traits-seedling-mortality Bp-seedling-mortality ;(Bp-seedling-mortality / Bp-maturity-age)
  set vegetation-traits-adult-mortality Bp-adult-mortality ;(Bp-adult-mortality / (Bp-max-age - Bp-maturity-age))

  ;PERCENTILE 05 and 95
  set vegetation-niche-min-temperature-minimum-average -2.8
  set vegetation-niche-max-temperature-minimum-average 7
  set vegetation-niche-min-slope 6.5
  set vegetation-niche-max-slope 37.9

  ;coefficients of glm equation to compute habitat suitability
  set vegetation-glm-coef-intercept 0.71627
  set vegetation-glm-coef-temperature-minimum-average 0.2730

  ;perturbation variables
  set vegetation-years-with-unsuitable-habitat 0
  set vegetation-burnt-this-year? 0
  set vegetation-resprouts-after-fire? Bp-resprout-after-fire
  set vegetation-resprouted? 0
  set vegetation-decay? 0

  ;kills the agent if the habitat is unsuitable
  biotic-compute-habitat-suitability
  if vegetation-is-habitat-suitable? = 0 [die]
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;species D
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to biotic-generate-species-D

  sprout-vegetation-species-Ds 1
  [
  set vegetation-species "Corylus avellana"

  ;graphics
  set vegetation-graphics-color pink
  set vegetation-graphics-shape "circle"
  set vegetation-graphics-size-seed 0.1
  set vegetation-graphics-size-seedling 0.2
  set vegetation-graphics-size-adult 0.6

  ;biological traits
  set vegetation-traits-maximum-age round random-normal Ca-max-age 10
  set vegetation-traits-current-age 0.1
  set vegetation-traits-sexual-maturity-age round random-normal Ca-maturity-age 2
  set vegetation-traits-dispersal-distance 1
  set vegetation-traits-pollen-productivity Ca-pollen-productivity
  set vegetation-traits-growth-rate Ca-growth-rate
  set vegetation-traits-maximum-biomass Ca-max-biomass
  set vegetation-traits-current-biomass 1
  set vegetation-traits-current-pollen-production 0
  set vegetation-traits-heliophilia Ca-heliophilia
  set vegetation-traits-seedling-tolerance Ca-seedling-tolerance
  set vegetation-traits-adult-tolerance Ca-adult-tolerance
  set vegetation-life-stage "seed"

  ;MORTALITY: we transform the probability of transition between life stages into an annual probability of death
  set vegetation-traits-seedling-mortality Ca-seedling-mortality ;(Ca-seedling-mortality / Ca-maturity-age)
  set vegetation-traits-adult-mortality Ca-adult-mortality ;(Ca-adult-mortality / (Ca-max-age - Ca-maturity-age))

  ;PERCENTILE 05 and 95
  set vegetation-niche-min-temperature-minimum-average 0.3
  set vegetation-niche-max-temperature-minimum-average 8.2
  set vegetation-niche-min-slope 2.5
  set vegetation-niche-max-slope 34.5

  ;coefficients of glm equation to compute habitat suitability
  set vegetation-glm-coef-intercept 1.51796 ;Europe
  set vegetation-glm-coef-temperature-minimum-average 0.84631 ;Europe

  ;perturbation variables
  set vegetation-years-with-unsuitable-habitat 0
  set vegetation-burnt-this-year? 0
  set vegetation-resprouts-after-fire? Ca-resprout-after-fire
  set vegetation-resprouted? 0
  set vegetation-decay? 0

  ;kills the agent if the habitat is unsuitable
  biotic-compute-habitat-suitability
  if vegetation-is-habitat-suitable? = 0 [die]
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;species E
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to biotic-generate-species-E

  sprout-vegetation-species-Es 1
  [
  set vegetation-species "Quercus petraea"

  ;graphics
  set vegetation-graphics-color orange - 1
  set vegetation-graphics-shape "circle"
  set vegetation-graphics-size-seed 0.1
  set vegetation-graphics-size-seedling 0.2
  set vegetation-graphics-size-adult 0.6

  ;biological traits
  set vegetation-traits-maximum-age round random-normal Qp-max-age 10
  set vegetation-traits-current-age 0.1
  set vegetation-traits-sexual-maturity-age round random-normal Qp-maturity-age 2
  set vegetation-traits-dispersal-distance 2
  set vegetation-traits-pollen-productivity Qp-pollen-productivity
  set vegetation-traits-growth-rate Qp-growth-rate
  set vegetation-traits-maximum-biomass Qp-max-biomass
  set vegetation-traits-current-biomass 1
  set vegetation-traits-current-pollen-production 0
  set vegetation-traits-heliophilia Qp-heliophilia
  set vegetation-traits-seedling-tolerance Qp-seedling-tolerance
  set vegetation-traits-adult-tolerance Qp-adult-tolerance
  set vegetation-life-stage "seed"

  ;MORTALITY: we transform the probability of transition between life stages into an annual probability of death
  set vegetation-traits-seedling-mortality Qp-seedling-mortality ;(Qp-seedling-mortality / Qp-maturity-age)
  set vegetation-traits-adult-mortality Qp-adult-mortality ;(Qp-adult-mortality / (Qp-max-age - Qp-maturity-age))

  ;PERCENTILE 05 and 95
  set vegetation-niche-min-temperature-minimum-average 2.5; -0.3
  set vegetation-niche-max-temperature-minimum-average 7.5; 8.1
  set vegetation-niche-min-slope 3.5
  set vegetation-niche-max-slope 33.5

  ;coefficients of glm equation to compute habitat suitability
  set vegetation-glm-coef-intercept -2.20832
  set vegetation-glm-coef-temperature-minimum-average 0.81890

  ;perturbation variables
  set vegetation-years-with-unsuitable-habitat 0
  set vegetation-burnt-this-year? 0
  set vegetation-resprouts-after-fire? Qp-resprout-after-fire
  set vegetation-resprouted? 0
  set vegetation-decay? 0

  ;kills the agent if the habitat is unsuitable
  biotic-compute-habitat-suitability
  if vegetation-is-habitat-suitable? = 0 [die]
  ]

end


;;##################################
;;SIMULATE IMMIGRATION FROM THE EDGES
;;#################################
;this procedure is called, and only species with zero patches occupied are regenerated
to biotic-regenerate-from-edges
  ask region-limits
  [
    if not any? vegetation-species-As-here and P.sylvestris? [biotic-generate-species-A]
    if not any? vegetation-species-Bs-here and P.uncinata? [biotic-generate-species-B]
    if not any? vegetation-species-Cs-here and B.pendula? [biotic-generate-species-C]
    if not any? vegetation-species-Ds-here and Q.petraea? [biotic-generate-species-D]
    if not any? vegetation-species-Es-here and C.avellana? [biotic-generate-species-E]

    ]
end


;;###########################
;;COMPUTE HABITAT SUITABILITY
;;###########################
;this procedure if performed by agents!
to biotic-compute-habitat-suitability

    ;computing habitat suitability
    set vegetation-glm-habitat-suitability 1 / ( 1 + exp( -(vegetation-glm-coef-intercept + vegetation-glm-coef-temperature-minimum-average * landscape-temperature-minimum-average)))

    ;comparing GLM result with random number and applying environmental limits (to avoid extrapolation) to decide if habitat is suitable or not.
    ifelse landscape-random < vegetation-glm-habitat-suitability
    and landscape-temperature-minimum-average < vegetation-niche-max-temperature-minimum-average
    and landscape-temperature-minimum-average > vegetation-niche-min-temperature-minimum-average
    and landscape-slope > vegetation-niche-min-slope
    and landscape-slope < vegetation-niche-max-slope

    [
      set vegetation-is-habitat-suitable? 1
      set vegetation-years-with-unsuitable-habitat 0
      ]

    [
      set vegetation-is-habitat-suitable? 0
      set vegetation-years-with-unsuitable-habitat vegetation-years-with-unsuitable-habitat + 1
      ]

end



;;###########################
;;POPULATION DYNAMICS
;;###########################
to biotic-population-dynamics

  ;FOR EACH TURTLE...
  ask turtles
  [

    ;INCREASING AGE,
    set vegetation-traits-current-age vegetation-traits-current-age + 1

    ;TRACKING LIFE STAGE
    biotic-track-life-stage

    ;MORTALITY IS ON
    ifelse Mortality?

    [

      ;INCREMENTING SEEDLING MORTALITY DUE TO MORE INTENSE HERVIBORY AFTER 7.7 ka BP
      if age-current > -7700 and age-current < -5702 [set vegetation-traits-seedling-mortality (vegetation-traits-seedling-mortality + 0.00005)] ;+ 0.1 in 2000 years
      ;if vegetation-traits-seedling-mortality >= 0.4 [set vegetation-traits-seedling-mortality 0.4]

       ;SEEDLINGS
      ;#########
      if vegetation-life-stage = "seedling"

      [

        ;TESTING IF THERE IS MORTALITY BY CLIMATE CHANGE
        ifelse vegetation-years-with-unsuitable-habitat > vegetation-traits-seedling-tolerance

          ;YES: PLANT DIES, SEED BANK IS DEPLETED
          [die]

          ;NO: TESTING IF THERE IS MORTALITY BY HERVIBORY
          [
            ifelse random-float 1 < vegetation-traits-seedling-mortality

              ;YES: THE PLANT IS TURNED INTO A SEED
              [biotic-grow-seed]

              ;NO: COMPETITION AND GROWTH
              [biotic-competition-and-growth]

            ];end of MORTALITY BY HERVIBORY

        ];end of SEEDLINGS


       ;ADULTS
      ;#########
      if vegetation-life-stage = "adult"
      [

        ;IF THE INDIVIDUAL IS FLAGGED FOR DECAY
        ifelse vegetation-decay? > 0

        ;DECAY
        [biotic-decay]

        ;ELSE
        [
        ifelse vegetation-years-with-unsuitable-habitat > vegetation-traits-adult-tolerance
          or random-float 1 < vegetation-traits-adult-mortality
          or vegetation-traits-current-age  > vegetation-traits-maximum-age

          ;FLAG FOR DECAY NEXT YEAR
          [set vegetation-decay? 1]


          ;COMPETITION AND GROWTH
          [biotic-competition-and-growth]

        ]; end of ELSE

        ]; end of ADULTS

      ];end of MORTALITY IS ON

      ;MORTALITY IS OFF
      [biotic-competition-and-growth]; end of ifelse Mortality?

  ]; end of ask turtles


end


;;##############################
;;TRACK LIFE STAGE OF THE PLANTS
;;##############################
to biotic-track-life-stage

  ;IF AGE IS 0
  ifelse vegetation-traits-current-age = 0

  ;IS SEED
  [set vegetation-life-stage "seed"]

  ;NOT SEED
  [
    ifelse vegetation-traits-current-age < vegetation-traits-sexual-maturity-age

    ;IS SEEDLING
    [set vegetation-life-stage "seedling"]

    ;IS ADULT
    [set vegetation-life-stage "adult"]
  ]
end


;;##########################################################
;;SIMULATES PLANT DECAY
;;##########################################################
to biotic-decay

  ;DECREASE BIOMASS
  ;set vegetation-traits-current-biomass (vegetation-traits-current-biomass - ((vegetation-traits-current-age - vegetation-traits-maximum-age) * (1 - vegetation-glm-habitat-suitability) * 10))
  set vegetation-traits-current-biomass vegetation-traits-current-biomass - (vegetation-decay? * ((1 - vegetation-glm-habitat-suitability) * random 10))

  ;INCREASES DECAYING TIME
  set vegetation-decay? vegetation-decay? + 1

  ;IF BIOMASS IS ALMOST ZERO
  ifelse vegetation-traits-current-biomass < 1

  ;TURN INTO SEED
  [biotic-grow-seed]

  ;OTHERWISE, COMPUTE POLLEN PRODUCTIVITY
  [biotic-update-pollen-productivity]


end


;;##########################################################
;;SIMULATES PLANT GROWTH AND COMPETITION FOR LIGHT AND SPACE
;;##########################################################
to biotic-competition-and-growth

     ;COMPUTE BIOMASS AVAILABLE IN THE PATCH
     set landscape-current-biomass sum [vegetation-traits-current-biomass] of turtles-here


       ;IF MAXIMUM BIOMASS IN THE PATCH HAS BEEN REACHED, OR THE MAXIMUM BIOMASS OF THE SPECIES HAS BEEN REACHED
       ifelse landscape-current-biomass >= Max-biomass-per-patch or vegetation-traits-current-biomass >= (vegetation-traits-maximum-biomass - random 10)

       ;NO ROOM FOR GROWTH
       [
         ;REDUCING BIOMASS AT RANDOM
         set vegetation-traits-current-biomass vegetation-traits-maximum-biomass - random vegetation-traits-current-biomass / 20

         biotic-update-pollen-productivity

         stop

       ]

       ;THERE'S ROOM FOR GROWTH
       [

        ;INTERACTION TERM DEPENDS ON THE PROPORTION OF AVAILABLE SPACE USED BY OTHER SPECIES
        set interaction-term ((1 - ((landscape-current-biomass - vegetation-traits-current-biomass) / Max-biomass-per-patch)) * (1 - vegetation-traits-heliophilia))

        ;COMPUTE BIOMASS
        set vegetation-traits-current-biomass
        vegetation-traits-maximum-biomass /
        (1 + vegetation-traits-maximum-biomass * exp(- vegetation-traits-growth-rate * interaction-term * vegetation-glm-habitat-suitability * vegetation-traits-current-age))

        ;COMPUTING POLLEN PRODUCTIVITY
        biotic-update-pollen-productivity

       ]


end


;;##################################################
;;COMPUTE POLLEN PRODUCTIVITY
;;##################################################
to biotic-update-pollen-productivity
  set vegetation-traits-current-pollen-production round (vegetation-traits-current-biomass * vegetation-traits-pollen-productivity)
end


;;##################################################
;;POST FIRE RESPONSE
;;##################################################
to biotic-post-fire-response

  ;TURN BURNT PLANTS INTO SEEDS (this HAVE to go after output-capture-proxy-data)
  ask turtles with [vegetation-burnt-this-year? = 1]
  [
    ;turn into seed
    biotic-grow-seed

    ;doubles growth rate for resprouters
    if vegetation-resprouts-after-fire? = 1
    [
      set vegetation-traits-growth-rate (vegetation-traits-growth-rate * 2)
      set vegetation-resprouted? 1
    ]


    ]

end


;;#################################
;;GROWS SEED IF SEED BANK IS ACTIVE
;;#################################
to biotic-grow-seed

  set vegetation-traits-current-age 0
  set vegetation-traits-current-biomass 1
  set vegetation-traits-current-pollen-production 0
  set vegetation-years-with-unsuitable-habitat 0
  set vegetation-burnt-this-year? 0
  set vegetation-decay? 0
  set size 0.1

  ;turn growth rate to normal for resprouted individuals
  if vegetation-resprouted? = 1
  [
    set vegetation-traits-growth-rate (vegetation-traits-growth-rate / 2)
    set vegetation-resprouted? 0
  ]

end



;;###########################
;;SEED DISPERSAL
;;###########################
to biotic-seed-dispersal

  ;selecting mature populations in suitable habitat
  ask turtles with [vegetation-life-stage = "adult" and vegetation-is-habitat-suitable? = 1]
  [

     ;captures breed of the current turtle
     let breed-of-this-turtle breed

     ;generating buffer at the given dispersal distance to places where there are not other individuals of the same species
     let dispersal-target-patches patches in-radius vegetation-traits-dispersal-distance with [not any? turtles-here with [breed = breed-of-this-turtle]]

       ;if there are dispersal patches availabl
       if any? dispersal-target-patches
       [
          ;succesful dispersal
          ask one-of dispersal-target-patches
          [
            if breed-of-this-turtle = vegetation-species-As [biotic-generate-species-A]
            if breed-of-this-turtle = vegetation-species-Bs [biotic-generate-species-B]
            if breed-of-this-turtle = vegetation-species-Cs [biotic-generate-species-C]
            if breed-of-this-turtle = vegetation-species-Ds [biotic-generate-species-D]
            if breed-of-this-turtle = vegetation-species-Es [biotic-generate-species-E]
            ]
         ]; end of any?

   ]; end of ask turtles

end



;;##################################################
;;##################################################
;;INPUT PROCEDURES
;;##################################################
;;##################################################

;;#########################
;;LOADING TIME SERIES
;;#########################

;;TEMPERATURE MINIMUM AVERAGE
to input-load-time-series-temperature
  set time-series-temperature-minimum-average []
  file-open "data/t_minimum_average"
  while [not file-at-end?] [
    let thisline file-read-line
    set time-series-temperature-minimum-average lput read-from-string thisline time-series-temperature-minimum-average
  ]
  file-close
end

;;AGE
to input-load-time-series-age
  set time-series-age []
  file-open "data/age"
  while [not file-at-end?] [
    let thisline file-read-line
    set time-series-age lput read-from-string thisline time-series-age
  ]
  file-close
end

;;Fire
to input-load-time-series-fire
  set time-series-fire []
  file-open "data/fire"
  while [not file-at-end?] [
    let thisline file-read-line
    set time-series-fire lput read-from-string thisline time-series-fire
  ]
  file-close
end


;;################
;;LOADING GIS DATA
;;################
to input-load-gis-data

  ;defines extension and resolution of the study area
  set landscape-area gis:load-dataset "data/elevation.asc"
  gis:set-world-envelope gis:envelope-of landscape-area

  ;import gis maps
  gis:apply-raster gis:load-dataset "data/slope.asc" landscape-slope
  gis:apply-raster gis:load-dataset "data/elevation.asc" landscape-elevation
  gis:apply-raster gis:load-dataset "data/topography.asc" landscape-topography

  ;import temperature correction maps
  gis:apply-raster gis:load-dataset "data/correct_t_minimum_average.asc" correction-map-temperature-minimum-average


  ;GENERATING NORTHNESS MAP (we repeat the slope map here, but it might be in different units than the one used as input above, so it is only a temporary file)
  ;;;;;;;;;;;;;;;;;;;;;;;;;
  ;THIS CODE IS ADAPTED FROM THE MODEL "GIS Gradient Example", available at the Netlogo model library, and coded by Uri Wilensky (Public domain)
  let horizontal-gradient gis:convolve landscape-area 3 3 [ 1 1 1 0 0 0 -1 -1 -1 ] 1 1
  let vertical-gradient gis:convolve landscape-area 3 3 [ 1 0 -1 1 0 -1 1 0 -1 ] 1 1
  let slope gis:create-raster gis:width-of landscape-area gis:height-of landscape-area gis:envelope-of landscape-area
  let aspect gis:create-raster gis:width-of landscape-area gis:height-of landscape-area gis:envelope-of landscape-area
  let x 0
  repeat (gis:width-of landscape-area)
  [ let y 0
    repeat (gis:height-of landscape-area)
    [ let gx gis:raster-value horizontal-gradient x y
      let gy gis:raster-value vertical-gradient x y
      if ((gx <= 0) or (gx >= 0)) and ((gy <= 0) or (gy >= 0))
      [ let s sqrt ((gx * gx) + (gy * gy))
        gis:set-raster-value slope x y s
        ifelse (gx != 0) or (gy != 0)
        [ gis:set-raster-value aspect x y atan gy gx ]
        [ gis:set-raster-value aspect x y 0 ] ]
      set y y + 1 ]
    set x x + 1 ]
  gis:set-sampling-method aspect "bilinear"

  ;convert into patch variable
  gis:apply-raster aspect landscape-aspect

  ask patches
  [
    ;0 to 180
    if landscape-aspect >= 0 and landscape-aspect < 180
    [
      set landscape-northness (landscape-aspect / 180)
      ]

    ;180 to 360
    if landscape-aspect >= 180 and landscape-aspect <= 360
    [
      set landscape-northness ((landscape-aspect - 180)/(360 - 180))
      ]

    ]
end


;;##################################################
;;##################################################
;;OUTPUT PROCEDURES
;;##################################################
;;##################################################

;;################
;;DRAW TURTLES
;;################
to output-plot-turtles
  ask turtles
  [
    set color vegetation-graphics-color
    set shape vegetation-graphics-shape

    if vegetation-life-stage = "seed" [set size vegetation-graphics-size-seed]
    if vegetation-life-stage = "seedling" [set size vegetation-graphics-size-seedling]
    if vegetation-life-stage = "adult" [set size vegetation-graphics-size-adult]
    ]

end


;;################
;;DRAW TOPOGRAPHY
;;################

to output-draw-topography

  ifelse Draw-topography?

  ;draws topography
  [
    ask patches with [landscape-topography > 0 ] [ set pcolor scale-color gray landscape-topography 50 300 ]
    ]

  ;draws RSAP
  [
    ask patches [set pcolor black]
    ask RSAP-area [set pcolor gray - 2]
    ]

end



;;#################
;;RECORD PROXY DATA
;;#################
to output-capture-proxy-data

  ;computing temperature at the core site
  set output-temperature-minimum-average [landscape-temperature-minimum-average] of patch 78 -54

  ;AGENTS ON SENSOR PRODUCING POLLEN
  let vegetation-species-As-producing-pollen-on-sensor ((vegetation-species-As-on RSAP-area) with [vegetation-life-stage = "adult"])
  let vegetation-species-Bs-producing-pollen-on-sensor ((vegetation-species-Bs-on RSAP-area) with [vegetation-life-stage = "adult"])
  let vegetation-species-Cs-producing-pollen-on-sensor ((vegetation-species-Cs-on RSAP-area) with [vegetation-life-stage = "adult"])
  let vegetation-species-Ds-producing-pollen-on-sensor ((vegetation-species-Ds-on RSAP-area) with [vegetation-life-stage = "adult"])
  let vegetation-species-Es-producing-pollen-on-sensor ((vegetation-species-Es-on RSAP-area) with [vegetation-life-stage = "adult"])

  ;COMPUTING TOTAL POLLEN PER SPECIES
  set output-pollen-vegetation-species-A sum [vegetation-traits-current-pollen-production] of vegetation-species-As-producing-pollen-on-sensor
  set output-pollen-vegetation-species-B sum [vegetation-traits-current-pollen-production] of vegetation-species-Bs-producing-pollen-on-sensor
  set output-pollen-vegetation-species-C sum [vegetation-traits-current-pollen-production] of vegetation-species-Cs-producing-pollen-on-sensor
  set output-pollen-vegetation-species-D sum [vegetation-traits-current-pollen-production] of vegetation-species-Ds-producing-pollen-on-sensor
  set output-pollen-vegetation-species-E sum [vegetation-traits-current-pollen-production] of vegetation-species-Es-producing-pollen-on-sensor

  ;CHARCOAL
  let vegetation-species-As-producing-charcoal-on-sensor ((vegetation-species-As-on RSAP-area) with [vegetation-burnt-this-year? = 1])
  let vegetation-species-Bs-producing-charcoal-on-sensor ((vegetation-species-Bs-on RSAP-area) with [vegetation-burnt-this-year? = 1])
  let vegetation-species-Cs-producing-charcoal-on-sensor ((vegetation-species-Cs-on RSAP-area) with [vegetation-burnt-this-year? = 1])
  let vegetation-species-Ds-producing-charcoal-on-sensor ((vegetation-species-Ds-on RSAP-area) with [vegetation-burnt-this-year? = 1])
  let vegetation-species-Es-producing-charcoal-on-sensor ((vegetation-species-Es-on RSAP-area) with [vegetation-burnt-this-year? = 1])

  ;COMPUTING TOTAL CHARCOAL PER SPECIES
  set output-charcoal-vegetation-species-A sum [vegetation-traits-current-biomass] of vegetation-species-As-producing-charcoal-on-sensor
  set output-charcoal-vegetation-species-B sum [vegetation-traits-current-biomass] of vegetation-species-Bs-producing-charcoal-on-sensor
  set output-charcoal-vegetation-species-C sum [vegetation-traits-current-biomass] of vegetation-species-Cs-producing-charcoal-on-sensor
  set output-charcoal-vegetation-species-D sum [vegetation-traits-current-biomass] of vegetation-species-Ds-producing-charcoal-on-sensor
  set output-charcoal-vegetation-species-E sum [vegetation-traits-current-biomass] of vegetation-species-Es-producing-charcoal-on-sensor
  set output-charcoal-vegetation-sum (output-charcoal-vegetation-species-A + output-charcoal-vegetation-species-B + output-charcoal-vegetation-species-C + output-charcoal-vegetation-species-D + output-charcoal-vegetation-species-E)

  ;BIOMASS
  set output-biomass-vegetation-species-A sum [vegetation-traits-current-biomass] of vegetation-species-As-on RSAP-area
  set output-biomass-vegetation-species-B sum [vegetation-traits-current-biomass] of vegetation-species-Bs-on RSAP-area
  set output-biomass-vegetation-species-C sum [vegetation-traits-current-biomass] of vegetation-species-Cs-on RSAP-area
  set output-biomass-vegetation-species-D sum [vegetation-traits-current-biomass] of vegetation-species-Ds-on RSAP-area
  set output-biomass-vegetation-species-E sum [vegetation-traits-current-biomass] of vegetation-species-Es-on RSAP-area
  set output-biomass-vegetation-sum (output-biomass-vegetation-species-A + output-biomass-vegetation-species-B + output-biomass-vegetation-species-C + output-biomass-vegetation-species-D + output-biomass-vegetation-species-E)

  ;output life-stage
  set output-seeds-vegetation-species-A count (vegetation-species-As-on RSAP-area) with [vegetation-life-stage = "seed"]
  set output-seeds-vegetation-species-B count (vegetation-species-Bs-on RSAP-area) with [vegetation-life-stage = "seed"]
  set output-seeds-vegetation-species-C count (vegetation-species-Cs-on RSAP-area) with [vegetation-life-stage = "seed"]
  set output-seeds-vegetation-species-D count (vegetation-species-Ds-on RSAP-area) with [vegetation-life-stage = "seed"]
  set output-seeds-vegetation-species-E count (vegetation-species-Es-on RSAP-area) with [vegetation-life-stage = "seed"]

  set output-seedlings-vegetation-species-A count (vegetation-species-As-on RSAP-area) with [vegetation-life-stage = "seedling"]
  set output-seedlings-vegetation-species-B count (vegetation-species-Bs-on RSAP-area) with [vegetation-life-stage = "seedling"]
  set output-seedlings-vegetation-species-C count (vegetation-species-Cs-on RSAP-area) with [vegetation-life-stage = "seedling"]
  set output-seedlings-vegetation-species-D count (vegetation-species-Ds-on RSAP-area) with [vegetation-life-stage = "seedling"]
  set output-seedlings-vegetation-species-E count (vegetation-species-Es-on RSAP-area) with [vegetation-life-stage = "seedling"]

  set output-adults-vegetation-species-A count (vegetation-species-As-on RSAP-area) with [vegetation-life-stage = "adult"]
  set output-adults-vegetation-species-B count (vegetation-species-Bs-on RSAP-area) with [vegetation-life-stage = "adult"]
  set output-adults-vegetation-species-C count (vegetation-species-Cs-on RSAP-area) with [vegetation-life-stage = "adult"]
  set output-adults-vegetation-species-D count (vegetation-species-Ds-on RSAP-area) with [vegetation-life-stage = "adult"]
  set output-adults-vegetation-species-E count (vegetation-species-Es-on RSAP-area) with [vegetation-life-stage = "adult"]

end

;;###########
;;SNAPSHOTS
;;###########

to output-snapshots

  ;If the interruptor is activated
  if Snapshots?
  [
    if Snapshots-frequency = "every year"
    [
      export-view (word Output-path "/snapshot-" ticks age-current ".png")
      ]

    if  Snapshots-frequency = "every 10 years"
    [
      ;saving snapshot only every 10 years
      let word-ticks (word ticks)
      if (ticks >= 10) and (last word-ticks = "0") and (last but-last word-ticks != "0") or (ticks = 100)
      [
        export-view (word Output-path "/snapshot-" ticks age-current ".png")
        ]
      ]

    ]; end of Snapshots?

end

;;###########
;;OUTPUT FILE
;;###########

to output-create-file

  ;checks if the file exists
  if (file-exists? word Output-path "/model_fire2_v12_results.csv")
  [carefully
    [file-delete word Output-path  "/model_fire2_v12_results.csv"]
    [print error-message]
  ]

  ;creates the file
  file-open word Output-path "/model_fire2_v12_results.csv"
  file-type "age;"
  file-type "temperature_minimum_average;"
  file-type "pollen_Psylvestris;"
  file-type "pollen_Puncinata;"
  file-type "pollen_Bpendula;"
  file-type "pollen_Cavellana;"
  file-type "pollen_Qpetraea;"
  file-type "real_charcoal;"
  file-type "ignitions;"
  file-type "charcoal_sum;"
  file-type "charcoal_Psylvestris;"
  file-type "charcoal_Puncinata;"
  file-type "charcoal_Bpendula;"
  file-type "charcoal_Cavellana;"
  file-type "charcoal_Qpetraea;"
  file-type "seeds_Psylvestris;"
  file-type "seedlings_Psylvestris;"
  file-type "adults_Psylvestris;"
  file-type "seeds_Puncinata;"
  file-type "seedlings_Puncinata;"
  file-type "adults_Puncinata;"
  file-type "seeds_Bpendula;"
  file-type "seedlings_Bpendula;"
  file-type "adults_Bpendula;"
  file-type "seeds_Cavellana;"
  file-type "seedlings_Cavellana;"
  file-type "adults_Cavellana;"
  file-type "seeds_Qpetraea;"
  file-type "seedlings_Qpetraea;"
  file-print "adults_Qpetraea"
  file-close


end

to output-write-file

  ;filling field by field
  file-open word Output-path "/model_fire2_v12_results.csv"
  file-type (word age-current ";")
  file-type (word output-temperature-minimum-average ";")
  file-type (word output-pollen-vegetation-species-A ";")
  file-type (word output-pollen-vegetation-species-B ";")
  file-type (word output-pollen-vegetation-species-C ";")
  file-type (word output-pollen-vegetation-species-D ";")
  file-type (word output-pollen-vegetation-species-E ";")
  file-type (word fire-charcoal-this-year ";")
  file-type (word fire-ignitions-this-year ";")
  file-type (word output-charcoal-vegetation-sum ";")
  file-type (word output-charcoal-vegetation-species-A ";")
  file-type (word output-charcoal-vegetation-species-B ";")
  file-type (word output-charcoal-vegetation-species-C ";")
  file-type (word output-charcoal-vegetation-species-D ";")
  file-type (word output-charcoal-vegetation-species-E ";")
  file-type (word output-seeds-vegetation-species-A ";")
  file-type (word output-seedlings-vegetation-species-A ";")
  file-type (word output-adults-vegetation-species-A ";")
  file-type (word output-seeds-vegetation-species-B ";")
  file-type (word output-seedlings-vegetation-species-B ";")
  file-type (word output-adults-vegetation-species-B ";")
  file-type (word output-seeds-vegetation-species-C ";")
  file-type (word output-seedlings-vegetation-species-C ";")
  file-type (word output-adults-vegetation-species-C ";")
  file-type (word output-seeds-vegetation-species-D ";")
  file-type (word output-seedlings-vegetation-species-D ";")
  file-type (word output-adults-vegetation-species-D ";")
  file-type (word output-seeds-vegetation-species-E ";")
  file-type (word output-seedlings-vegetation-species-E ";")
  file-print (word output-adults-vegetation-species-E "")
  file-close

end
@#$#@#$#@
GRAPHICS-WINDOW
1223
27
1978
531
-1
-1
4.5
1
10
1
1
1
0
0
0
1
0
165
-109
0
1
1
1
ticks
30.0

BUTTON
19
424
188
484
Setup
simulation-setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
206
638
378
683
NIL
age-last
17
1
11

MONITOR
205
594
378
639
NIL
age-current
17
1
11

BUTTON
19
593
191
685
Run
simulation-run
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
23
187
182
220
RSAP-radius
RSAP-radius
5
50
50.0
1
1
NIL
HORIZONTAL

PLOT
22
713
1203
833
Average of monthly minimum temperature (blue) and changes in environmental stochasticity (red))
age
Celsius
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"average minimum" 1.0 0 -13345367 true "" "plot output-temperature-minimum-average"
"environnmental stochasticity" 1.0 0 -2674135 true "" "plot environmental-stochasticity-changed"

SWITCH
20
279
376
312
Fire?
Fire?
0
1
-1000

INPUTBOX
20
318
189
378
Fire-probability-per-year
0.2
1
0
Number

PLOT
1226
709
1916
829
Simulated charcoal
NIL
NIL
0.0
0.0
0.0
0.0
true
false
"" ""
PENS
"charcoal" 1.0 0 -16777216 true "" "plot output-charcoal-vegetation-sum"

PLOT
1226
589
1913
709
Real charcoal
NIL
NIL
0.0
10.0
0.0
1.0
true
false
"" ""
PENS
"Real charcoal" 1.0 0 -16777216 true "" "plot fire-charcoal-this-year * Fire-ignitions-amplification-factor"
"Fire ignitions" 1.0 1 -2674135 true "" "plot fire-ignitions-this-year"

INPUTBOX
197
317
376
377
Fire-ignitions-amplification-factor
50.0
1
0
Number

INPUTBOX
390
46
550
106
Ps-max-age
800.0
1
0
Number

INPUTBOX
390
104
550
164
Ps-maturity-age
30.0
1
0
Number

INPUTBOX
390
164
550
224
Ps-pollen-productivity
1.0
1
0
Number

INPUTBOX
390
223
550
283
Ps-growth-rate
0.1
1
0
Number

INPUTBOX
390
284
550
344
Ps-max-biomass
200.0
1
0
Number

INPUTBOX
390
344
552
404
Ps-heliophilia
0.2
1
0
Number

INPUTBOX
390
404
550
464
Ps-seedling-tolerance
10.0
1
0
Number

INPUTBOX
390
464
550
524
Ps-adult-tolerance
50.0
1
0
Number

INPUTBOX
390
523
550
583
Ps-seedling-mortality
0.05
1
0
Number

INPUTBOX
390
580
550
640
Ps-adult-mortality
0.001
1
0
Number

INPUTBOX
390
640
551
700
Ps-resprout-after-fire
0.0
1
0
Number

INPUTBOX
551
46
711
106
Pu-max-age
800.0
1
0
Number

INPUTBOX
551
104
711
164
Pu-maturity-age
30.0
1
0
Number

INPUTBOX
551
164
711
224
Pu-pollen-productivity
1.0
1
0
Number

INPUTBOX
551
223
711
283
Pu-growth-rate
0.1
1
0
Number

INPUTBOX
551
284
711
344
Pu-max-biomass
200.0
1
0
Number

INPUTBOX
551
344
713
404
Pu-heliophilia
0.2
1
0
Number

INPUTBOX
551
404
711
464
Pu-seedling-tolerance
10.0
1
0
Number

INPUTBOX
551
464
711
524
Pu-adult-tolerance
50.0
1
0
Number

INPUTBOX
551
523
711
583
Pu-seedling-mortality
0.05
1
0
Number

INPUTBOX
551
580
711
640
Pu-adult-mortality
0.001
1
0
Number

INPUTBOX
551
640
712
700
Pu-resprout-after-fire
0.0
1
0
Number

INPUTBOX
712
46
872
106
Bp-max-age
100.0
1
0
Number

INPUTBOX
712
104
872
164
Bp-maturity-age
15.0
1
0
Number

INPUTBOX
712
164
872
224
Bp-pollen-productivity
1.0
1
0
Number

INPUTBOX
712
223
872
283
Bp-growth-rate
0.3
1
0
Number

INPUTBOX
712
284
872
344
Bp-max-biomass
150.0
1
0
Number

INPUTBOX
712
344
874
404
Bp-heliophilia
0.4
1
0
Number

INPUTBOX
712
404
872
464
Bp-seedling-tolerance
5.0
1
0
Number

INPUTBOX
712
464
872
524
Bp-adult-tolerance
10.0
1
0
Number

INPUTBOX
712
523
872
583
Bp-seedling-mortality
0.1
1
0
Number

INPUTBOX
712
580
872
640
Bp-adult-mortality
0.008
1
0
Number

INPUTBOX
712
640
873
700
Bp-resprout-after-fire
1.0
1
0
Number

INPUTBOX
1036
46
1196
106
Ca-max-age
100.0
1
0
Number

INPUTBOX
1036
104
1196
164
Ca-maturity-age
10.0
1
0
Number

INPUTBOX
1036
164
1196
224
Ca-pollen-productivity
1.0
1
0
Number

INPUTBOX
1036
223
1196
283
Ca-growth-rate
0.3
1
0
Number

INPUTBOX
1036
284
1196
344
Ca-max-biomass
150.0
1
0
Number

INPUTBOX
1036
344
1195
404
Ca-heliophilia
0.4
1
0
Number

INPUTBOX
1036
404
1196
464
Ca-seedling-tolerance
5.0
1
0
Number

INPUTBOX
1036
464
1196
524
Ca-adult-tolerance
15.0
1
0
Number

INPUTBOX
1036
523
1196
583
Ca-seedling-mortality
0.2
1
0
Number

INPUTBOX
1036
580
1196
640
Ca-adult-mortality
0.006
1
0
Number

INPUTBOX
1036
640
1197
700
Ca-resprout-after-fire
1.0
1
0
Number

INPUTBOX
874
46
1034
106
Qp-max-age
500.0
1
0
Number

INPUTBOX
874
105
1034
165
Qp-maturity-age
30.0
1
0
Number

INPUTBOX
874
165
1034
225
Qp-pollen-productivity
1.0
1
0
Number

INPUTBOX
874
224
1034
284
Qp-growth-rate
0.1
1
0
Number

INPUTBOX
874
285
1034
345
Qp-max-biomass
150.0
1
0
Number

INPUTBOX
874
345
1036
405
Qp-heliophilia
0.1
1
0
Number

INPUTBOX
874
405
1034
465
Qp-seedling-tolerance
10.0
1
0
Number

INPUTBOX
874
465
1034
525
Qp-adult-tolerance
40.0
1
0
Number

INPUTBOX
874
524
1034
584
Qp-seedling-mortality
0.1
1
0
Number

INPUTBOX
874
581
1034
641
Qp-adult-mortality
0.002
1
0
Number

INPUTBOX
874
640
1035
700
Qp-resprout-after-fire
1.0
1
0
Number

INPUTBOX
198
152
376
220
Max-biomass-per-patch
500.0
1
0
Number

PLOT
21
831
1203
951
Pollen of Pinus uncinata
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Pinus uncinata" 1.0 0 -12087248 true "" "plot output-pollen-vegetation-species-B"

PLOT
22
950
1204
1070
Pollen of Pinus sylvestris
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Pinus sylvestris" 1.0 0 -6565750 true "" "plot output-pollen-vegetation-species-A"

PLOT
22
1068
1206
1188
Pollen of Betula pendula
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Betula pendula" 1.0 0 -4079321 true "" "plot output-pollen-vegetation-species-C"

PLOT
22
1306
1207
1426
Pollen of Corylus avellana
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Corylus avellana" 1.0 0 -2064490 true "" "plot output-pollen-vegetation-species-D"

PLOT
1226
949
1993
1069
Population dynamics of Pinus sylvestris
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"seeds" 1.0 0 -3026479 true "" "plot output-seeds-vegetation-species-A"
"seedlings" 1.0 0 -13345367 true "" "plot output-seedlings-vegetation-species-A"
"adults" 1.0 0 -2674135 true "" "plot output-adults-vegetation-species-A"

PLOT
1226
829
1994
949
Population dynamics of Pinus uncinata
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"seeds" 1.0 0 -3026479 true "" "plot output-seeds-vegetation-species-B"
"seedlings" 1.0 0 -13345367 true "" "plot output-seedlings-vegetation-species-B"
"adults" 1.0 0 -2674135 true "" "plot output-adults-vegetation-species-B"

PLOT
1229
1069
1995
1189
Population dynamics of Betula pendula
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"seeds" 1.0 0 -3026479 true "" "plot output-seeds-vegetation-species-C"
"seedlings" 1.0 0 -13345367 true "" "plot output-seedlings-vegetation-species-C"
"adults" 1.0 0 -2674135 true "" "plot output-adults-vegetation-species-C"

PLOT
1226
1307
1990
1427
Population dynamics of Corylus avellana
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"seeds" 1.0 0 -3026479 true "" "plot output-seeds-vegetation-species-D"
"seedlings" 1.0 0 -13345367 true "" "plot output-seedlings-vegetation-species-D"
"adults" 1.0 0 -2674135 true "" "plot output-adults-vegetation-species-D"

SWITCH
20
145
182
178
Draw-topography?
Draw-topography?
1
1
-1000

INPUTBOX
200
425
380
485
Burn-in-iterations
1000.0
1
0
Number

MONITOR
199
491
377
536
Current burn-in iteration
Burn-in-counter
0
1
11

BUTTON
20
553
379
589
Run one year
simulation-run
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
19
487
189
536
Restart plots
clear-all-plots
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

PLOT
22
1186
1206
1306
Pollen of Quercus petraea
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"Quercus petraea" 1.0 0 -3844592 true "" "plot output-pollen-vegetation-species-E"

PLOT
1226
1189
1993
1309
Population dynamics of Quercus petraea
NIL
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"seeds" 1.0 0 -3026479 true "" "plot output-seeds-vegetation-species-E"
"seedlings" 1.0 0 -13345367 true "" "plot output-seedlings-vegetation-species-E"
"adults" 1.0 0 -2674135 true "" "plot output-adults-vegetation-species-E"

SWITCH
22
100
185
133
Snapshots?
Snapshots?
1
1
-1000

CHOOSER
199
100
378
145
Snapshots-frequency
Snapshots-frequency
"every 10 years" "every year"
0

INPUTBOX
22
32
380
92
Output-path
/home/blas/Dropbox/RESEARCH/COLLABORATIONS/compartido_modelos_fuego/5_model/code/output
1
0
String

CHOOSER
22
227
375
272
Randomness-settings
Randomness-settings
"Fixed seed, deterministic results" "Free seed, non-deterministic results"
1

PLOT
22
1522
1207
1672
Monitored individuals biomass
Time
Biomass
0.0
10.0
0.0
10.0
true
true
"" "ask monitored-turtles [\n  create-temporary-plot-pen (word vegetation-species)\n  set-plot-pen-color color\n  plotxy ticks vegetation-traits-current-biomass\n]"
PENS

PLOT
20
1674
1208
1824
Monitored individuals suitability
Time
Suitability
0.0
10.0
0.0
1.0
true
true
"" "ask monitored-turtles [\n  create-temporary-plot-pen (word vegetation-species)\n  set-plot-pen-color color\n  plotxy ticks vegetation-glm-habitat-suitability\n]"
PENS

PLOT
20
1825
1208
1975
Monitored individuals age
Time
Age
0.0
10.0
0.0
10.0
true
true
"" "ask monitored-turtles [\n  create-temporary-plot-pen (word vegetation-species)\n  set-plot-pen-color color\n  plotxy ticks vegetation-traits-current-age\n]"
PENS

INPUTBOX
22
1459
183
1519
monitored-x
85.0
1
0
Number

INPUTBOX
186
1459
347
1519
monitored-y
-10.0
1
0
Number

BUTTON
354
1460
502
1519
Run
simulation-run
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
390
10
550
43
P.sylvestris?
P.sylvestris?
0
1
-1000

SWITCH
554
10
710
43
P.uncinata?
P.uncinata?
0
1
-1000

SWITCH
714
10
872
43
B.pendula?
B.pendula?
0
1
-1000

SWITCH
875
10
1034
43
Q.petraea?
Q.petraea?
0
1
-1000

SWITCH
1036
10
1195
43
C.avellana?
C.avellana?
0
1
-1000

SWITCH
20
384
189
417
Mortality?
Mortality?
0
1
-1000

TEXTBOX
520
1466
980
1515
This section is for testing purposes only. It allows the user to monitor the behavior of the model in a single patch defined by its cordinates monitored-x and monitored-y
12
0.0
1

@#$#@#$#@
## WHAT IS IT?

This is a spatio-temporal simulation of the effect of fire regimes on the population dynamics of five forest species (Pinus sylvestris, Pinus uncinata, Betula pendula, Corylus avellana, and Quercus petraea) during the Lateglacial-Holocene transition (15-7 cal Kyr BP) at El Portalet, an alpine bog located in the central Pyrenees region (1802m asl, Spain), that has served for palaeoenvironmental studies (González-Smapériz et al. 2006; Gil-Romera et al., 2014).


## HOW IT WORKS

### Abiotic component

The abiotic layer of the model is represented by three main environmental factors:

+ **Topography** derived from a digital elevation model at 200 x 200 meters resolution. Slope (along temperature) is used to impose restrictions to species distributions. Northness (in the range [0, 1]) is used to restrict fire spread. Aspect is used to draw a shaded relief map (at the user's request). Elevation is used to compute a lapse rate map (see below).

+ **Temperature** (average of montly minimum temperatures) time series for the study area computed from palaeoclimatic data at annual resolution provided by the [TraCe simulation](http://www.cgd.ucar.edu/ccr/TraCE/), a transient model for the global climate evolution of the last 21K years with an annual resolution. The single temperature value of every year is converted into a temperature map (200 x 200 m resolution) using a lapse rate map based on the elevation map. Temperature, along with slope, is used to compute habitat suitability by using a logistic equation. Habitat suitability affects plant growth and survival.

+ **Fire**: The charcoal accumulation rate record from El Portalet palaeoenvironmental sequence (Gil-Romera et al., 2014) is used as input to simulate forest fires. A value of this time series is read each year, and a random number in the range [0, 1] is generated. If the random number is lower than the *Fire-probability-per-year* parameter defined by the user, the value from the charcoal time series is multiplied by the parameter Fire-ignitions-amplification-factor (defined by the user) to compute the number of ignitions for the given year. As many adult treeF as ignitions are selected to start spreading fire. Fire spreads to a neighbor patch if there is an adult tree in there, and a random number in the range [0, 1] is higher than the northness value of the patch.

### Biotic component

The biotic layer of the model is composed by five tree species. We have introduced the following elements to represent their ecological dynamics:

+ **Topoclimatic niche**, inferred from their present day distributions and high resolution temperature maps (presence data taken from GBIF, temperature maps taken from Worldclim and the Digital Climatic Atlas of the Iberian Peninsula). The ecological niche is represented by a logistic equation (see below). The results of this equation plus the dispersal dynamics of each species defines changes in distribution over time.

+ **Population dynamics**, driven by species traits such as dispersal distance, longevity, fecundity, mortality, growth rate, post-fire response to fire, and heliophity (competition for light). The data is based on the literature and/or expert opinion from forest and fire ecologists, and it is used to simulate growth (using logistic equations), competition for light and space, decay due to senescence, and mortality due to climate, fire, or plagues.

The model doesn't simulate the entire populations of the target species. Instead, on each 200 x 200 meters patch it simulates the dynamics of an small forest plot (around 10 x 10 meters) where a maximum of one individual per species can exist.


### Model dynamics

**The life of an individual**

During the model setup seeds of every species are created on every patch. From there, every seed will go through the following steps every simulated year:

+  Its age increases by one year, and its life-stage is changed to "seedling".

+  The minimum average temperature of its patch is updated.

+  The individual computes its habitat suitability using the logistic equation *1 / ( 1 + exp( -(intercept + coefficient * patch-temperature)))*, where the *intercept* and the *coefficient* are user defined. These parameters are hardcoded to save space in the GUI, and have been computed beforehand by using current presence data and temperature maps. 

    +  If habitat suitability is higher than a random number in the range [0, 1], the habitat is considered suitable (NOTE: this random number is defined for the patch, and it changes every ~10 years following a random walk drawn from a normal distribution with the average set to the previous value, and a standard deviation of 0.001).

    +  If it is lower, the habitat is considered unsuitable, and the number of years under unsuitable habitat is increased by 1.

        + If the number of years unders unsuitable habitat becomes higher than *seedling-tolerance*, the seedling dies, and another seed from the seed bank takes its place. Otherwise it stays alive.

+  Mortality: If a random number in the range [0, 1] is lower than the seedling mortality of the species the plant dies, and it is replaced by a seed from the seed bank. Otherwise it stays alive.

+  Competition and growth:

   +  If the patch total biomass of the individuals in the patch equals *Max-biomass-per-patch*, the individual loses an amount of biomass between 0 and the 20% of its current biomass. This number is selected at random.

   + If *Max-biomass-per-patch* has not been reached yet:

       + An *interaction term* is computed as *(1 - (biomass of other individuals in the patch / Max-biomass-per-patch)) * (1 - heliophilia))*. 

       + The interaction term is introduced in the growth equation *max-biomass / (1 + max-biomass * exp(- growth-rate * interaction-term * habitat-suitability * age))* to compute the current biomass of the individual. The lower the interaction term and habitat suitability are, the lower the growth becomes.

+  If a fire reaches the patch and there are adult individuals of other species on it, the plant dies, and it is replaced by a seed (this seed inherites the traits of the parent).

These steps continue while the individual is still a seedling, but once it reaches its maturity some steps become slightly different:

+  If a random number in the range [0, 1] is lower than the adults mortality of the species, or the maximum age of the species is reached, the individual is marked for decay. The current biomass of decaying individuals is computed as *previous-biomass - years-of-decay*. To add the effect of climatic variability to this decreasing function, its result is multiplied by *1 - habitat-suitability x random[0, 10]*. If the biomass is higher than zero, pollen productivity is computed as *current-biomass x species-pollen-productivity*. The individual dies and is replaced by a seed when the biomass is below 1.

+  Dispersal: If the individual is in suitable habitat, a seed from it is placed in one of the neighboring patches within a radius given by the dispersal distance of the species (which is measured in "number of patches" and hardcoded) with no individuals of the same species.

+  If the individual starts a fire, or if fire spreads in from neighboring patches, it is marked as "burned", spreads fire to its neighbors, dies, and is replaced by a seed. If the individual belongs to an species with post-fire resprouting, the growth-rate of the seed is multiplied by 2 to boost growth after fire.

**Simulating pollen and charcoal deposition**

The user defines the radius of a catchment area round the El Portalet core location (10 km by default). All patches withing this radius define the RSAP (relevant source area of pollen). 

At the end of every simulated year the pollen production of every adult of each species within the RSAP is summed, and this value is used to compose the simulated pollen curves. The same is done with the biomass of the burned individuals to compose the virtual charcoal curve.

### Output

**Results table**

The resulting data is exported to a table (csv format) with the following columns, and one row per simulated year:

+  age: simulated year.
+  temperature_minimum_average: average minimum winter temperature of the study area.
+  pollen_Psylvestris: pollen sum for Pinus sylvestris.
+  pollen_Puncinata
+  pollen_Bpendula
+  pollen_Cavellana
+  pollen_Qpetraea
+  real_charcoal: real charcoal values from El Portalet core.
+  ignitions: number of fire ignitions.
+  charcoal_sum: biomass sum of all burned individuals.
+  charcoal_Psylvestris: biomass sum of burned individuals of Pinus sylvestris.
+  charcoal_Puncinata
+  charcoal_Bpendula
+  charcoal_Cavellana
+  charcoal_Qpetraea
+  seeds_Psylvestris: number of seeds produced by adult individuals of Pinus sylvestris.
+  seedlings_Psylvestris: number of seedlings.
+  adults_Psylvestris: number of adults.
+  seeds_Puncinata
+  seedlings_Puncinata
+  adults_Puncinata
+  seeds_Bpendula
+  seedlings_Bpendula
+  adults_Bpendula
+  seeds_Cavellana
+  seedlings_Cavellana
+  adults_Cavellana
+  seeds_Qpetraea
+  seedlings_Qpetraea

**Graphical output**


The model presents several graphical outputs:
+  Modeled pollen variation for the target taxa.

+ Population dynamics plots, showing the number of adults, seedling and seeds produced during the simulation.

+ Plots of the input values:
	+ Minimum Temperature of the coldest month.
	+ Charcoal.


## HOW TO USE IT

### Input files

Input files are stored in a folder named "data". These are:

+  **age**: text file with no extension and a single column with no header containing age values from -15000 to -5701 
+  **fire**: text file with no extension and a single column with no header containing actual charcoal counts expresed in the range [0, 1]. There are as many rows as in the **age** file
+  **t_minimum_average**: text file with same features as the ones above containing minimum winter temperatures for the study area extracted from the TraCe simualtion.
+  **correct_t_minimum_average.asc**: Map at 200m resolution containing the minimum winter temperature difference (period 1970-2000) between the TraCe simulation and the Digital Climatic Atlas of the Iberian Peninsula. It is used to transform the values of **t_minimum_average** into a high resolution temperature map.
+  **elevation.asc**: digital elevation model of the study area at 200m resolution, coordinate system with EPSG code 23030.
+  **slope.asc**: topographic slope.
+  **topography.asc**: shaded relief map. It is used for plotting purposes only.

### Input parameters

**General configuration of the simulation**

+  **Output-path**: Character. Path of the output folder. This parameter cannot be empty.
+  **Snapshots?**: Boolean. If on, creates snapshots of the GUI to make videos.
+  **Snapshots-frequency**: Character. Defines the frequency of snapshots. Only two options: "every year" and "every 10 years".
+  **Draw-topography?**: Boolean. If on, plots a shaded relief map (stored in **topography.asc**).
+  **RSAP-radius**: Numeric[5, 50]. Radius of the RSAP in number of patches. Each patch is 200 x 200 m, so an RSAP-radius of 10 equals 2 kilometres.
+ **Randommness-settings**: Character. Allows to choose between "fixed seed" to obtain deterministic results, or "free seed" to obtain different results on each run.
+  **Max-biomass-per-patch**: Numeric, integer. Maximum charge capacity of a patch.
+  **Fire?**: Boolean. If on, fires are produced whenever the data **fire** triggers a fire event. If off, fires are not produced (control simulation).
+  **Fire-probability-per-year**: Numeric [0, 1]. Whenever the **fire** file provides a number higher than 0, if a random number in the range [0, 1] is lower than **Fire-probability-per-year**, a number of ignitions is computed (see below) and fires are triggered.
+  **Fire-ignitions-amplification-factor**: Numeric  The **fire** file provides values in the range [0, 1], and this multiplication factor converts these values in an integer number of ignitions. If **fire** equals one, and **Fire-ignitions-amplification-factor** equals 10, the number of ignitions will be 10 for the given year.
+  **Mortality?**: Boolean. If on, mortality due to predation, plagues and other unpredictable sources is active (see **Xx-seedling-mortality** and **Xx-adult-mortality** parameters below).
+  **Burn-in-iterations**: Numeric, integer. Number of years to run the model at a constant temperature (the initial one in the **t_minimum_average** file) and no fires to allow the population model to reach an equilibrium before to start the actual simulation.
+ **P.sylvestris?**, **P.uncinata?**, **B.pendula?**, **Q.petraea?**, and **C.avellana?**: Boolean. If off, the given species is removed from the simulation. Used for testing purposes.

**Species traits**

+  **Xx-max-age**: Numeric, integer. Maximum longevity. Every individual reaching this age is marked for decay.
+  **Xx-maturity-age**: Numeric, integer. Age of sexual maturity. Individuals reaching this age are considered adults.
+  **Xx-pollen-productivity**: Numeric. Multiplier of biomass to obtain a relative measure of pollen productivity among species.
+  **Xx-growth-rate**: Numeric. Growth rate of the given species.
+  **Xx-max-biomass**: Numeric, integer. Maximum biomass reachable by the given species.
+  **Xx-heliophilia**: Numeric, [0, 1]. Dependance of the species on solar light to grow. It is used to compute the effect of competence in plant growth.
+  **Xx-seedling-tolerance**: Numeric, integer. Numer of years a seedling can tolerate unsuitable climate.
+  **Xx-adult-tolerance**: Numeric, integer. Numer of years an adult can tolerate unsuitable climate.
+  **Xx-seedling-mortality**: Numeric, [0, 1]. Proportion of seedlings dying due to predation.
+  **Xx-adult-mortality**: Numeric, [0, 1]. Proportion of adults dying due to plagues or other mortality sources.
+  **Xx-resprout-after-fire**: Boolean. If 0 the species doesn't show a post-fire response. If 1, **growth-rate** is multiplied by two in the resprouted individual to increase growth rate.

The parameters describing species' niches are hard-coded because the GUI was already crammed with boxes:

+  **vegetation-niche-min-temperature-minimum-average**: Numeric. Minimum temperature at which the species has been found using GBIF presence data.
+  **vegetation-niche-min-slope**: Numeric. Minimum topographic slope at which the species has been found.
+  **vegetation-niche-max-slope**: Numeric. Maximum topographic slope at which the species has been found.
+  **vegetation-glm-coef-intercept**: Numeric. Intercept of the logistic equation to compute habitat suitability fitted to presence data and minimum temperature maps.
+  **vegetation-glm-coef-temperature-minimum-average**: Numeric. Coefficient of the logistic equation to compute habitat suitability.








## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
