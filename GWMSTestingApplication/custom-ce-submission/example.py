#!/usr/bin/env python3

import streamline_application_module as app
from types import SimpleNamespace
from requests import request

### WEB APP ###

### Request Parser ###

args = SimpleNamespace()
args.GLIDEIN_COUNT=100
args.GLIDEIN_EXECUT_TEST="/usr/kerberos/bin/hostname"
args.LOGFILE="logs/test.log"
args.OUTPUTFILE="logs/test.out"
args.ERRORFILE="logs/test.err"

env = app.make_environment(args)
app.submit(env)

request("get", url="https://fermicloud189.fnal.gov:8583/submit?say=Hi&to=Mom")

# https://fermicloud189.fnal.gov:8583/
# https://fermicloud189.fnal.gov:8583/submit?say=Hi&to=Mom
