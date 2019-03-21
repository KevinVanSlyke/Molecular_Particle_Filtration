# -*- coding: utf-8 -*-
"""
Created on Fri Aug 18 14:46:50 2017

@author: Kevin Van Slyke
"""
from LAMMPS_input_generator import LAMMPS_input_generator
from LAMMPS_sbatch_generator import LAMMPS_sbatch_generator
import random
import os
import shutil
import time

nTrialEnsemble = 20 #number of trials with differing random seed but otherwise identical parameters to create
timeout = 48 #hours
#filterSpacing = [100]

#registryShift = [10,100,200]
#poreWidth = [20, 50, 200]
#impurityDiamter = [1]
poreWidth = [20]
#poreSpacing = [20, 100, 200, 1000]
poreSpacing = [20]
#impurityDiameter = [1,5]
impurityDiameter = [1,10]
movies = False
pyDir = os.getcwd()
os.chdir('..')
projDir = os.getcwd()
simDir = os.path.join(projDir, 'Simulation_Files/')
os.chdir(simDir)
ensembleDir = 'Simulation_Ensemble_' + time.strftime("%m_%d_%Y")
if movies == True:
    ensembleDir = 'Local_' + ensembleDir
if not os.path.exists(ensembleDir):
    os.makedirs(ensembleDir)
shutil.copy2(os.path.join(pyDir, 'Nth_LAMMPS_restart_generator.py'),ensembleDir)
shutil.copy2(os.path.join(pyDir, 'run_Nth_LAMMPS_restarts.py'),ensembleDir)
shutil.copy2(os.path.join(pyDir, 'delete_extra_ensemble_files.py'),ensembleDir)
os.chdir(ensembleDir)

for width in poreWidth:
    for diameter in impurityDiameter:
        for spacing in poreSpacing:
            if movies == False:
                #paramDir = '{0}W_{1}D_{2}F'.format(width, diameter,spacing)
                paramDir = '{0}W_{1}D_{2}F'.format(width, diameter, spacing)
                if not os.path.exists(paramDir):
                    os.makedirs(paramDir)
                os.chdir(paramDir)
                LAMMPS_input_generator(width, spacing, diameter, movies)
                LAMMPS_sbatch_generator(width, spacing, diameter, nTrialEnsemble, timeout)
                os.chdir('..')
            else:
                seed = random.seed()
                randomSeed = []
                for i in xrange(6):
                    randomSeed.append(random.randint(i+1,(i+1)*100000))
                LAMMPS_input_generator(width, spacing, diameter, movies)

                    
                
#    for impurityDiameter in [2,10]:
#        for poreWidth in [20, 50, 200]:
#            LAMMPS_files_generator(randomSeed, impurityDiameter, poreWidth, filterSpacing)
#    os.chdir(trialsDir)    
    
    #for firstVar in range(2,42):
        #for secondVar in [2, 5, 10]:
            #LAMMPS_files_generator(randomSeed, firstVar, secondVar)
            #os.chdir(simDir)
            #for thirdVar in [secondVar*2, secondVar*4]:
                #LAMMPS_files_generator(randomSeed, firstVar, secondVar, thirdVar)
                #os.chdir(simDir)
                #for fourthVar in [5000, 20000]:
                    #LAMMPS_files_generator(randomSeed, firstVar, secondVar, thirdVar, fourthVar)
                    #os.chdir(simDir)