import sys
import urllib.request
from urllib.error import HTTPError
import time


def get_repo_url(edition, version):
    if edition == "flyway":
        return f'https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/{version}/flyway-commandline-{version}.tar.gz'
    if edition == "redgate":
        return f'https://download.red-gate.com/maven/release/org/flywaydb/enterprise/flyway-commandline/{version}/flyway-commandline-{version}.tar.gz'
    print("Edition should be 'flyway' or 'redgate'")
    exit(1)
    

if __name__ == "__main__":
    edition = sys.argv[1]
    version = sys.argv[2]
    url = get_repo_url(edition, version)
    
    while True:
        try:
            response = urllib.request.urlopen(url)
            artifact_file = open(f'flyway-commandline-{version}.tar.gz', 'wb')
            artifact_file.write(response.read())
            response.close()
            artifact_file.close()
            break
        except HTTPError:
            time.sleep(2)
            print("Unable to download artifacts. Trying again in 2 seconds...")
    