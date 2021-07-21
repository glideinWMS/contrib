#!/usr/bin/env python3

import argparse
import subprocess
import os
import re
import tempfile
import shutil

from generate_submit_environment import generate_submit_environment

#Find Absolute and Working Directory Paths 

#job.env
WORK_DIR = os.getcwd()
print(f"User working directory: {WORK_DIR}")

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
print(f"Script root directory: {ROOT_DIR}")

# /var/lib/gwms-factory/work-dir/entry_fermicloud528/job.condor
# /var/lib/gwms-factory/work-dir/entry_fermicloud489/job.condor
def make_condor(args):
    jobconFile = "/var/lib/gwms-factory/work-dir/" + str(args.GLIDEIN_ENTRY_NAME) + "/job.condor"
    sub_list = [
        (r"Log\s=\s.*", "Log = $ENV(LOGFILE)"),
        (r"\bOutput\s=\s.*", "Output = $ENV(OUTPUTFILE)"),
        (r"Error\s=\s.*", "Error = $ENV(ERRORFILE)")
    ]
    tf = tempfile.NamedTemporaryFile("w", delete=False)
    file = open(jobconFile, "r").read()
    
    for s in sub_list:
        file = re.sub(s[0], s[1], file)
    tf.writelines(file)
    tf.close()

    # Make a temporary copy of the condor file
    # Change the temporary file variables to fit out needs
    # Write the new temporary file
    return tf.name # return the temporary file path
# jobconFile = ROOT_DIR + "/job.condor"

def submit(jobenvFile, jobconFile):
    # Call condor_submit
    p = subprocess.Popen(["/usr/bin/condor_submit", jobconFile], env=jobenvFile, stdout=subprocess.PIPE, stderr=subprocess.STDOUT) #subprocess. tells python where the name is coming from
    p.wait()
    return p.stdout.read() #returns the standard output back to caller 

def make_environment(args):
    #logs

    if not os.path.isabs(args.LOGFILE):
        args.LOGFILE = WORK_DIR + "/" + args.LOGFILE
    logFile = args.LOGFILE


    #outputs

    if not os.path.isabs(args.OUTPUTFILE):
        args.OUTPUTFILE = WORK_DIR + "/" + args.OUTPUTFILE
    outFile = args.OUTPUTFILE


    #errors

    if not os.path.isabs(args.ERRORFILE):
        args.ERRORFILE = WORK_DIR + "/" + args.ERRORFILE
    errorFile = args.ERRORFILE


    #executable

    if not os.path.isabs(args.GLIDEIN_EXECUT_TEST):
        args.GLIDEIN_EXECUT_TEST = WORK_DIR + "/" + args.GLIDEIN_EXECUT_TEST
    execFile = args.GLIDEIN_EXECUT_TEST


    # Do some processing
    print(f"Number of jobs: {args.GLIDEIN_COUNT}")
    print(args)

    env = generate_submit_environment()
    env["GLIDEIN_COUNT"] = str(args.GLIDEIN_COUNT)
    env["LOGFILE"] = logFile
    env["OUTPUTFILE"] = outFile
    env["ERRORFILE"] = errorFile
    env["GLIDEIN_EXECUT_TEST"] = execFile

    return env

if __name__ == "__main__":
    # Parse arguments from the terminal
    parser = argparse.ArgumentParser(description="Process this condor job")
    parser.add_argument('GLIDEIN_COUNT', type=int)   
    # parser.add_argument('--entry-name', dest='GLIDEIN_ENTRY_NAME', action='store', const=str, nargs='?')
    parser.add_argument('GLIDEIN_ENTRY_NAME')
    parser.add_argument('GLIDEIN_EXECUT_TEST')
    parser.add_argument('LOGFILE')
    parser.add_argument('OUTPUTFILE')
    parser.add_argument('ERRORFILE')
    args = parser.parse_args()

    env = make_environment(args)
    condor = make_condor(args)
    print(condor)
    print(submit(env, condor))
