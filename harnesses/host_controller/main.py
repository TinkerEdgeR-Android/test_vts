#!/usr/bin/env python
#
# Copyright (C) 2017 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import argparse
import json
import logging
import socket
import threading
import sys

from vts.harnesses.host_controller import console
from vts.harnesses.host_controller import host_controller
from vts.harnesses.host_controller.tfc import tfc_client
from vts.harnesses.host_controller.tradefed import remote_client


def main():
    """Parses arguments and starts console."""
    parser = argparse.ArgumentParser()
    parser.add_argument("config_file", type=argparse.FileType('r'),
                        help="The configuration file in JSON format")
    parser.add_argument("--poll", action="store_true",
                        help="Disable console and start host controller "
                             "threads polling TFC.")
    args = parser.parse_args()
    config_json = json.load(args.config_file)

    root_logger = logging.getLogger()
    root_logger.setLevel(getattr(logging, config_json["log_level"]))

    tfc = tfc_client.CreateTfcClient(
            config_json["tfc_api_root"],
            config_json["service_key_json_path"],
            api_name=config_json["tfc_api_name"],
            api_version=config_json["tfc_api_version"],
            scopes=config_json["tfc_scopes"])

    hosts = []
    for host_config in config_json["hosts"]:
        cluster_ids = host_config["cluster_ids"]
        # If host name is not specified, use local host.
        hostname = host_config.get("hostname", socket.gethostname())
        port = host_config.get("port", remote_client.DEFAULT_PORT)
        cluster_ids = host_config["cluster_ids"]
        remote = remote_client.RemoteClient(hostname, port)
        host = host_controller.HostController(remote, tfc, hostname,
                                              cluster_ids)
        hosts.append(host)
        if args.poll:
            lease_interval_sec = host_config["lease_interval_sec"]
            host_thread = threading.Thread(target=host.Run,
                                           args=(lease_interval_sec,))
            host_thread.daemon = True
            host_thread.start()

    if args.poll:
        while True:
            sys.stdin.readline()
    else:
        console.Console(tfc, hosts).cmdloop()


if __name__ == "__main__":
    main()