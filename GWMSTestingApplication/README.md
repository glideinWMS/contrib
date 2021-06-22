Particle physics requires copious computing resources to extract physics results. Such resources are delivered by various systems: local batch farms, grid sites, private and commercial clouds, and supercomputing centers. High Performance Computing (HPC) centers have always been an opportunity and a challenge due to the uniqueness of their architectures. GlideinWMS is a workflow manager provisioning resources for scientific computing. It is used by many collaborations including the LHC experiment CMS, all the FIFE experiments at Fermilab and by the HEPCloud portal. It simplifies greatly the use of computing resources for problems that can be broken down into chunks executed on multiple nodes.
This project will work into streamlining complex workflows that make use of parallel processing and take advantage of HPC specificities like several hundreds of TB of memory. Specifically, it will consist in optimizing and making production ready a highly parallel data selection (skimming) workflow. The data will be loaded in memory and, taking advantage of the high bandwidth, thousands of processes will work in parallel to select O(10^2) events out of O(10^12) subevents. This is a very important workflow for HEP (High Energy Physics) experiments, including DUNE, Fermilab's flagship neutrino experiment, and we plan to run it on supercomputers, including at NERSC and at the Argonne Leadership Computing Facilities.

In short, this project will accomplish the following: Help to extend GlideinWMS to streamline the execution on supercomputers of highly parallel data selection workflows (skimming) used in High Energy Physics experiments; Allow scientists to submit many skimming requests to a queue; Allow GlideinWMS split each skimming in a trillion of concurrent event selections executing in parallel and accessing data in memory on computers with close to a petabyte of RAM. It is like picking with a single look the few key photograms of a movie with a trillion images; and allow GlideinWMS to deliver the results, use efficiently the resources and hide the complexity.

Timeline of Project:

First Semester:
September-November: Continue Summer Work of constructing Testing application; modifying and updating the scripts

November-December: Begin rerunning the testing application with GlideinWMS software

Second Semester:
January-February: Start final review/paper on project

April: Complete paper and begin creating poster for Honors College symposium