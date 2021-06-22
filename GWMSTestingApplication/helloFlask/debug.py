import re
from subprocess import check_output

condor_q = check_output(["/usr/kerberos/bin/condor_q"])[:-1].decode()

# Parses the default output of condor_q: https://regex101.com/r/J4b86v/1
regex = r"(\w+)\s+(ID\:\s+\d+)\s+(\d{1,2}\/\d{1,2}\s+\d{1,2}\:\d{1,2})\s+([\_\d]+)" \
            r"\s+([\_\d]+)\s+([\_\d]+)\s+([\_\d]+)\s+(?:([\_\d]+)\s+)?(\d+\.\d+(?:\-\d+)?)"

parser = re.compile(regex)
match = parser.findall(condor_q)
pass