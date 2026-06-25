/*-----------------------------------------------------------
  02_tables.sas
  GitHub version – Template for descriptive and clinical tables
  Manuscript: Descriptive analysis of epidemiology, demographic characteristics, and survival of dedifferentiated liposarcoma in France
-----------------------------------------------------------*/


  Requirements:
    - SAS 9.4
    - AdClin macro %Table1 available in the SAS session

  Input datasets (generic names):
    dataset_main            : main analysis dataset
    dataset_metastasis      : metastatic disease dataset
    dataset_local_relapse   : local relapse dataset
    dataset_relapse_comb    : relapse treatment combinations
    dataset_PFS1            : PFS1 dataset (best response L1)
    dataset_L1_flags        : systemic treatments – line 1
    dataset_L2_flags        : systemic treatments – line 2
    dataset_L3_flags        : systemic treatments – line 3

  Required variables (generic names):
    patient_id
    cov_age
    cov_sex
    cov_site
    cov_grade
    cov_size
    cov_ecog
    cov_histotype
    cov_metastasis
    cov_metastatic_status
    cov_mdm2_test
    cov_mdm2_method
    cov_mdm2_result
    cov_surgery
    cov_radiotherapy
    cov_other_local
    cov_systemic_primary
    cov_relapse
    cov_relapse_surgery
    cov_relapse_radiotherapy
    cov_relapse_systemic
    cov_relapse_combination
    cov_best_response_L1
    cov_drug_class
-----------------------------------------------------------*/

/*-----------------------------------------------------------
  Global reporting options
-----------------------------------------------------------*/
%RepOpts(
    TitleCase      = sentence,
    ColHeadCase    = sentence,
    RowHeadCase    = sentence,
    EditStrings    = yes,
    UnivLayout     = (n; nmiss; mean "_(" std ")"; median "_(" min "-" max ")"; "Q1-Q3"!Q1 "-" Q3),
    UnivDec        = (mean 2 std 2 median 2 min 2 max 2 Q1 2 Q3 2),
    OutputFolder   = output
);

/*===========================================================
  TABLE 1 – Population characteristics and MDM2 testing
===========================================================*/
%Title(Table 1 – Population characteristics and MDM2 testing)

%Table1(
    PopDataset   = dataset_main,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_histotype = 2),

    Blocks =
        /* Patient and tumour characteristics */
        cov_age              type=univ /
        cov_age              type=freq /
        cov_sex              type=freq /
        cov_site             type=freq /
        cov_grade            type=freq /
        cov_size             type=freq /
        cov_ecog             type=freq /
        cov_metastasis       type=freq /

        /* MDM2 testing */
        cov_mdm2_test        type=freq /
        cov_mdm2_method@(cov_mdm2_test=1) type=freq /
        cov_mdm2_result@(cov_mdm2_test=1) type=freq /
);

/*===========================================================
  TABLE 2 – Local and systemic treatments of primary tumour
===========================================================*/
%Title(Table 2 – Local and systemic treatments of primary tumour)

%Table1(
    PopDataset   = dataset_main,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Pop,
    PrintMissing = Yes,
    PopFilter    = (cov_histotype = 2 and cov_metastasis = 0),

    Blocks =
        /* Local treatments */
        cov_surgery        type=freq /
        cov_radiotherapy   type=freq /
        cov_other_local    type=freq /

        /* Systemic treatments */
        cov_systemic_primary       type=freq /
);

/*===========================================================
  TABLE 3A – Diagnosis of metastatic disease
===========================================================*/
%Title(Table 3A – Diagnosis of metastatic disease)

%Table1(
    PopDataset   = dataset_metastasis,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_histotype = 2),

    Blocks =
        cov_metastasis        type=freq /
        cov_metastatic_status type=freq /
);

/*===========================================================
  TABLE 3B – Local treatment of metastatic disease
===========================================================*/
%Title(Table 3B – Local treatment of metastatic disease)

%Table1(
    PopDataset   = dataset_metastasis,
    PopId        = patient_id,
    ColAll       = yes "Total",
    ColVar       = cov_metastasis,
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_metastasis = 1 and cov_histotype = 2),

    Blocks =
        cov_surgery        type=freq /
        cov_other_local    type=freq /
);

/*===========================================================
  TABLE 3C – Systemic treatments for metastasis
===========================================================*/
%Title(Table 3C – Systemic treatments for metastasis)

%Table1(
    PopDataset   = dataset_metastasis,
    PopId        = patient_id,
    ColAll       = yes "Total",
    ColVar       = cov_metastasis,
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_metastasis = 1 and cov_histotype = 2),

    Blocks =
        cov_systemic_primary type=freq /
);

/*===========================================================
  TABLE 3D – Best response to L1 systemic treatment
===========================================================*/
%Title(Table 3D – Best response to L1 systemic treatment)

%Table1(
    PopDataset   = dataset_PFS1,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_histotype = 2),

    Blocks =
        cov_best_response_L1 type=freq /
);

/*===========================================================
  SUPPLEMENTARY TABLE 1 – Primary tumour treatments without surgery
===========================================================*/
%Title(Supplementary Table 1 – Primary tumour treatments without surgery)

%Table1(
    PopDataset   = dataset_main,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_surgery = 0 and cov_histotype = 2 and cov_metastasis = 0),

    Blocks =
        cov_radiotherapy type=freq /
        cov_systemic_primary     type=freq /
);

/*===========================================================
  SUPPLEMENTARY TABLE 2A – Local relapse of primary tumour
===========================================================*/
%Title(Supplementary Table 2A – Local relapse of primary tumour)

%Table1(
    PopDataset   = dataset_local_relapse,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_histotype = 2 and cov_metastasis = 0),

    Blocks =
        cov_relapse type=freq /
        cov_relapse_surgery@(cov_relapse=1) type=freq /
        cov_relapse_radiotherapy@(cov_relapse=1) type=freq /
);

/*===========================================================
  SUPPLEMENTARY TABLE 2B – Relapse treatment combinations
===========================================================*/
%Title(Supplementary Table 2B – Local relapse treatment combinations)

%Table1(
    PopDataset   = dataset_relapse_comb,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_relapse = 1 and cov_histotype = 2 and cov_metastasis = 0),

    Blocks =
        cov_relapse_combination type=freq /
);

/*===========================================================
  SUPPLEMENTARY TABLE 3 – Systemic treatments L1–L3
===========================================================*/
%Title(Supplementary Table 3 – L1 systemic treatments)

%Table1(
    PopDataset   = dataset_L1_flags,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_histotype = 2),

    Blocks =
        cov_drug_class type=freq /
);

%Title(Supplementary Table 3 – L2 systemic treatments)

%Table1(
    PopDataset   = dataset_L2_flags,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_histotype = 2),

    Blocks =
        cov_drug_class type=freq /
);

%Title(Supplementary Table 3 – L3 systemic treatments)

%Table1(
    PopDataset   = dataset_L3_flags,
    PopId        = patient_id,
    ColAll       = yes "Total",
    PctCol       = Nonmiss,
    PrintMissing = Yes,
    PopFilter    = (cov_histotype = 2),

    Blocks =
        cov_drug_class type=freq /
);

/*===========================================================
  SUPPLEMENTARY TABLE 4 – Cox regression analyses (PFS1 & PFS2)
===========================================================*/

/* PFS1 Cox model */
ods output ParameterEstimates = cox_PFS1;

proc phreg data = dataset_PFS1;
    class cov_age cov_sex cov_ecog cov_grade cov_size cov_site cov_surgery cov_metastasis;
    model time_to_event*event(0) =
        cov_age cov_sex cov_size cov_ecog cov_grade cov_site cov_surgery cov_metastasis
        / rl ties=efron;
run;

ods output close;

/* PFS2 Cox model */
ods output ParameterEstimates = cox_PFS2;

proc phreg data = dataset_PFS2;
    class cov_age cov_sex cov_ecog cov_grade cov_size cov_site cov_surgery cov_metastasis;
    model time_to_event*event(0) =
        cov_age cov_sex cov_size cov_ecog cov_grade cov_site cov_surgery cov_metastasis
        / rl ties=efron;
run;

ods output close;
