# aws-auth-script

## Description

This script allows to get new auth keys from AWS for 9-hour access.

It's is supposed, that you can do all the stuff via `aws-iam-authenticator` and `aws` cli, which is boring, the script helps avoid that routine.

The script assumes, that your user is created in `IAM` and has enabled `MFA`.

## Preparations

1. It is assumed, that you already have `<homefolder>/.aws/credentials` file with `default` profile.

    The `default` profile must contain your `Access` and `Secret`  keys, generated with AWS Console web app.

    ```ini
    [default]
    aws_access_key_id = AKAS12313123asd
    aws_secret_access_key = asdfsar123123ASD131zxsas1123szfdasddsf32
    ```

## Installation

1. Copy script file to any `Path` folder
1. Define `AWS_MFA_SERIAL_NUMBER` environment variable with value like `arn:aws:iam::1234567890123:mfa/kuser`.

    You can get this value from you user edit page in `IAM`.

## Usage

1. Open terminal and run the script.
1. Provide MFA Identifier, if you did not define `AWS_MFA_SERIAL_NUMBER` environment variable.
1. Provide MFA Verification code from your MFA device.

The script creates `mfa` profile in your `<homefolder>/.aws/credentials` file.

```ini
[mfa]
aws_access_key_id = AS123AVCSDF23ASDF
aws_secret_access_key = 312SDFASD2134ZDFASDf4345SADFASDF23423AS
aws_session_token = <long-long-very-long-string-here>
```

Use that profile to access to Amazon Console.

You can specify it in commands:

```powershell
aws s3 ls --profile mfa
```

Or you can set default profile in environment variable:

* bash:

    ```bash
    echo "\nexport AWS_PROFILE=mfa\n" >> ~/.bashrc
    ```

* pwsh

    ```powershell
    [System.Environment]::SetEnvironmentVariable("AWS_PROFILE", "mfa", "User")
    ```
