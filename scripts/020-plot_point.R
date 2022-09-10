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
    mutate(alleleper = n / sum(n) * 100) %>%
    ungroup()

pos <- position_jitter(width = 0.3, seed = 1)

g_point <-
    ggplot(df_point, aes(x = strain, y = alleleper, color = strain, label = barcode)) +
    geom_jitter(position = pos) +
    # geom_text_repel(show.legend = FALSE, position = pos) +
    theme_bw() +
    theme(
        text = element_text(size = 12),
        axis.title.x = element_text(size = 14),
        axis.title.y = element_text(size = 14),
        strip.text = element_text(size = 16, face = "bold")
    ) +
    labs(x = "Strain", y = "% of reads", color = "Strain") +
    facet_wrap(~allele)

ggsave(g_point, filename = "reports/point_plot.png", width = 16, height = 4)
ggsave(g_point, filename = "reports/point_plot.pdf", width = 16, height = 4)

#####################################################################

# df_stack <-
#     df %>%
#     group_by(strain, allele) %>%
#     count(allele) %>%
#     group_by(strain) %>%
#     mutate(per = n / sum(n) * 100) %>%
#     ungroup()

# g_stack <-
#     ggplot(df_stack, aes(x = strain, y = per, fill = allele)) +
#     geom_bar(position = "fill", stat = "identity") +
#     theme_bw() +
#     labs(x = "Strain", y = "% of reads", color = "Strain")

# ggsave(g_stack, filename = "reports/stack_plot.png", width = 8, height = 4)
# ggsave(g_stack, filename = "reports/stack_plot.pdf", width = 8, height = 4)


# # ## Statistics

# df_stack %>% filter(str_detect(strain, "C3H|NC"))
# tmp <-
#     df %>%
#     filter(str_detect(strain, "B6N|C3H"))

# chisq_test(tmp, strain ~ allele)


# values <-
#     tmp %>%
#     filter(condition != "control") %>%
#     group_by(strain, allele) %>%
#     count(allele) %>%
#     group_by(strain) %>%
#     mutate(per = n / sum(n)) %>%
#     ungroup() %>%
#     arrange(strain) %>%
#     pull(n) %>%
#     matrix(ncol = 2)


# chisq.value <- chisq.test(values)$statistic
# p <- 0.1
# delta <- sum(values) * p**2
# ddof <- nrow(values) - 1
# 1 - pchisq(chisq.value, ddof, delta, lower.tail = TRUE)


# # vx <- matrix(c(43, 20, 28, 15, 31, 11), nrow = 2, byrow = T)
# # chisq.test(vx)

# # chisq.value <- chisq.test(vx)$statistic
# # p <- 0
# # delta <- sum(vx) * p**2
# # ddof <- ncol(vx) - 1
# # 1 - pchisq(chisq.value, ddof, delta, lower.tail = TRUE)

# # pchisq(chisq.value, 3, 0)

# # values <- as.table(rbind(c(358565, 123, 95288, 4793), c(197649, 333, 55328, 18399)))
# # chisq.test(values)
