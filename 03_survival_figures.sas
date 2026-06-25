/*-----------------------------------------------------------
  03_survival_figures.sas
  GitHub version – Code used to generate survival figures
  Manuscript:  Descriptive analysis of epidemiology, demographic characteristics, and survival of  dedifferentiated liposarcoma in France


  Requirements:
    - SAS 9.4
    - AdClin macro %NEWSURV available in the SAS session

  Input datasets:
    dataset_main      : main analysis dataset (OS analyses)
    dataset_PFS1      : PFS1 dataset
    dataset_PFS2      : PFS2 dataset
    dataset_PFS2_doxo : PFS2 subset (doxorubicin)

  Required variables in each dataset:
    time_to_event : time-to-event variable
    event         : event indicator (1=event, 0=censored)
    cov_age       : age category
    cov_ecog      : ECOG performance status
    cov_grade     : tumour grade
    cov_surgery   : surgery of tumour (yes/no)
    cov_metastasis: synchronous metastasis indicator
    cov_size      : tumour size category
    cov_site      : site group
    cov_treatment1: treatment group for PFS1
    cov_group2    : four-category treatment group for PFS2
    cov_group2_v2 : binary treatment grouping for PFS2
-----------------------------------------------------------*/

/* Global ODS and style setup */
ods graphics / reset=all;
ods listing style=htmlblue;
ods escapechar='^';

/* Custom style for Arial fonts */
proc template;
    define style Styles.ArielStyle;
        parent = Styles.HTMLBlue;
        style GraphFonts /
            'GraphDataFont'  = ("Arial", 8pt)
            'GraphValueFont' = ("Arial", 8pt)
            'GraphLabelFont' = ("Arial", 9pt)
            'GraphTitleFont' = ("Arial",10pt);
    end;
run;

ods listing style=Styles.ArielStyle;

/*-----------------------------------------------------------
  Utility macro to generate a clean PDF survival figure
-----------------------------------------------------------*/
%macro make_surv_figure(
    data=,
    time=,
    cens=,
    cen_vl=0,
    class=,
    timelist=,
    color=,
    ylabel=,
    xlabel=,
    outfile=,
    summary_ds=
);

    /* Reset ODS environment */
    ods _all_ close;
    ods listing close;
    ods html close;
    ods results off;
    ods noresults;
    ods graphics off;

    title;
    footnote;

    ods escapechar='^';
    ods path reset;
    ods path sashelp.tmplmst(read);

    /* Output PDF file */
    ods pdf file="output/&outfile..pdf"
            notoc nogtitle nogfootnote;

    ods graphics / reset=all imagefmt=pdf antialiasmax=1400;

    /* Capture summary table */
    ods output _summary=&summary_ds;

    ods layout gridded columns=1;
    ods region;

    /* Call to NEWSURV macro */
    %newsurv(
        DATA=&data,
        TIME=&time,
        CENS=&cens,
        CEN_VL=&cen_vl,
        TIMELIST=&timelist,
        COLOR=&color,
        SUMMARY=1,
        YLABEL=&ylabel,
        XLABEL=&xlabel,
        %if %length(&class) %then %do;
            CLASS=&class,
        %end;
        rISKLIST=0 to 160 by 20,
        risklabellocation=left,
        RISKLOCATION=BOTTOM,
        parheader=Number at risk,
        paralign=labels,
        RISKCOLOR=1,
        CONFTYPE=LOGLOG,
        PLOTCI=0,
        border=0,
        SHOWWALLS=0,
        PLOTCIFILLTRANSPARENCY=0.90,
        DISPLAY=LEGEND
    );

    ods region;
    ods layout end;
    ods pdf close;

    ods listing;
    ods results on;
    options notes source source2;

%mend make_surv_figure;

/*-----------------------------------------------------------
  FIGURE 1A – Overall survival (unstratified)
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_main,
    time      = time_to_event,
    cens      = event,
    timelist  = 12 24 60,
    color     = blue,
    ylabel    = Overall survival (OS),
    xlabel    = Months from diagnosis,
    outfile   = Figure1A,
    summary_ds= fig1A_summary
);

/*-----------------------------------------------------------
  FIGURE 1B – OS stratified by age category
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_main,
    time      = time_to_event,
    cens      = event,
    class     = cov_age,
    timelist  = 12 24 60,
    color     = blue green,
    ylabel    = Overall survival (OS),
    xlabel    = Months from diagnosis,
    outfile   = Figure1B,
    summary_ds= fig1B_summary
);

/*-----------------------------------------------------------
  FIGURE 1C – OS stratified by ECOG
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_main,
    time      = time_to_event,
    cens      = event,
    class     = cov_ecog,
    timelist  = 12 24 60,
    color     = blue purple green,
    ylabel    = Overall survival (OS),
    xlabel    = Months from diagnosis,
    outfile   = Figure1C,
    summary_ds= fig1C_summary
);

/*-----------------------------------------------------------
  FIGURE 1D – OS stratified by tumour grade
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_main,
    time      = time_to_event,
    cens      = event,
    class     = cov_grade,
    timelist  = 12 24 60,
    color     = blue red purple green,
    ylabel    = Overall survival (OS),
    xlabel    = Months from diagnosis,
    outfile   = Figure1D,
    summary_ds= fig1D_summary
);

/*-----------------------------------------------------------
  FIGURE 2A – OS stratified by surgery
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_main,
    time      = time_to_event,
    cens      = event,
    class     = cov_surgery,
    timelist  = 12 24 60,
    color     = blue green,
    ylabel    = Overall survival (OS),
    xlabel    = Months from diagnosis,
    outfile   = Figure2A,
    summary_ds= fig2A_summary
);

/*-----------------------------------------------------------
  FIGURE 2B – OS stratified by synchronous metastasis
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_main,
    time      = time_to_event,
    cens      = event,
    class     = cov_metastasis,
    timelist  = 12 24 60,
    color     = blue purple,
    ylabel    = Overall survival (OS),
    xlabel    = Months from diagnosis,
    outfile   = Figure2B,
    summary_ds= fig2B_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 1A – PFS1 overall
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS1,
    time      = time_to_event,
    cens      = event,
    timelist  = 6 12,
    color     = blue,
    ylabel    = Progression Free Survival (PFS1),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig1A,
    summary_ds= supp1A_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 1B – PFS1 stratified by ECOG
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS1,
    time      = time_to_event,
    cens      = event,
    class     = cov_ecog,
    timelist  = 6 12,
    color     = blue purple green,
    ylabel    = Progression Free Survival (PFS1),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig1B,
    summary_ds= supp1B_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 1C – PFS1 stratified by tumour size
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS1,
    time      = time_to_event,
    cens      = event,
    class     = cov_size,
    timelist  = 6 12,
    color     = blue green purple,
    ylabel    = Progression Free Survival (PFS1),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig1C,
    summary_ds= supp1C_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 1D – PFS1 stratified by treatment
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS1,
    time      = time_to_event,
    cens      = event,
    class     = cov_treatment1,
    timelist  = 6 12,
    color     = blue purple,
    ylabel    = Progression Free Survival (PFS1),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig1D,
    summary_ds= supp1D_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 2A – PFS2 overall
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS2,
    time      = time_to_event,
    cens      = event,
    timelist  = 6 12,
    color     = blue,
    ylabel    = Progression Free Survival (PFS2),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig2A,
    summary_ds= supp2A_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 2B – PFS2 stratified by tumour size
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS2,
    time      = time_to_event,
    cens      = event,
    class     = cov_size,
    timelist  = 6 12,
    color     = blue green purple,
    ylabel    = Progression Free Survival (PFS2),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig2B,
    summary_ds= supp2B_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 2C – PFS2 stratified by site
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS2,
    time      = time_to_event,
    cens      = event,
    class     = cov_site,
    timelist  = 6 12,
    color     = blue red green orange,
    ylabel    = Progression Free Survival (PFS2),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig2C,
    summary_ds= supp2C_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 2D – PFS2 doxorubicin subset
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS2_doxo,
    time      = time_to_event,
    cens      = event,
    timelist  = 6 12,
    color     = blue purple,
    ylabel    = Progression Free Survival (PFS2),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig2D,
    summary_ds= supp2D_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 2E
  Comparative PFS2 across four treatment groups:
    - Trabectedin (standard of care)
    - Eribulin
    - Ifosfamide
    - Other molecules
  Variable: cov_group2 (four-category treatment variable)
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS2,
    time      = time_to_event,
    cens      = event,
    class     = cov_group2,
    timelist  = 6 12,
    color     = blue red green orange,
    ylabel    = Progression Free Survival (PFS2),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig2E,
    summary_ds= supp2E_summary
);

/*-----------------------------------------------------------
  SUPPLEMENTARY FIGURE 2F
  PFS2 comparison between:
    - Trabectedin (standard of care)
    - All other molecules combined
  Variable: cov_group2_v2 (binary treatment grouping)
-----------------------------------------------------------*/
%make_surv_figure(
    data      = dataset_PFS2,
    time      = time_to_event,
    cens      = event,
    class     = cov_group2_v2,
    timelist  = 6 12,
    color     = blue purple,
    ylabel    = Progression Free Survival (PFS2),
    xlabel    = Time since 1st treatment line (months),
    outfile   = SuppFig2F,
    summary_ds= supp2F_summary
);
