#! /bin/sh
# Manually Vacuum All DBs

# Dev DBs
psql -d FareDev -c "vacuum full verbose analyse" -S > /space/postgresql/vacuums/vacuum.FareDev.`date +%Y%m%d%H%M`.log 2>&1 
#psql -d MemberDev -c "vacuum full verbose analyse" -S > /space/postgresql/vacuums/vacuum.MemberDev.`date +%Y%m%d%H%M`.log 2>&1 
psql -d ContentMgtDev -c "vacuum full verbose analyse" -S > /space/postgresql/vacuums/vacuum.ContentMgtDev.`date +%Y%m%d%H%M`.log 2>&1 

# QA DBs
#psql -d FareQA -c "vacuum full verbose analyse" -S > /space/postgresql/vacuums/vacuum.FareQA.`date +%Y%m%d%H%M`.log 2>&1 
#psql -d MemberQA -c "vacuum full verbose analyse" -S > /space/postgresql/vacuums/vacuum.MemberQA.`date +%Y%m%d%H%M`.log 2>&1 

# Misc DBs
#psql -d SabreHistory -c "vacuum full verbose analyse" -S > /space/postgresql/vacuums/vacuum.SabreHistory.`date +%Y%m%d%H%M`.log 2>&1 
