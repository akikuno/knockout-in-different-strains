pacman::p_load(tidyverse)

df <- read_csv("reports/allele_number.csv.gz")

df_filtered <- df %>%
    filter(condition != "control") %>%
    mutate(strain = str_to_upper(strain))

# Total samples
df_filtered %>%
    select(strain, barcode) %>%
    distinct() %>%
    count()

# samples by strains
df_samples <-
    df_filtered %>%
    select(strain, barcode) %>%
    distinct() %>%
    group_by(strain) %>%
    count() %>%
    rename("#sample" = n)

# samples that contains more than 10% deletion alleles

df_deletion <-
    df_filtered %>%
    select(strain, barcode, allele) %>%
    group_by(strain, barcode, allele) %>%
    count() %>%
    ungroup(allele) %>%
    mutate(percent = n / sum(n) * 100) %>%
    filter(allele == "target") %>%
    filter(percent >= 10) %>%
    select(strain, barcode) %>%
    distinct() %>%
    group_by(strain) %>%
    count() %>%
    rename("#sample w/ deletion" = n)

df_summary <-
    inner_join(df_samples, df_deletion, by = "strain") %>%
    mutate(percentage = `#sample w/ deletion` / `#sample` * 100) %>%
    mutate(percentage = round(percentage, digit = 1))

write_csv(df_summary, "reports/table.csv")
