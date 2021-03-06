#!/usr/bin/env python3

import os
import socket
import htcondor
import argparse

from glideinwms.factory import glideFactoryConfig as gfc
from glideinwms.factory.glideFactoryLib import ClientWeb, get_submit_environment
from glideinwms.factory.glideFactoryCredentials import (
    SubmitCredentials,
    validate_frontend,
)


def get_ads(collector, frontendName, targetEntry):
    constraint = (
        'MyType=="glideclient" && regexp("^%s@.*$", AuthenticatedIdentity) && regexp("^%s@.*$", ReqName)'
        % (frontendName, targetEntry)
    )
    res = collector.query(htcondor.AdTypes.Any, constraint, ["Name"])

    constraint = f'(MyType=="glideclient") && (Name=="{res[0]["Name"]}")'
    ads = collector.query(htcondor.AdTypes.Any, constraint)[0]

    return ads


def generate_submit_environment(
    idleLifetime=3600,
    targetEntry="fermicloud489",
    clientName="test.test",
    frontendName="vofrontend_service",
    wmsCollector=socket.gethostname(),
    asList=False,
):
    cwd = os.getcwd()
    os.chdir("/var/lib/gwms-factory/work-dir/")

    glideinDescript = gfc.GlideinDescript()
    frontendDescript = gfc.FrontendDescript()
    collector = htcondor.Collector(wmsCollector)
    ads = get_ads(collector, frontendName, targetEntry)

    clientWebURL = ads["WebURL"]
    clientSignType = ads["WebSignType"]
    clientDescript = ads["WebDescriptFile"]
    clientSign = ads["WebDescriptSign"]
    clientGroup = ads["GroupName"]
    clientGroupWebURL = ads["WebGroupURL"]
    clientGroupDescript = ads["WebGroupDescriptFile"]
    clientGroupSign = ads["WebGroupDescriptSign"]
    clientWeb = ClientWeb(
        clientWebURL,
        clientSignType,
        clientDescript,
        clientSign,
        clientGroup,
        clientGroupWebURL,
        clientGroupDescript,
        clientGroupSign,
    )

    glideinDescript.load_pub_key()
    symKeyObj, frontendSecName = validate_frontend(
        ads, frontendDescript, glideinDescript.data["PubKeyObj"]
    )
    securityClass = symKeyObj.decrypt_hex(ads["GlideinEncParamSecurityClass"]).decode(
        "utf-8"
    )
    proxyID = symKeyObj.decrypt_hex(ads["GlideinEncParamSubmitProxy"]).decode("utf-8")
    userName = frontendDescript.get_username(frontendSecName, securityClass)

    credentials = SubmitCredentials(userName, securityClass)
    credentials.id = proxyID
    credentials.cred_dir = (
        "/var/lib/gwms-factory/client-proxies/user_%s/glidein_gfactory_instance"
        % userName
    )
    credFile = "%s_%s" % (ads["ClientName"], proxyID)
    credentials.add_security_credential("SubmitProxy", credFile)

    params = {
        "entry_name": targetEntry,
        "client_name": clientName,
        "submit_credentials": credentials,
        "client_web": None,
        "params": {},
        "idle_lifetime": idleLifetime,
    }

    env = get_submit_environment(**params)

    if not asList:
        dictEnv = {}
        for i in env:
            key, value = i.split("=")
            dictEnv[key] = value
        env = dictEnv

    os.chdir(cwd)

    return env


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--entry", help="Target entry")
    parser.add_argument("--frontend", help="Frontend to impersonate")
    args = parser.parse_args()

    env = generate_submit_environment(asList=True)

    rootDir = os.path.dirname(os.path.abspath(__file__))
    os.chdir(rootDir)
    with open("job.env", "w") as fd:
        fd.write("\n".join(env))
