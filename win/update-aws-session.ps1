
# Help functions

function err {
    $allArgs = ($PsBoundParameters.Values + $args) -join " "
    Write-Error $allArgs
}

# Verify jq is installed

& jq --version >$null

if ($LASTEXITCODE -ne 0) {
    err "Please, install jq for parsing json"
    exit 10
}

# Main

$serialNumber=$Env:AWS_MFA_SERIAL_NUMBER

if  (! $serialNumber ){
    Write-Output "Please, provide your MFA serial number"
    Write-Output "You can define AWS_MFA_SERIAL_NUMBER environment variable in order not to input the value over and over"
    Write-Output "Example: arn:aws:iam::1234567890123:mfa/kuser"
    $serialNumber = Read-Host "MFA Serial Number: "
    $AWS_MFA_SERIAL_NUMBER=$serialNumber
}

Write-Output "MFS Serial Number: $serialNumber"

$tokenCode = Read-Host "Enter MFA Verification Code: "

$result=$(aws sts get-session-token --serial-number $serialNumber --token-code $tokenCode)

if ( $LASTEXITCODE -ne 0 ) {
    err "Can't retrive session keys from AWS using provided values. Please, check the values and try again."
    exit 42
}

$AWS_ACCESS_KEY_ID=$($result | jq  -r ".Credentials.AccessKeyId")
$AWS_SECRET_ACCESS_KEY=$($result | jq -r ".Credentials.SecretAccessKey")
$AWS_SESSION_TOKEN=$($result | jq -r ".Credentials.SessionToken")
$expirationDate=$($result | jq -r ".Credentials.Expiration")

$profileName="mfa"
Start-Process powershell -Verb runAs -ArgumentList "-Command '& aws configure set aws_access_key_id $AWS_ACCESS_KEY_ID --profile $profileName'"
Start-Process powershell -Verb runAs -ArgumentList "-Command '& aws configure set aws_secret_access_key $AWS_SECRET_ACCESS_KEY --profile $profileName'"
Start-Process powershell -Verb runAs -ArgumentList "-Command '& aws configure set aws_session_token $AWS_SESSION_TOKEN --profile $profileName'"

Write-Output "Session will expire after $expirationDate for AWS Profile <$profileName>"
