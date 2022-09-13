pacman::p_load(tidyverse)

df <- read_csv("reports/allele_number.csv.gz")

df_filtered <- df %>%
    filter(condition != "control")

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
    count()

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
    ungroup() %>%
    mutate(sum = sum(n))

inner_join(df_samples, df_deletion, by = "strain") %>%
    mutate(percentage = n.y / n.x * 100)
