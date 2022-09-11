import base64
import json
import os
from typing import Optional, TypedDict

SECRETS_DIRECTORY = "Secrets"
PROVISIONING_PROFILE = "Tasktivity_App_Store_distribution.mobileprovision"
SIGNING_CERTIFICATE = "Certificates.p12"


class Certificates(TypedDict):
    provisioning_profile: Optional[str]
    signing_certificate: Optional[str]


def main():
    certificates_data = make_certificates_dict()

    write_certificates_json(certificates_data=certificates_data)

    print("done encoding certificates ✨✨✨")


def write_certificates_json(*, certificates_data: Certificates):
    certificates_json = json.dumps(certificates_data, indent=2)
    certificates_json_filepath = os.path.join(SECRETS_DIRECTORY, "certificates.json")

    with open(certificates_json_filepath, "w") as file:
        file.write(certificates_json)


def make_certificates_dict():
    certificates: Certificates = {}

    for filename in os.listdir(SECRETS_DIRECTORY):
        if filename == PROVISIONING_PROFILE:
            certificates["provisioning_profile"] = encode_certificate(filename=filename)
        if filename == SIGNING_CERTIFICATE:
            certificates["signing_certificate"] = encode_certificate(filename=filename)

    return certificates


def encode_certificate(*, filename: str):
    filepath = os.path.join(SECRETS_DIRECTORY, filename)

    with open(filepath, "rb") as file:
        return base64.b64encode(file.read()).decode("utf-8")


main()
