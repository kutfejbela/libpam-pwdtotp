#!/bin/bash

source /etc/libpam-pwdtotp/libpam-pwdtotp.conf
source /etc/libpam-pwdtotp/libpam-pwdtotp.lib

LIBPAM_PWDTOTP_STRING_PASSWORD=$("$LIBPAM_PWDTOTP_COMMAND_CAT" -)

libpam_pwdtotp_check_requirements

LIBPAM_PWDTOTP_STRING_USER=$PAM_USER

LIBPAM_PWDTOTP_STRING_FILETOTP=$("$LIBPAM_PWDTOTP_COMMAND_CAT" "$LIBPAM_PWDTOTP_FILE_TOTP" | "$LIBPAM_PWDTOTP_COMMAND_GREP" -m 1 -oP "^$LIBPAM_PWDTOTP_STRING_USER:\\K.*")

LIBPAM_PWDTOTP_STRING_FILESHA512PWD=$("$LIBPAM_PWDTOTP_COMMAND_CAT" "$LIBPAM_PWDTOTP_FILE_PWD" | "$LIBPAM_PWDTOTP_COMMAND_GREP" -m 1 -oP "^$LIBPAM_PWDTOTP_STRING_USER:\\K.*")

libpam_pwdtotp_check_pwdtotp

LIBPAM_PWDTOTP_NUMBER_TOTP=$("$LIBPAM_PWDTOTP_COMMAND_OATHTOOL" -d "$LIBPAM_PWDTOTP_NUMBER_TOTPDIGIT" -s "$LIBPAM_PWDTOTP_NUMBER_TOTPTIME" --totp "$LIBPAM_PWDTOTP_STRING_FILETOTP")

if [ "$LIBPAM_PWDTOTP_BOOL_DEBUG" == "yes" ]
then
 echo "The given user: $LIBPAM_PWDTOTP_STRING_USER"
 echo "The given password: $LIBPAM_PWDTOTP_STRING_PASSWORD"
 echo "User hex secret: $LIBPAM_PWDTOTP_STRING_FILETOTP"
 echo "User TOTP (${LIBPAM_PWDTOTP_NUMBER_TOTPTIME}s): $LIBPAM_PWDTOTP_NUMBER_TOTP"
 echo "User password sha512 hash: $LIBPAM_PWDTOTP_STRING_FILESHA512PWD"
fi

LIBPAM_PWDTOTP_STRING_FILESHA512PWD="$LIBPAM_PWDTOTP_STRING_FILESHA512PWD  -"

LIBPAM_PWDTOTP_STRING_TOTP="${LIBPAM_PWDTOTP_STRING_PASSWORD: -$LIBPAM_PWDTOTP_NUMBER_TOTPDIGIT}"
LIBPAM_PWDTOTP_STRING_SHA512PWD=$(echo "${LIBPAM_PWDTOTP_STRING_PASSWORD: 0: -$LIBPAM_PWDTOTP_NUMBER_TOTPDIGIT}" | "$LIBPAM_PWDTOTP_COMMAND_SHA512SUM" )

if [ ! "$LIBPAM_PWDTOTP_STRING_SHA512PWD" = "$LIBPAM_PWDTOTP_STRING_FILESHA512PWD" ]
then
 if [ "$LIBPAM_PWDTOTP_BOOL_DEBUG" == "yes" ]
 then
  echo "The password does not match"

  exit 101
 fi
fi

if [ ! "$LIBPAM_PWDTOTP_STRING_TOTP" = "$LIBPAM_PWDTOTP_NUMBER_TOTP" ]
then
 if [ "$LIBPAM_PWDTOTP_BOOL_DEBUG" == "yes" ]
 then
  echo "The one time password (TOTP) does not match"

  exit 102
 fi
fi

exit 0
