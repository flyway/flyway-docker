from build_images import get_buildx_command, get_tags
import subprocess
import sys


def get_push_command(edition, tag):
    return f'docker push {edition}/flyway:{tag}'


if __name__ == "__main__":
    edition = sys.argv[1]
    version = sys.argv[2]

    release_commands = []
    tags = []
    if edition == "flyway":
        # Multi-arch images are pushed using the buildx command
        release_commands.append(get_buildx_command(edition, "linux/arm/v7,linux/arm64/v8,linux/amd64", version, "", ".", True))
        tags.extend(get_tags(version, "-alpine"))
        tags.extend(get_tags(version, "-azure"))
    else:
        tags.extend(get_tags(version, ""))
        tags.extend(get_tags(version, "-alpine"))
        tags.extend(get_tags(version, "-azure"))

    release_commands.extend([get_push_command(edition, tag) for tag in tags])

    for command in release_commands:
        print(command)
        subprocess.run(command)
