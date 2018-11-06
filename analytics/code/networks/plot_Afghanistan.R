library("igraph")
library("tidyverse")

# palette  c("#00AFBB", "#E7B800", "#FC4E07");

# afghanistan

# upload data
read_csv("data/Afghanistan_edges.csv") %>%
  rename(from = Source, to = Target) %>%
  distinct %>%
  mutate(source = "real") %>%
  as_data_frame -> links

rename(links, from = to, to = from) -> links_inv


read_csv("results/multihawkes/tol_burn_runs001/Afghanistan_wnet.csv", 
         col_names = c("from", "to", "w"))%>%
  filter(w > 0.001) %>%
  select(from, to) %>%
  filter(from != to) %>%
  distinct %>%
  left_join(links) %>%
  left_join(links2) %>%
  mutate( source = replace_na(source, "multihawk")) %>%
  as_data_frame -> links_m

read_delim("results/multihawkes/tol_burn_runs001/Afghanistan_groupnames.txt", 
                                     "\t", escape_double = FALSE, col_names = "groups", 
                                     trim_ws = TRUE) -> nodes

# create graph objects
graph_from_data_frame(links, directed = FALSE, vertices = nodes) -> net
graph_from_data_frame(links_m, directed = FALSE, vertices = nodes) -> net_m

# different colors for edges
colors <- c("gray50", "tomato")
E(net_m)$color <- colors[E(net_m)$source]

# set vertex coordinates
coords <- layout_as_star(net_m)

#plot
pdf("figures/network_Afghanistan.pdf", height = 7, width = 14)
par(mfrow=c(1,2))
plot(net, vertex.label = NA, 
     edge.width = 1,
     edge.color = "tomato",
     vertex.color = "gray75", xlab = "Observed", layout = coords)
plot(net_m, vertex.label = NA, 
     edge.width = 1,
     vertex.color = "gray75",
     edge.color = c("gray75", "tomato")[1+(E(net_m)$source == "real")], 
     xlab = "Estimated", layout = coords)
dev.off()

# analytics
#d_real <- degree(net, normalized = TRUE)
#d_mh <- degree(net_m, normalized = TRUE)

#transitivity(net)
#transitivity(net_m)


