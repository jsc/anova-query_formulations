This repository contains the scripts, data, and code necessary to
perform an ANOVA analysis across three TREC document collections --
ROBUST 2004, CORE 2017, CORE 2018, using multiple query formulations
for an information need (TREC Topic).

The key idea is to create a nested GLMM ANOVA model to perform the
analysis. This work will be published shortly.

The repository layout is as follows:
* anova/ -- matlab modelling and analysis code
* queries/ -- The query variants originally created for the ROBUST 2004
  collection and introduced in the paper from Benham and Culpepper at ADCS 
  2017 titled ``Risk-Reward Trade-offs in Rank Fusion''.
* terrier_runs/ -- All TREC run files for variants of the 25 overlapping
  collection topics for every system configuration and collection studied.
* terrier_scripts/ -- Bash scripts that can be used to reproduce the
  runs using a fork of the Terrier IR search engine we created in order
  to accomodate several new stemmers as well as modifications to a few
  of the ranking models to improve performance. The fork can be found
  at https://github.com/jsc/terrier-5.1.1.1.

Several important notes about the scripts are in order. First, you must
obtain and create 3 collection files using TREC collection data. We do
not own the rights so we cannot make any of the three collections available.
Sorry. If you do have the collections you need to create three files called:
robust04.txt.gz, nyt.txt.gz, and wapo.txt.gz for the three collections or
modify the scripts accordingly. The expected input for Terrier will be
TRECTXT format. For further details on the original collection formats
or to get access to the collection, please visit https://trec.nist.gov.

We have also included the configuration files for all of the indexes
and system configuration. These are created by Terrier after a run
and your configuration files should be similar if you manage to get
the scripts to work for you. These are provided to aide in debugging
any major differences in your own experiments should you attempt
to reproduce or extend our work in the future. Recreating all of the
runs and indexes will take several days on a moderately large server.
The ANOVA is considerable more challenging, and can take up to 1.5TB
of RAM on a single server to model the same number of factors
simultaneously. So, we wish you all the best should you be brave enough 
to try!

There are only 25 topics which overlap in the three collections and these
are the only ones used in our experiments. We have included the query
variants for all 249 ROBUST 2004 topics for convenience.

Additional details about the full analysis and model descriptions will
be provided as soon as we have finalised the review process of the work. 
Don't worry, it is not work under double blind review, so you don't
have to fret too much about breaking blind somewhere should you happen
to stubble onto this repository!

Collaborators on this work are: J. Shane Culpepper, RMIT University;
Guglielmo Faggioli + Nicola Ferro, Univerity of Padua; and Oren
Kurland, Technion. Feel free to contact any of us should you have
any questions or comments.



