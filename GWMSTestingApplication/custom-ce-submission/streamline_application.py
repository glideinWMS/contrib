#!/usr/bin/env python3

import argparse
import subprocess
import os

#Find Absolute and Working Directory Paths 

#job.env
WORK_DIR = os.getcwd()
print(f"User working directory: {WORK_DIR}")

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
print(f"Script root directory: {ROOT_DIR}")

jobenv_direct = ROOT_DIR + "/job.env"
jobcon_direct = ROOT_DIR + "/job.condor"

def submit(jobenvfile):
    # Call condor_submit
    p = subprocess.Popen(["/usr/kerberos/bin/condor_submit", jobcon_direct], env=jobenvfile)
    p.wait()

def make_environment(args):
    #logs
    log_direct = args.LOGFILE


    if not os.path.isabs(args.LOGFILE):
        args.LOGFILE = WORK_DIR + "/" + args.LOGFILE
    log_direct = args.LOGFILE

    #outputs
    out_direct = args.OUTPUTFILE


    if not os.path.isabs(args.OUTPUTFILE):
        args.OUTPUTFILE = WORK_DIR + "/" + args.OUTPUTFILE
    out_direct = args.OUTPUTFILE


    #errors
    err_direct = args.ERRORFILE


    if not os.path.isabs(args.ERRORFILE):
        args.ERRORFILE = WORK_DIR + "/" + args.ERRORFILE
    err_direct = args.ERRORFILE


    #executable
    exec_direct = args.GLIDEIN_EXECUT_TEST


    if not os.path.isabs(args.GLIDEIN_EXECUT_TEST):
        args.GLIDEIN_EXECUT_TEST = WORK_DIR + "/" + args.GLIDEIN_EXECUT_TEST
    exec_direct = args.GLIDEIN_EXECUT_TEST


    # Do some processing
    print(f"Number of jobs: {args.GLIDEIN_COUNT}")
    print(args)

    jobenvfile = {}
    with open(jobenv_direct) as new:
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
    jobenvfile["LOGFILE"] = log_direct
    jobenvfile["OUTPUTFILE"] = out_direct
    jobenvfile["ERRORFILE"] = err_direct
    jobenvfile["GLIDEIN_EXECUT_TEST"] = args.GLIDEIN_EXECUT_TEST

    return jobenvfile

if __name__ == "__main__":
    # Parse arguments from the terminal
    parser = argparse.ArgumentParser(description="Process this condor job")
    parser.add_argument('GLIDEIN_COUNT')   
    parser.add_argument('--name', dest='GLIDEIN_ENTRY_NAME', action='store', const=str, nargs='?')
    parser.add_argument('GLIDEIN_EXECUT_TEST')
    parser.add_argument('LOGFILE')
    parser.add_argument('OUTPUTFILE')
    parser.add_argument('ERRORFILE')
    args = parser.parse_args()

    env = make_environment(args)
    submit(env)
