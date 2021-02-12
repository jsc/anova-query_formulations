The scripts can be ran in the following order to pull the fork of terrier,
create all of the indexes, and run all of the query variants using many
different ranking configurations. As mentioned in the main README.md,
you must have the three collection files in this directory or the
scripts will abort.
Run the scripts as follows:
1. ./setup.sh
2. ./mk_index.sh
3. ./run_rob.sh
4. ./run_core17.sh
5. ./run_core18.sh

You can modify each if the run_x scripts to use an exact number of
CPU cores if you wish. Right now, it will try to use all available
resources which can generate a pretty large load if you are not
careful.
