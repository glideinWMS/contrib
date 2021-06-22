import os
import re
import datetime
import uuid
import streamline_application_module as submod #submission module
from zipfile import ZipFile
from os.path import basename
from types import SimpleNamespace
from requests import request
from subprocess import check_output
from flask import Flask, request, send_file, redirect, url_for, session
app = Flask(__name__)
app.secret_key = b'_5#y2L"F4Q8z\n\xec]/'
app.config['SEND_FILE_MAX_AGE_DEFAULT'] = 0
ROOT_DIR = os.path.dirname(os.path.abspath(__file__))
LOG_DIR = ROOT_DIR+"/logs/{}"

@app.route('/')
def intro():
    html = open(f"{ROOT_DIR}/streamline_app.html").read()
    
    html = html.replace(
        "[QUEUE_URL]", f"{request.url_root}queue"
    )
    return html

@app.route('/log', methods=['GET'])
def log():
    UUID = request.args.get('uuid')
    today = datetime.datetime.now().strftime("%Y-%m-%d_%H-%M-%S")


    zippath = f'{LOG_DIR.format(UUID)}/logdownloads_{today}.zip'

    with ZipFile(zippath, 'w') as zipObj:
        for folderName, subfolders, filenames in os.walk(LOG_DIR.format(UUID)):
            for filename in filenames:
                #create complete filepath of file in directory
                filePath = os.path.join(folderName, filename)
                if os.path.abspath(filePath) == zippath:
                    continue
                # Add file to zip
                zipObj.write(filePath, basename(filePath))

    return send_file(zippath, as_attachment=True)

@app.route('/result', methods=['POST']) 
def result():
    UUID = session['uuid']
    return f"To retreive logs, click <a href={request.url_root}log?uuid={UUID}>this link</a>"

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

@app.route('/submit', methods=['POST'])
def submit():
    UUID = uuid.uuid4()
    session['uuid'] = UUID
    count = request.form.get("payload")
    executable = request.files.get("file")
    arguments = request.form.get("args")
    args = SimpleNamespace()
    args.GLIDEIN_COUNT = count
    args.ARGUMENTS = arguments
    args.GLIDEIN_EXECUT_TEST=f"{LOG_DIR.format(UUID)}/userexecutable"
    args.LOGFILE=f"{LOG_DIR.format(UUID)}/test.log"
    args.OUTPUTFILE=f"{LOG_DIR.format(UUID)}/test.out"
    args.ERRORFILE=f"{LOG_DIR.format(UUID)}/test.err"

    try:
        os.mkdir(f"{ROOT_DIR}/logs")
    except FileExistsError:
        pass 

    os.mkdir(LOG_DIR.format(UUID))

    executable.save(f"{LOG_DIR.format(UUID)}/userexecutable")
    env = submod.make_environment(args)
    submission = submod.submit(env)
    print(submission)

    return redirect(url_for("result"), code=307)