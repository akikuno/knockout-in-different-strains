pacman::p_load(tidyverse, ggrepel)

df <-
    read_csv("reports/allele_number.csv.gz") %>%
    filter(str_detect(allele, "target|abnormal")) %>%
    filter(condition != "control") %>%
    mutate(allele = if_else(allele == "abnormal", "large rearrengement", allele)) %>%
    mutate(allele = if_else(allele == "target", "deletion", allele)) %>%
    mutate(allele = str_to_upper(allele)) %>%
    mutate(strain = str_to_upper(strain))

df_point <-
    df %>%
    mutate(barcode = str_remove(barcode, "barcode")) %>%
    group_by(strain, barcode) %>%
    count(allele) %>%
    mutate(alleleper = n / sum(n)) %>%
    ungroup()

df_point$strain <-
    factor(df_point$strain, levels = c("BALBC", "NC", "CBA", "C3H", "SJL", "DBA1", "DBA2", "B6N"))
pos <- position_jitter(width = 0.3, seed = 1)

g_point <-
    ggplot(df_point, aes(x = strain, y = alleleper, color = strain, label = barcode)) +
    geom_jitter(position = pos) +
    scale_y_continuous(labels = percent) +
    # geom_text_repel(show.legend = FALSE, position = pos) +
    theme_bw() +
    theme(
        text = element_text(size = 12),
        axis.text = element_text(size = 16),
        axis.title = element_text(size = 16),
        strip.text = element_text(size = 16),
        legend.position = "none"
    ) +
    labs(x = "Strain", y = "% of reads") +
    facet_wrap(~allele)

# ggsave(g_point, filename = "reports/point_plot.png", width = 16, height = 4)
ggsave(g_point, filename = "reports/point_plot.pdf", width = 16, height = 4)
