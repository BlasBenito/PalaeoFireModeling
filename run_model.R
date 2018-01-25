##AUTHOR: BLAS M. BENITO
#EMAIL: blasbenito (at) gmail.com

#INSTALLING NETLOGO 6.0.2
########################################
#DOWNLOAD NETLOGO FROM MY DROPBOX (it is ready to use RNetLogo on it)
download.file(url="https://www.dropbox.com/s/vmddzpc955tul3n/netlogo.zip?raw=1", destfile="netlogo.zip")

#DECOMPRESS FILE AND RENAME FOLDER (FOR SIMPLER PATHS)
unzip("netlogo.zip")


#INSTALLING AND LOADING LIBRARIES
########################################

#INSTALLING JAVA WITH SUDO IN MY LOCAL MACHINE: 
# sudo apt-get install default-jdk
# sudo update-alternatives --config java (check path here and use it in the next line)
# export LD_LIBRARY_PATH=/usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java
# sudo R CMD javareconf


#INSTALLING rJava IN THE VIRTUAL MACHINE
#Open ssh connection from your computer. RSA key is required. Change IP as needed. sudo doesn't require password
#ssh -i /home/blas/Dropbox/AMAZON_CLOUD/Rstudio.pem ubuntu@18.196.153.217
#sudo apt-get install r-cran-rjava
#sudo update-alternatives --config java #not really required
#sudo R CMD javareconf
#reboot system



#IN R, installing libraries
# install.packages("rJava", dep=TRUE)
<<<<<<< HEAD
# install.packages("RNetLogo", dep=TRUE)
=======
#install.packages("RNetLogo", dep=TRUE)
>>>>>>> b28647f1b2da3fd9b5f1bb748b0cab38f3fd5628

#loading library
library("RNetLogo")
library("parallel")

#RELEVANT PATHS (MODIFY THEM AS YOU NEED)
#######################################
#netlogo executable, it requires the location of the "app" folder inside of the netlogo install folder
#IMPORTANT: If your model uses NetLogo extensions, copy the files of the extension inside the "app" folder of the NetLogo install folder.
netlogo.path <- "/home/rstudio/PalaeoFireModeling/netlogo/app"

#model path. IMPORTANT: requires an absolute path
model.path <- "/home/rstudio/PalaeoFireModeling/model.nlogo" 

#main working folder
working.folder <- "/home/rstudio/PalaeoFireModeling"
setwd(working.folder)

#OUTPUT FOLDER
output.folder <- paste(working.folder, "/output", sep="")
dir.create(output.folder)

setwd("~/PalaeoFireModeling")


#LOADING MODEL
#####################################
#starting netlogo
#note: set gui=FALSE for headless execution in server
NLStart(netlogo.path, gui=FALSE, nl.jarname="netlogo-6.0.2.jar")
#loading your model
NLLoadModel(model.path)


#DECOMPRESSING INPUT DATA
#####################################
unzip(zipfile="/home/rstudio/PalaeoFireModeling/data.zip")


#EXECUTION PARAMETERS
#######################################
#iterations to initialize the population model
burn.in.iterations=1000
<<<<<<< HEAD
burn.in.iterations=1000
#number of times each simulation is repeated
repetitions=10
repetitions=5
=======
#number of times each simulation is repeated
repetitions=10
>>>>>>> b28647f1b2da3fd9b5f1bb748b0cab38f3fd5628
#number of years to be run in the simulation
run.years=nrow(read.table(paste(working.folder, "/data/fire", sep="")))
# run.years=50
#range of fire parameter values
fire.probability.per.year.values=seq(0.2, 1, by=0.2)
fire.ignitions.amplification.factor.values=seq(10, 50, by=10)


#SPECIES TRAITS
#################################
#use this function whenever you need to reset the trait values in the GUI, ideally to be run before each execution
set.traits <- function(){
  NLCommand("set P.sylvestris? TRUE", 
            "set Ps-max-age 800", 
            "set Ps-maturity-age 30",
            "set Ps-pollen-productivity 1", 
            "set Ps-growth-rate 0.1", 
            "set Ps-max-biomass 200", 
            "set Ps-heliophilia 0.2", 
            "set Ps-seedling-tolerance 10", 
            "set Ps-adult-tolerance 50", 
            "set Ps-seedling-mortality 0.05", 
            "set Ps-adult-mortality 0.001", 
            "set Ps-resprout-after-fire 0", 
            "set Ps-min-slope 4.2", 
            "set Ps-max-slope 31.4", 
            "set Ps-min-temperature -4.6", 
            "set Ps-max-temperature 6.8", 
            "set Ps-intercept 2.02131", 
            "set Ps-coefficient 0.36198", 
            "set P.uncinata? TRUE", 
            "set Pu-max-age 800", 
            "set Pu-maturity-age 30", 
            "set Pu-pollen-productivity 1", 
            "set Pu-growth-rate 0.1", 
            "set Pu-max-biomass 200", 
            "set Pu-heliophilia 0.2", 
            "set Pu-seedling-tolerance 10", 
            "set Pu-adult-tolerance 50", 
            "set Pu-seedling-mortality 0.05", 
            "set Pu-adult-mortality 0.001", 
            "set Pu-resprout-after-fire 0", 
            "set Pu-min-slope 7.1", 
            "set Pu-max-slope 36.5", 
            "set Pu-min-temperature -1.1", 
            "set Pu-max-temperature 7.4", 
            "set Pu-intercept 0.2695", 
            "set Pu-coefficient 0.6179", 
            "set B.pendula? TRUE", 
            "set Bp-max-age 100", 
            "set Bp-maturity-age 15", 
            "set Bp-pollen-productivity 1", 
            "set Bp-growth-rate 0.3", 
            "set Bp-max-biomass 150", 
            "set Bp-heliophilia 0.4", 
            "set Bp-seedling-tolerance 5", 
            "set Bp-adult-tolerance 10", 
            "set Bp-seedling-mortality 0.1", 
            "set Bp-adult-mortality 0.008", 
            "set Bp-resprout-after-fire 1", 
            "set Bp-min-slope 6.5", 
            "set Bp-max-slope 37.9", 
            "set Bp-min-temperature -2.8", 
            "set Bp-max-temperature 7", 
            "set Bp-intercept 0.71627", 
            "set Bp-coefficient 0.273", 
            "set Q.petraea? TRUE", 
            "set Qp-max-age 500", 
            "set Qp-maturity-age 30", 
            "set Qp-pollen-productivity 1", 
            "set Qp-growth-rate 0.1", 
            "set Qp-max-biomass 150", 
            "set Qp-heliophilia 0.1", 
            "set Qp-seedling-tolerance 10", 
            "set Qp-adult-tolerance 40", 
            "set Qp-seedling-mortality 0.1", 
            "set Qp-adult-mortality 0.002", 
            "set Qp-resprout-after-fire 1", 
            "set Qp-min-slope 3.5", 
            "set Qp-max-slope 33.5", 
            "set Qp-min-temperature 2.5", 
            "set Qp-max-temperature 7.5", 
            "set Qp-intercept -2.20832", 
            "set Qp-coefficient 0.8189", 
            "set C.avellana? TRUE", 
            "set Ca-max-age 100", 
            "set Ca-maturity-age 10", 
            "set Ca-pollen-productivity 1", 
            "set Ca-growth-rate 0.3", 
            "set Ca-max-biomass 150", 
            "set Ca-heliophilia 0.4", 
            "set Ca-seedling-tolerance 5", 
            "set Ca-adult-tolerance 15", 
            "set Ca-seedling-mortality 0.2", 
            "set Ca-adult-mortality 0.006", 
            "set Ca-resprout-after-fire 1", 
            "set Ca-min-slope 2.5", 
            "set Ca-max-slope 34.5", 
            "set Ca-min-temperature 0.3", 
            "set Ca-max-temperature 8.2", 
            "set Ca-intercept 1.51796", 
            "set Ca-coefficient 0.84631")
}

#example (will throw an error if the model isn't loaded)
set.traits()


##############################################################################
##############################################################################
#SENSITIVITY ANALYSIS
##############################################################################
##############################################################################


##############################################################################
#CONTROL SIMULATION: NO FIRE
##############################################################################

#LIST TO SAVE RESULTS
nofire.experiment=list()

#SIMULATIONS
for (current.repetition in 1:repetitions){
  
<<<<<<< HEAD
  print(current.repetition)
    
=======
>>>>>>> b28647f1b2da3fd9b5f1bb748b0cab38f3fd5628
  #create folder to store results
  repetition.folder=paste("output/nofire/repetition_", current.repetition, sep="")
  dir.create(repetition.folder, recursive=TRUE)
  
  #PARAMETER CONFIGURATION
  #output folder
  NLCommand("set Output-path", paste("\"", repetition.folder, "\"", sep=""))
  
  #traits
  set.traits()
  
  #general parameters for all simulations
  NLCommand("set Snapshots?  \"no snapshots\"", 
            "set Draw-topography? FALSE", 
            "set RSAP-radius 50", 
            "set Randomness-settings  \"Free seed, non-deterministic results\"", 
            "set Max-biomass-per-patch 500", 
            "set Mortality? TRUE", 
            "set Burn-in-iterations ", burn.in.iterations)
  
  #deactivating fire
  NLCommand("set Fire? FALSE")
  
  #running setup procedure
  NLCommand("simulation-setup")
  
  #run simulation
  NLDoCommand(run.years, "simulation-run")
  
  #store resulting tables in list
  nofire.experiment[[current.repetition]] <- read.table(paste(repetition.folder, "/output_table.csv", sep=""), header=TRUE, sep=";", dec=".")
  
}


##############################################################################
#SENSITIVITY ANALYSIS: FIRE
##############################################################################
#WORKING FOLDER (where the NetLogo model lives)
setwd(working.folder)

#LIST TO SAVE RESULTS
fire.experiment=list()

#VECTORS TO SAVE PARAMETERS (will become a dataframe at the end)
fire.id=0
fire.ids=vector()
fire.probability=vector()
fire.ignitions=vector()
fire.repetition=vector()
fire.names=vector()

#FIRE PROBABILITY PER YEAR
for (fire.probability.per.year in fire.probability.per.year.values){
  
  #FIRE IGNITIONS AMPLIFICATION FACTOR
  for (fire.ignitions.amplification.factor in fire.ignitions.amplification.factor.values){
    
    #REPETITIONS
    for (current.repetition in 1:repetitions){
      
      #gathering parameters
      fire.id=fire.id+1
      print(fire.id)
      fire.ids=c(fire.ids, fire.id)
      fire.probability=c(fire.probability, fire.probability.per.year)
      fire.ignitions=c(fire.ignitions, fire.ignitions.amplification.factor)
      fire.repetition=c(fire.repetition, current.repetition)
      fire.names=c(fire.names, paste("p", fire.probability.per.year, "-i", fire.ignitions.amplification.factor, "-r", current.repetition, sep=""))
      
      #create folder to store results
      repetition.folder=paste("output/fire/", fire.id, sep="")
      dir.create(repetition.folder, recursive=TRUE)
      
      #PARAMETER CONFIGURATION
      #output folder
      NLCommand("set Output-path", paste("\"", repetition.folder, "\"", sep=""))
      
      #traits
      set.traits()
      
      #general parameters for all simulations
      NLCommand("set Snapshots?  \"no snapshots\"", 
                "set Draw-topography? FALSE", 
                "set RSAP-radius 50", 
                "set Randomness-settings  \"Free seed, non-deterministic results\"", 
                "set Max-biomass-per-patch 500", 
                "set Mortality? TRUE", 
                "set Burn-in-iterations ", burn.in.iterations)
      
      #activating fire and setting up parameters
      NLCommand("set Fire? TRUE", 
                "set Fire-probability-per-year", fire.probability.per.year, 
                "set Fire-ignitions-amplification-factor", fire.ignitions.amplification.factor)
      
      #running setup procedure
      NLCommand("simulation-setup")
      
      #run simulation
      NLDoCommand(run.years, "simulation-run")
      
      #store resulting tables in list
      fire.experiment[[fire.id]] <- read.table(paste(repetition.folder, "/output_table.csv", sep=""), header=TRUE, sep=";", dec=".")
      
    } #end of REPETITIONS
    
  } #end of FIRE IGNITIONS AMPLIFICATION FACTOR
  
} #end of FIRE PROBABILITY PER YEAR

#WRITING AND SAVING OUTPUT DATA
experiments.table=data.frame(id=fire.ids, fire_probability_per_year=fire.probability, fire_ignitions_amplification_factor=fire.ignitions, repetition=fire.repetition, simulation_name=fire.names)

save(nofire.experiment, fire.experiment, experiments.table, file="output/experiment_results.RData")

write.table(experiments.table, file = "output/fire_experiments.csv", col.names = TRUE, row.names = FALSE, sep=";")


#close the model
NLQuit()


#PARALLELISED VERSION
################################################
################################################

#FUNCTIONS

#initialization function (to be used by each core)
initialize.model <- function(dummy, netlogo.path, model.path) {
  library(RNetLogo)
  NLStart(netlogo.path, gui=FALSE, nl.jarname="netlogo-6.0.2.jar")
  NLLoadModel(model.path)
}

#nofire simulation function
nofire.simulation <- function(current.repetition){
  
  #PARAMETERS
  burn.in.iterations=10
  run.years=50
  
  #create folder to store results
  repetition.folder=paste("output/nofire/repetition_", current.repetition, sep="")
  dir.create(repetition.folder, recursive=TRUE)
  
  #PARAMETER CONFIGURATION
  #output folder
  NLCommand("set Output-path", paste("\"", repetition.folder, "\"", sep=""))
  
  #traits
  set.traits()
  
  #general parameters for all simulations
  NLCommand("set Snapshots?  \"no snapshots\"", 
            "set Draw-topography? FALSE", 
            "set RSAP-radius 50", 
            "set Randomness-settings  \"Free seed, non-deterministic results\"", 
            "set Max-biomass-per-patch 500", 
            "set Mortality? TRUE", 
            "set Burn-in-iterations ", burn.in.iterations)
  
  #deactivating fire
  NLCommand("set Fire? FALSE")
  
  #running setup procedure
  NLCommand("simulation-setup")
  
  #run simulation
  NLDoCommand(run.years, "simulation-run")
  
  #output
  output.table <- read.table(paste(repetition.folder, "/output_table.csv", sep=""), header=TRUE, sep=";", dec=".")
  return(output.table)
  
}

#stopping function
quit.netlogo <- function(x){
  NLQuit()
}



#NO FIRE SIMULATION
##############################################
##############################################
#setting up the cluster
cores <- detectCores()
cluster <- makeCluster(cores)
#exporting relevant functions to the cluster
clusterExport(cl=cluster, c('set.traits', 'netlogo.path', 'model.path'))

#loading netlogo on each processor
invisible(parLapply(cluster, 1:cores, initialize.model, netlogo.path=netlogo.path, model.path=model.path))

#number of repetitions
current.repetition <- 1:8

#running simulation
result.nofire.simulation <- parSapply(cluster, current.repetition, nofire.simulation)

#quit Netlogo in each processor
invisible(parLapply(cluster, 1:cores, quit.netlogo))

# stop cluster
stopCluster(cluster)
