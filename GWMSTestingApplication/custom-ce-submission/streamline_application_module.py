#!/usr/bin/env python3

import argparse
import subprocess
import os

from generate_submit_environment import generate_submit_environment

#Find Absolute and Working Directory Paths 

#job.env
WORK_DIR = os.getcwd()
print(f"User working directory: {WORK_DIR}")

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
print(f"Script root directory: {ROOT_DIR}")

# /var/lib/gwms-factory/work-dir/entry_fermicloud528/job.condor
jobcon_direct = ROOT_DIR + "/job.condor"


def submit(jobenvfile):
    # Call condor_submit
    p = subprocess.Popen(["/usr/bin/condor_submit", jobcon_direct], env=jobenvfile, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) #subprocess. tells python where the name is coming from
    p.wait()
    return p.stdout.read() #returns the standard output back to caller 

def make_environment(args):
    #logs

    if not os.path.isabs(args.LOGFILE):
        args.LOGFILE = WORK_DIR + "/" + args.LOGFILE
    log_direct = args.LOGFILE


    #outputs

    if not os.path.isabs(args.OUTPUTFILE):
        args.OUTPUTFILE = WORK_DIR + "/" + args.OUTPUTFILE
    out_direct = args.OUTPUTFILE


    #errors

    if not os.path.isabs(args.ERRORFILE):
        args.ERRORFILE = WORK_DIR + "/" + args.ERRORFILE
    err_direct = args.ERRORFILE


    #executable

    if not os.path.isabs(args.GLIDEIN_EXECUT_TEST):
        args.GLIDEIN_EXECUT_TEST = WORK_DIR + "/" + args.GLIDEIN_EXECUT_TEST
    exec_direct = args.GLIDEIN_EXECUT_TEST


    # Do some processing
    print(f"Number of jobs: {args.GLIDEIN_COUNT}")
    print(args)

    env = generate_submit_environment()
    env["GLIDEIN_COUNT"] = str(args.GLIDEIN_COUNT)
    env["LOGFILE"] = log_direct
    env["OUTPUTFILE"] = out_direct
    env["ERRORFILE"] = err_direct
    env["GLIDEIN_EXECUT_TEST"] = exec_direct

    return env

if __name__ == "__main__":
    # Parse arguments from the terminal
    parser = argparse.ArgumentParser(description="Process this condor job")
    parser.add_argument('GLIDEIN_COUNT', type=int)   
    parser.add_argument('--entry-name', dest='GLIDEIN_ENTRY_NAME', action='store', const=str, nargs='?')
    parser.add_argument('GLIDEIN_EXECUT_TEST')
    parser.add_argument('LOGFILE')
    parser.add_argument('OUTPUTFILE')
    parser.add_argument('ERRORFILE')
    args = parser.parse_args()

    env = make_environment(args)
    print(submit(env))
