#!/bin/bash
set -e

ENV=$1
echo "[ENVIRONMENT]: $ENV"

DB_MIGRATIONS_FOLDER=${DB_MIGRATIONS_FOLDER:-src/main/resources/db/migration}

case $ENV in
	dev) 
		DB_HOST=$DB_DEV_HOST
		DB_PORT=$DB_DEV_PORT
		DB_NAME=$DB_DEV_DATABASE
		DB_SCHEMA=$DB_DEV_SCHEMA
		;;
	test)
		DB_HOST=$DB_TEST_HOST
		DB_PORT=$DB_TEST_PORT
		DB_NAME=$DB_TEST_DATABASE
		DB_SCHEMA=$DB_TEST_SCHEMA
		;;
	*)
		echo "ERROR: Unable to match environment to Database schema"
		exit 1
		;;
esac

DB_URL="jdbc:postgresql://$DB_HOST:$DB_PORT/$DB_NAME"
echo "[DB_URL]: $DB_URL"
echo "[DB_SCHEMA]: $DB_SCHEMA"
echo "[DB_MIGRATIONS_FOLDER] $DB_MIGRATIONS_FOLDER"

echo "MIGRATION INFORMATION..."
flyway info -url="$DB_URL" \
	-schemas="$DB_SCHEMA" \
	-user="$OBP_DEV_DB_USER" \
	-password="$OBP_DEV_DB_PASSWORD" \
	-locations=filesystem:/$(pwd)/$DB_MIGRATIONS_FOLDER

echo "START MIGRATION..."
flyway migrate -url="$DB_URL" \
	-schemas="$DB_SCHEMA" \
	-user="$OBP_DEV_DB_USER" \
	-password="$OBP_DEV_DB_PASSWORD" \
	-locations=filesystem:/$(pwd)/$DB_MIGRATIONS_FOLDER