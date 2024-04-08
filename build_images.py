import sys
import version_utils
import os


def get_tags(version, tag_suffix):
    tags = ["latest", version, version_utils.get_major_and_minor_version(version), version_utils.get_major_version(version)]
    return [t + tag_suffix for t in tags]


def get_tag_flags(version, edition, tag_suffix):
    tags = get_tags(version, tag_suffix)
    command_flags = ""
    for tag in tags:
        command_flags += f'-t {edition}/flyway:{tag} '
    return command_flags


def get_buildx_command(edition, platforms, version, tag_suffix, folder, push=False):
    pull_or_push = "pull"
    if push:
        pull_or_push = "push"
    command = f'docker buildx build --target {edition} --platform {platforms} --{pull_or_push} --build-arg FLYWAY_VERSION={version} '
    command += get_tag_flags(version, edition, tag_suffix)
    return command + folder
    
    
def get_build_command(edition, version, tag_suffix, folder):
    command = f'docker build --target {edition} --pull --build-arg FLYWAY_VERSION={version} '
    command += get_tag_flags(version, edition, tag_suffix)
    file_flag = f'-f {folder}/Dockerfile '
    return command + file_flag + "."
    

if __name__ == "__main__":
    edition = sys.argv[1]
    version = sys.argv[2]
    
    commands = []
    if edition == "flyway":  # We only do multi-arch builds for OSS due to compatibility issues with Redgate Compare
        commands.append("docker buildx rm multi_arch_builder")
        commands.append("docker run --rm --privileged multiarch/qemu-user-static --reset -p yes")
        commands.append("docker buildx create --name multi_arch_builder --driver docker-container --driver-opt network=bridge --use")
        commands.append(get_buildx_command(edition, "linux/arm/v7,linux/arm64/v8,linux/amd64", version, "", "."))
    else:
        commands.append(get_build_command(edition, version, "", "."))
    commands.append(get_build_command(edition, version, "-alpine", "./alpine"))
    commands.append(get_build_command(edition, version, "-azure", "./azure"))
    
    for command in commands:
        print(f'Running docker build command: {command}')
        os.system(command)
