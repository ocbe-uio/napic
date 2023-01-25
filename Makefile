
VIEDOC_EXPORT_NAME = _20230125_071722
DATE = $(shell echo $(VIEDOC_EXPORT_NAME) | sed 's/.*_\(....\)\(..\)\(..\)_.*/\1-\2-\3/')
DMC_REPORT = $(DATE)_Nor-Solidarity_DMC_Report.docx
MAIN_REPORT1 = $(DATE)_Nor-Solidarity_Main_Report2.docx
RAW_CSV = $(wildcard data/raw/$(VIEDOC_EXPORT_NAME)/*)
TDMISC = data/td/tdae.rds data/td/tdex.rds data/td/tdsq.rds data/td/tdsc.rds data/td/tdcm.rds data/td/tdds.rds
TD = data/td/tdran.rds $(TDMISC) data/td/tddm.rds data/td/tdrc.rds data/td/tdvs.rds data/td/tdlb.rds data/td/tdvl.rds data/td/tdab.rds
ADMISC = data/ad/adab.rds data/ad/advl.rds data/ad/adrc.rds 
AD = data/ad/adsl.rds data/ad/adae.rds data/ad/adex.rds data/ad/addm.rds data/ad/adev.rds $(ADMISC)
RD = results/rds/rdev.rds results/rds/rdlb.rds results/rds/rddi.rds results/rds/rdab.rds results/rds/rdvlrf.rds results/rds/rdvl_sg.rds

# Set this to FALSE when for the true results.  
PSEUDORANDOM = FALSE

.PHONY: all td ad rd raw dmc_report main_report1
all: td ad raw rd
td: $(TD)
ad: $(AD)
rd: $(RD)
raw: data/raw/raw.rds data/raw/rawab.rds data/raw/rawvl.rds
dmc_report: results/dmc/$(DMC_REPORT)
main_report1: results/main/$(MAIN_REPORT1)

############################
# Make raw datasets
############################

data/raw/raw.rds:  $(RAW_CSV) src/make_raw/make_raw.R src/external/functions.R
	Rscript src/make_raw/make_raw.R $(VIEDOC_EXPORT_NAME)
	
data/raw/rawab.rds: src/make_raw/make_rawab.R data/raw/misc/2011202_Remdesivir_study_Antibody_data.xlsx
	Rscript src/make_raw/make_rawab.R
	
data/raw/rawvl.rds: src/make_raw/make_rawvl.R data/raw/misc/ORO_data_til_Inge.xlsx
	Rscript src/make_raw/make_rawvl.R

##################################	
# Make Tabulation datasets (TD)
#################################

data/td/tdran.rds: data/raw/raw.rds src/external/functions.R src/make_td/make_tdran.R
	Rscript src/make_td/make_tdran.R


################################	
# Make Analysis Datasets (AD)
###############################	
data/ad/adsl.rds: data/raw/raw.rds src/external/functions.R data/td/tddm.rds data/td/tdran.rds data/td/tdsq.rds src/make_ad/make_adsl.R
	Rscript src/make_ad/make_adsl.R $(PSEUDORANDOM)
	

	
############################
# Make Result Datasets (RD)
############################


results/rds/rdlb.rds: data/td/tdlb.rds data/ad/adsl.rds src/make_rd/rdlb_functions.R src/make_rd/stata.R src/make_rd/make_rdlb.R
	Rscript src/make_rd/make_rdlb.R 	
	

##############################
# Make reports
##############################

	
results/main/$(MAIN_REPORT1): $(AD) $(TD) $(RD) src/make_reports/main_report1.Rmd
	Rscript -e 'rmarkdown::render("src/make_reports/main_report1.Rmd", \
	output_dir = "results/main", output_file = "$(MAIN_REPORT1)", \
	knit_root_dir = "../../.", \
	params = list(viedoc_export = "$(VIEDOC_EXPORT_NAME)", pseudorandom = $(PSEUDORANDOM) ) )'



