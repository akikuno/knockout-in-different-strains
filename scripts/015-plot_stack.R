pacman::p_load(tidyverse, scales)

df <- read_csv("reports/allele_number.csv.gz")

df <- df %>%
    filter(condition != "control") %>%
    mutate(allele = if_else(allele == "abnormal", "large rearrengement", allele)) %>%
    mutate(allele = if_else(allele == "target", "deletion", allele)) %>%
    mutate(allele = str_to_upper(allele)) %>%
    mutate(strain = str_to_upper(strain))

df_split <- group_split(df, run)

iwalk(df_split, function(x, idx) {
    df_stack <-
        x %>%
        # count alleles
        group_by(barcode, strain) %>%
        count(allele) %>%
        mutate(per = n / sum(n) * 100) %>%
        ungroup() %>%
        # color setting
        mutate(fill = case_when(
            allele == "LARGE REARRENGEMENT" ~ "gray80",
            allele == "DELETION" ~ "tomato",
            allele == "INVERSION" ~ "mediumpurple3",
            allele == "WT" ~ "limegreen"
        ))

    strain <- df_stack %>%
        select(barcode, strain) %>%
        unite(id, strain:barcode, sep = "-") %>%
        distinct() %>%
        pull(id)

    g_stack <-
        ggplot(df_stack, aes(x = barcode, y = per, fill = allele)) +
        geom_bar(color = "black", position = "fill", stat = "identity", aes(fill = fill)) +
        scale_fill_identity(guide = "legend", labels = df_stack$allele, breaks = df_stack$fill) +
        scale_x_discrete(labels = strain, guide = guide_axis(angle = 90)) +
        scale_y_continuous(labels = percent) +
        theme_bw() +
        theme(
            axis.text.y = element_text(size = 16),
            axis.title = element_text(size = 16),
            strip.text = element_text(size = 16),
            legend.position = "bottom"
        ) +
        labs(x = "Strain", y = "% of reads", fill = "Allele")

    ggsave(g_stack, filename = str_glue("reports/stack_plot_{idx}.pdf"), width = 16, height = 4)
    ggsave(g_stack, filename = str_glue("reports/stack_plot_{idx}.png"), width = 16, height = 4)
})
