#!/bin/bash

# Original: https://gist.github.com/woowa-hsw0/caa3340e2a7b390dbde81894f73e379d

set -eu
umask 0022

TMPDIR=$(mktemp -d awsenv)

echo "TEMPDIR $TMPDIR"

if [[ $# -ge 1 ]]; then
    AWS_PROFILE="$1"
else
    read -p 'Enter AWS_PROFILE: ' AWS_PROFILE
fi

caller_identity=($(aws --profile "$AWS_PROFILE" sts get-caller-identity --output text))


AWS_ACCOUNT_NUMBER="${caller_identity[0]}"
AWS_IAM_USER_ARN="${caller_identity[1]}"
AWS_IAM_USERNAME="$(basename "$AWS_IAM_USER_ARN")"
MFA_SERIAL="arn:aws:iam::$AWS_ACCOUNT_NUMBER:mfa/$AWS_IAM_USERNAME"

echo "AWS Account number: $AWS_ACCOUNT_NUMBER"
echo "IAM Username: $AWS_IAM_USERNAME"
echo "MFA Serial: $MFA_SERIAL"

if ykman oath info > "$TMPDIR/yk-oath-info" 2>&1 ; then
    echo "Trying to read MFA code from Yubikey."
    cat "$TMPDIR/yk-oath-info"
    rm -f "$TMPDIR/yk-oath-info"

    ykman oath code "$AWS_PROFILE" 2>&1 | tee "$TMPDIR/yk-mfa-code"
    # take the last field, the name of the MFA token can contain spaces (Amazon Web Services ...) 
    otp_token=$(grep -F "$AWS_PROFILE" "$TMPDIR/yk-mfa-code" | rev | cut -d' ' -f1 |rev)
    echo "TOKEN $otp_token"
    rm -f "$TMPDIR/yk-mfa-code"
    [[ -z "$otp_token" ]] && exit 1
else
    read -p 'Enter MFA code: ' otp_token
fi

session_token=($(aws --profile "$AWS_PROFILE" sts get-session-token --serial-number $MFA_SERIAL --token-code $otp_token --query 'Credentials.[AccessKeyId,SecretAccessKey,SessionToken]' --output text))
export AWS_ACCESS_KEY_ID="${session_token[0]}" AWS_SECRET_ACCESS_KEY="${session_token[1]}" AWS_SESSION_TOKEN="${session_token[2]}"

aws sts get-caller-identity

rm -Rf "$TMPDIR"

echo "All set, aws configured"
