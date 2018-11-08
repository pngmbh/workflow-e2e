#!/usr/bin/env bash
#
# This program is suppsoed to be run inside the workflow-e2e docker container
# to download the workflow CLI at runtime and run the integration tests.
set -eo pipefail

function debug {
	if [ "${DEBUG_MODE}" == "true" ]; then
		filename="/tmp/deis_debug"
		touch "${filename}"
		echo "Sleeping until ${filename} is deleted"

		while [ -f "${filename}" ]
		do
			sleep 2
		done
	fi
}

trap debug ERR

CLI_URL="https://github.com/pngmbh/workflow-cli/releases/download/${CLI_VERSION}/deis-latest-linux-amd64"
echo "getting workflow-cli binary from $CLI_URL"
curl -L -f --silent --show-error --retry 5 --retry-delay 10 -o /usr/local/bin/deis  "$CLI_URL"
chmod +x /usr/local/bin/deis

echo "Workflow CLI Version '$(deis --version)' installed."

if [ "$TEST" == "bps" ]; then
	make test-buildpacks
	make test-dockerfiles
else
	make test-integration
fi
