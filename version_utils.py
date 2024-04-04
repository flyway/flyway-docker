import re


def get_major_and_minor_version(version_number):
    return re.match(r"\d+\.\d+", version_number).group(0)


def get_major_version(version_number):
    return re.match(r"\d+", version_number).group(0)