#!/usr/bin/env python3

import argparse
import subprocess
import os
import re
import tempfile
import shutil

from generate_submit_environment import generate_submit_environment


WORK_DIR = os.getcwd()
print(f"User working directory: {WORK_DIR}")

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
print(f"Script root directory: {ROOT_DIR}")


def make_condor(args):
    jobconFile = "/var/lib/gwms-factory/work-dir/entry_" + str(args.ENTRY_NAME) + "/job.condor"
    sub_list = [
        (r"\bLog\s=\s.*", "Log = $ENV(LOGFILE)"),
        (r"\bOutput\s=\s.*", "Output = $ENV(OUTPUTFILE)"),
        (r"\bError\s=\s.*", "Error = $ENV(ERRORFILE)"),
        (r"\bExecutable\s=\s.*", "Executable = $ENV(EXECUTABLE)")
    ]
    tf = tempfile.NamedTemporaryFile("w", delete=False) 
    file = open(jobconFile, "r").read() #make a temporary copy of the condor file
    
    for s in sub_list: #change the temporary file variables
        file = re.sub(s[0], s[1], file)
    tf.writelines(file) #write a new temporary file
    tf.close()

    return tf.name # return the temporary file path

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

    if not os.path.isabs(args.ERRORFILE):
        args.EXECUTABLE = WORK_DIR + "/" + args.EXECUTABLE
    execFile = args.EXECUTABLE


    # Do some processing
    print(f"Number of jobs: {args.GLIDEIN_COUNT}")
    print(args)

    env = generate_submit_environment()
    env["GLIDEIN_COUNT"] = str(args.GLIDEIN_COUNT)
    env["LOGFILE"] = logFile
    env["OUTPUTFILE"] = outFile
    env["ERRORFILE"] = errorFile
    env["EXECUTABLE"] = execFile
    env["ARGUMENTS"] = str(" ".join(exec_args))

    return env

if __name__ == "__main__":
    # Parse arguments from the terminal
    parser = argparse.ArgumentParser(description="Process this condor job")
    parser.add_argument('--logfile', dest='LOGFILE', default='job.log')
    parser.add_argument('--outfile', dest='OUTPUTFILE', default='job.out')
    parser.add_argument('--errfile', dest='ERRORFILE', default='job.err')
    parser.add_argument('-n', dest='GLIDEIN_COUNT', type=int, default=1)
    parser.add_argument('ENTRY_NAME')
    parser.add_argument('EXECUTABLE', metavar='EXECUTABLE [ARGUMENTS]')
    args, exec_args = parser.parse_known_args()

    env = make_environment(args)
    condor = make_condor(args)
    print(condor)
    print(submit(env, condor))
