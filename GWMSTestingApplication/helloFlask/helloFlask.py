import os
import re
import datetime
from subprocess import check_output
from flask import Flask, request, send_file
app = Flask(__name__)

ROOT_DIR = os.path.dirname(os.path.abspath(__file__))

@app.route('/')
def hello_world():
    helloFlask = open(f"{ROOT_DIR}/helloFlask.html").read()
    helloFlask = helloFlask.replace(
        "[SHELL_TIME]", check_output(["/usr/kerberos/bin/date"])[:-1].decode()
    )
    helloFlask = helloFlask.replace(
        "[PYTHON_TIME]", str(datetime.datetime.now().time())
    )
    return helloFlask

@app.route('/log')
def download_log():
    log_path = f"{ROOT_DIR}/test.log"
    return send_file(log_path, as_attachment=True)

@app.route('/handle', methods=['POST'])
def handle():
    payload = request.form.get("payload")
    return f"Value sent by POST: \"{payload}\""

@app.route('/queue')
def queue():
    condor_q = check_output(["/usr/kerberos/bin/condor_q"])[:-1].decode()

    # Parses the default output of condor_q: https://regex101.com/r/En6S0I/1
    regex = r"(\w+)\s+(ID\:\s+\d+)\s+(\d{1,2}\/\d{1,2}\s+\d{1,2}\:\d{1,2})\s+([\_\d]+)" \
            r"\s+([\_\d]+)\s+([\_\d]+)\s+([\_\d]+)\s+(?:([\_\d]+)\s+)?(\d+\.\d+(?:\-\d+)?)"
    
    parser = re.compile(regex)
    lines = parser.findall(condor_q)
    
    headers = tuple(condor_q.strip().split("\n")[1].split())
    lines.insert(0, headers)

    html_table = "<table border=1>"
    for line in lines:
        html_table += "<tr>"
        for column in line:
            if column:
                html_table += f"<td>{column}</td>"
        html_table += "</tr>"
    html_table += "</table>"

    print(html_table)
    return html_table
