import sys
import urllib.request
from urllib.error import HTTPError
import time


def get_repo_url(edition, version, artifact_suffix):
    if edition == "flyway":
        return f'https://repo1.maven.org/maven2/org/flywaydb/flyway-commandline/{version}/flyway-commandline-{version}{artifact_suffix}.tar.gz'
    if edition == "redgate":
        return f'https://download.red-gate.com/maven/release/com/redgate/flyway/flyway-commandline/{version}/flyway-commandline-{version}{artifact_suffix}.tar.gz'
    print("Edition should be 'flyway' or 'redgate'")
    exit(1)

def await_and_download_artifact(url, file):
    i = 100
    while i > 0:
        try:
            response = urllib.request.urlopen(url)
            artifact_file = open(file, 'wb')
            artifact_file.write(response.read())
            response.close()
            artifact_file.close()
            return True
        except HTTPError:
            time.sleep(2)
            print(f"Unable to download artifact: {url}. Trying again in 2 seconds...")
            i -= 1
    return False

def await_and_download_rg_artifact(edition, version, artifact_suffix):
    url = get_repo_url(edition, version, artifact_suffix)
    return await_and_download_artifact(url, f'flyway-commandline-{version}{artifact_suffix}.tar.gz')

def await_and_download_mongosh(version):
    url = f'https://downloads.mongodb.com/compass/mongosh-{version}-linux-x64.tgz'
    file = 'mongosh-linux.tgz'
    return await_and_download_artifact(url, file)

if __name__ == "__main__":
    edition = sys.argv[1]
    version = sys.argv[2]
    success = await_and_download_rg_artifact(edition, version, "")
    success &= await_and_download_rg_artifact(edition, version, "-linux-alpine-x64")
    success &= await_and_download_mongosh("2.3.4")
    if not success:
        exit(1)
    
