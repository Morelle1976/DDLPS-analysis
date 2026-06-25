/*-----------------------------------------------------------
  01_data_preparation_template.sas
  Data preparation template for analysis datasets

  Manuscript: Descriptive analysis of epidemiology, demographic
  characteristics, and survival of dedifferentiated liposarcoma in France

  This script illustrates the structure of the data preparation workflow
  without exposing internal, patient-specific or institution-specific logic.
-----------------------------------------------------------*/

/*===========================================================
  1. Libraries – generic placeholders
===========================================================*/

libname DIAG  "path/to/DIAG";
libname DM    "path/to/DM";
libname INC   "path/to/INC";
libname META  "path/to/META";
libname MOL   "path/to/MOL";
libname REL   "path/to/REL";
libname RELS  "path/to/RELS";
libname SMETA "path/to/SMETA";
libname SYST  "path/to/SYST";
libname TRT   "path/to/TRT";

/*===========================================================
  2. Inclusion cohort and basic merge
===========================================================*/

/* Inclusion dataset (cohort definition) */
data inclusion;
    set INC.inc;
run;

/* Keep only included patients (inclflag = 1) */
data inclusion_cohort;
    set inclusion;
    if inclflag = 1;
    keep record_id inclflag;
run;

/* Core clinical datasets */
data dm_raw;   set DM.dm;   run;
data inc_raw;  set INC.inc; run;
data diag_raw; set DIAG.diag; run;
data trt_raw;  set TRT.trt;  run;
data mol_raw;  set MOL.mol;  run;

/* Sort for merging */
proc sort data=dm_raw;   by record_id; run;
proc sort data=inc_raw;  by record_id; run;
proc sort data=diag_raw; by record_id; run;
proc sort data=trt_raw;  by record_id; run;
proc sort data=mol_raw;  by record_id; run;

/* Merge core datasets into a single patient-level dataset */
data fusion1;
    merge dm_raw inc_raw diag_raw trt_raw mol_raw;
    by record_id;
run;

/* Restrict to inclusion cohort */
proc sort data=fusion1;          by record_id; run;
proc sort data=inclusion_cohort; by record_id; run;

data analyse1;
    merge fusion1 (in=a) inclusion_cohort;
    by record_id;
    if a; /* keep only included patients */
run;

/*===========================================================
  3. Derivation of core covariates (generic names)
===========================================================*/

data analyse1;
    set analyse1;

    /* Patient identifier */
    length patient_id $50;
    patient_id = record_id;

    /* Age at diagnosis (years) */
    age_diag = round((dateoforiginaldiagnosis - birthdate) / 365.25);
    label age_diag = "Age at diagnosis";

    /* Age category */
    if 0 < age_diag < 65 then agecod = 1;
    else if age_diag >= 65 then agecod = 2;
    label agecod = "Age category";

    /* Tumour size categories (example) */
    if 0 < sizeoftumour < 50 then sizcod = 1;
    else if 50 <= sizeoftumour <= 100 then sizcod = 2;
    else if sizeoftumour > 100 then sizcod = 3;
    label sizcod = "Tumour size category";

    /* Year of diagnosis */
    Yeardiagnosis = year(dateoforiginaldiagnosis);
    label Yeardiagnosis = "Year of diagnosis";

    /* Depth of tumour (generic recode) */
    length Depth_of_tumourcod $200;
    if depthoftumor = 1 then Depth_of_tumourcod = "Deep";
    else if depthoftumor = 2 then Depth_of_tumourcod = "Superficial";
    else if depthoftumor = 3 then Depth_of_tumourcod = "Deep";
    label Depth_of_tumourcod = "Depth of tumour";

    /* Histotype – generic binary flag for DDLPS */
    /* histotype2 = 2 ? dedifferentiated liposarcoma */
    histotype2 = histotype;
    label histotype2 = "Histotype (2 = DDLPS)";

    /* Metastatic status (baseline) */
    m = meta; /* example: meta variable from META dataset */
    label m = "Synchronous metastasis (0/1)";

run;

/*===========================================================
  4. Systemic treatment for primary tumour – line counts
===========================================================*/

/* Raw systemic treatment dataset */
data syst_raw;
    set SYST.syst;
run;

/* Remove empty repeat instances */
data syst_etape1;
    set syst_raw;
    if redcap_repeat_instance = . then delete;
run;

/* Merge with analysis cohort */
proc sort data=syst_etape1;      by record_id; run;
proc sort data=analyse1;         by record_id; run;

data syst_etape2;
    merge syst_etape1 analyse1 (in=a);
    by record_id;
    if a;
run;

/* Keep only rows with systemic treatment flag (example: systtrt = 1) */
data syst_primary;
    set syst_etape2;
    if systtrt = 1;
run;

/* Total number of lines for primary tumour */
proc sort data=syst_primary; by record_id systlinenb; run;

data nbrelignestotal;
    set syst_primary;
    by record_id systlinenb;
    if last.record_id;
    nbligne_primary = systlinenb;
    keep record_id nbligne_primary;
    label nbligne_primary = "Total number of lines for primary tumour";
run;

/* Merge back into main dataset */
proc sort data=nbrelignestotal; by record_id; run;
proc sort data=analyse1;        by record_id; run;

data analyse1;
    merge analyse1 nbrelignestotal;
    by record_id;
run;

/* Neo-adjuvant, adjuvant, palliative – generic line counts */
data syst_neo_adjuvant;
    set syst_etape2;
    if systtrtset = 1; /* neo-adjuvant */
run;

proc sql;
    create table nbrelignesneoadj as
    select record_id, count(*) as nbligne_neoadj
    from syst_neo_adjuvant
    group by record_id;
quit;

data syst_adjuvant;
    set syst_etape2;
    if systtrtset = 2; /* adjuvant */
run;

proc sql;
    create table nbrelignesadj as
    select record_id, count(*) as nbligne_adj
    from syst_adjuvant
    group by record_id;
quit;

data syst_palliative;
    set syst_etape2;
    if systtrtset = 3; /* palliative */
run;

proc sql;
    create table nbrelignespalliative as
    select record_id, count(*) as nbligne_pallia
    from syst_palliative
    group by record_id;
quit;

/* Merge line counts into main dataset */
proc sort data=nbrelignesneoadj;    by record_id; run;
proc sort data=nbrelignesadj;       by record_id; run;
proc sort data=nbrelignespalliative;by record_id; run;
proc sort data=analyse1;            by record_id; run;

data analyse1;
    merge analyse1 nbrelignesneoadj nbrelignesadj nbrelignespalliative;
    by record_id;
run;

/* Derive binary indicators */
data analyse1;
    set analyse1;

    /* Systemic treatment yes/no */
    if nbligne_primary > 0 then syst = 1;
    else syst = 0;
    label syst = "Systemic treatment for primary tumour";

    /* Neo-adjuvant */
    if nbligne_neoadj > 0 then neo_adj = 1;
    else neo_adj = 0;
    label neo_adj = "Neo-adjuvant treatment";

    /* Adjuvant */
    if nbligne_adj > 0 then adj = 1;
    else adj = 0;
    label adj = "Adjuvant treatment";

    /* Palliative */
    if nbligne_pallia > 0 then pallia = 1;
    else pallia = 0;
    label pallia = "Palliative treatment";

run;

/*===========================================================
  5. Local relapse of primary tumour – generic structure
===========================================================*/

/* Raw local relapse dataset */
data rel_raw;
    set REL.rel;
run;

/* Remove empty repeat instances */
data rel2;
    set rel_raw;
    if redcap_repeat_instance = . then delete;
run;

/* Restrict to analysis cohort */
proc sort data=rel2;             by record_id; run;
proc sort data=inclusion_cohort; by record_id; run;

data rel2_cohort;
    merge rel2 inclusion_cohort (in=a);
    by record_id;
    if a;
run;

/* Keep only rows with local relapse flag (rellocal = 1) */
data yeslocalrelapse;
    set rel2_cohort;
    if rellocal = 1;
run;

/* First local relapse per patient */
proc sort data=yeslocalrelapse; by record_id relnb; run;

data premiererechutelocal;
    set yeslocalrelapse;
    by record_id relnb;
    if first.record_id;
    keep record_id rellocal;
run;

/* Merge into main dataset */
proc sort data=premiererechutelocal; by record_id; run;
proc sort data=analyse1;            by record_id; run;

data rechutelocaleouinon;
    merge analyse1 premiererechutelocal;
    by record_id;
run;

data rechutelocaleouinon;
    set rechutelocaleouinon;
    if rellocal = 1 then rechute_locale = 1;
    else rechute_locale = 0;
    label rechute_locale = "Local relapse of primary tumour";
run;

/*===========================================================
  6. Metastatic disease – generic structure
===========================================================*/

/* Raw metastatic dataset */
data meta_raw;
    set META.meta;
run;

/* Restrict to analysis cohort */
proc sort data=meta_raw;          by record_id; run;
proc sort data=inclusion_cohort;  by record_id; run;

data metaouinon;
    merge meta_raw inclusion_cohort (in=a);
    by record_id;
    if a;
run;

/* Generic metastatic status */
data metaouinon;
    set metaouinon;
    /* Example: meta = 1 yes, 0 no, .A unknown */
    length metastatic_status $50;
    if meta = 1 then metastatic_status = "Yes";
    else if meta = 0 then metastatic_status = "No";
    else metastatic_status = "Unknown";
    label metastatic_status = "Metastatic disease (baseline)";
run;

/*===========================================================
  7. PFS/OS analysis datasets – generic structure
===========================================================*/

/* OS dataset */
data ddlps;
    set analyse1;
    /* Example: time_to_event and event variables must be derived
       from dates of diagnosis, last follow-up, and death. */
    /* time_to_event = ...; */
    /* event = ...; */
run;

/* PFS1 dataset */
data ddlpsPFS1;
    set analyse1;
    /* Example: delaiPFSL1 and PFSL1 must be derived from
       systemic treatment dates and progression dates. */
    /* delaiPFSL1 = ...; */
    /* PFSL1 = ...; */
run;

/* PFS2 dataset */
data ddlpsPFS2;
    set analyse1;
    /* Example: delaiPFSL2 and PFSL2 must be derived similarly. */
    /* delaiPFSL2 = ...; */
    /* PFSL2 = ...; */
run;

/*===========================================================
  8. Final mapping to generic analysis datasets
===========================================================*/

/* Main analysis dataset (population characteristics, primary tumour) */
data dataset_main;
    set analyse1;
    length cov_age cov_sex cov_site cov_grade cov_size cov_ecog cov_metastasis 8;
    length cov_mdm2_test cov_mdm2_method cov_mdm2_result 8;

    /* Map to generic covariates */
    cov_age        = agecod;
    cov_sex        = sex;
    cov_site       = grandecat;
    cov_grade      = grade_grouped;
    cov_size       = sizcod;
    cov_ecog       = performancestatus;
    cov_metastasis = m;

    /* MDM2 testing – example mapping */
    cov_mdm2_test   = molmdm2test;
    cov_mdm2_method = testMDM2;
    cov_mdm2_result = molmdm2res;

    /* Treatment indicators */
    cov_systemic_primary   = syst;
    cov_neo_adjuvant       = neo_adj;
    cov_adjuvant           = adj;
    cov_palliative         = pallia;

    label cov_age              = "Age category";
    label cov_sex              = "Sex";
    label cov_site             = "Tumour site group";
    label cov_grade            = "Tumour grade";
    label cov_size             = "Tumour size category";
    label cov_ecog             = "Performance status";
    label cov_metastasis       = "Baseline metastasis";
    label cov_mdm2_test        = "MDM2 testing performed";
    label cov_mdm2_method      = "MDM2 testing method";
    label cov_mdm2_result      = "MDM2 testing result";
    label cov_systemic_primary = "Systemic treatment for primary tumour";
    label cov_neo_adjuvant     = "Neo-adjuvant treatment";
    label cov_adjuvant         = "Adjuvant treatment";
    label cov_palliative       = "Palliative treatment";
run;

/* Metastatic analysis dataset */
data dataset_metastasis;
    set metaouinon;
    length patient_id $50;
    patient_id = record_id;
run;

/* Local relapse analysis dataset */
data dataset_local_relapse;
    set rechutelocaleouinon;
    length patient_id $50;
    patient_id = record_id;
run;

/* PFS1 and PFS2 analysis datasets */
data dataset_PFS1;
    set ddlpsPFS1;
    length patient_id $50;
    patient_id = record_id;
run;

data dataset_PFS2;
    set ddlpsPFS2;
    length patient_id $50;
    patient_id = record_id;
run;

/*===========================================================
  End of 00_data_preparation_template.sas
===========================================================*/
