import sys
import re


def validate_version(version_number):
    if re.fullmatch(r"\d+\.\d+\.\d+(-beta\d?)?$", version_number) is None:
        print(f'Version number {version_number} provided does not match expected format')
        exit(1)
        
        
def update_versions_in_readme(version_number):
    minor_version = re.match(r"\d+\.\d+", version_number).group(0)
    major_version = re.match(r"\d+", version_number).group(0)
    
    readme_file = open("./README.md", 'r')
    readme_content = readme_file.read()
    readme_file.close()
    
    readme_content, _ = re.subn(r"(?<=`)\d+\.\d+\.\d+(-beta\d?)?(?=(-(alpine|azure))?`)", version_number, readme_content)
    readme_content, _ = re.subn(r"(?<=`)\d+\.\d+(?=(-(alpine|azure))?`)", minor_version, readme_content)
    readme_content, _ = re.subn(r"(?<=`)\d+(?=(-(alpine|azure))?`)", major_version, readme_content)
    
    readme_file = open("./README.md", 'w')
    readme_file.write(readme_content)
    readme_file.close()
        

if __name__ == "__main__":
    version = sys.argv[1]
    validate_version(version)
    update_versions_in_readme(version)
    