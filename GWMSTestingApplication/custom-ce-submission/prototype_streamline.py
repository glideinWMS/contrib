#!/usr/bin/env python3

import argparse
import subprocess

# Parse arguments from the terminal
parser = argparse.ArgumentParser(description="Process this condor job")
parser.add_argument('GLIDEIN_COUNT', metavar='G', type=str, nargs=1)   
parser.add_argument('--name', dest='GLIDEIN_ENTRY_NAME', action='store', const=str, nargs='?')
parser.add_argument('GLIDEIN_EXECUT_TEST', metavar='execute')
parser.add_argument('jobenv', metavar='file', type=str)


args = parser.parse_args()

# Do some processing
print(f"Number of jobs: {args.GLIDEIN_COUNT}")
print(args)

jobenvfile = {}
with open(args.jobenv) as new:
    lines = new.readlines() 
    for i in lines:
        try:
            key, value = i.split("=")
            key = key.split(" ")[1]
            value = value.strip()
            jobenvfile[key] = value
        except ValueError:
            pass
jobenvfile["GLIDEIN_COUNT"] = args.GLIDEIN_COUNT[0]
jobenvfile["LOGSFILE"] = args.LOGSFILE[1]
jobenvfile["OUTPUTFILE"] = args.OUTPUTFILE[1]
jobenvfile["ERRORFILE"] = args.ERRORFILE[1]


# Call bash commands
p = subprocess.Popen(["/usr/kerberos/bin/condor_submit", "job.condor"], env= jobenvfile)
p.wait()

p = subprocess.Popen(["/usr/kerberos/bin/hostname"], stdout=subprocess.PIPE)
p.wait()



