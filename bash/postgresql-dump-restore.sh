DUMP_FILE="dump_$(date "+%Y%m%d%H%M%S").sql"
DUMP_DATA_ONLY_FILE="dump_dataonly_$(date "+%Y%m%d%H%M%S").sql"

DB_HOST=
DB_PORT=
DB_DATABASE=
DB_USERNAME=
DB_PASSWORD=

PGPASSWORD=$DB_PASSWORD pg_dump \
    -h $DB_HOST \
    -p $DB_PORT \
    -d $DB_DATABASE \
    -U $DB_USERNAME \
    > $DUMP_FILE

PGPASSWORD=admin psql \
    -h 127.0.0.1 \
    -p 5432 \
    -d agents-backend \
    -U admin \
    -f $DUMP_FILE

# PGPASSWORD=$DB_PASSWORD pg_dump \
#     --column-inserts \
#     --data-only \
#     -h $DB_HOST \
#     -p $DB_PORT \
#     -d $DB_DATABASE \
#     -U $DB_USERNAME \
#     > $DUMP_DATA_ONLY_FILE


# PGPASSWORD=admin pg_restore \
#   -Fd \
#   -j 2 \
#   $DUMP_DATA_ONLY_FILE \
#   -h 127.0.0.1 \
#   -d agent-backend \
#   -p 5432 \
#   -U admin
