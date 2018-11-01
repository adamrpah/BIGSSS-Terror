library("igraph")
library("tidyverse")

# afghanistan
read_csv("data/Afghanistan_edges.csv") -> links
read_csv("results/multihawkes/tol_burn_runs001/Afghanistan_wnet.csv", 
         col_names = c("from", "to", "w")) %>%
  select(from, to) -> links_m
read_csv("data/Afghanistan_groups.csv", col_names = c("groups")) -> nodes
unique(links$from) -> nodes
graph_from_data_frame(links_m, directed = FALSE, vertices = nodes) -> net_m
graph_from_data_frame(links, directed = FALSE, vertices = nodes) -> net
plot.igraph(net)
plot.igraph(net_m)

degree(net)
degree(net_m)

transitivity(net)
transitivity(net_m)


# iraq
read_csv("data/Iraq_edges.csv") -> links
read_csv("results/multihawkes/tol_burn_runs001/Iraq_wnet.csv", 
         col_names = c("from", "to", "w")) %>%
  select(from, to) -> links_m
read_csv("data/Iraq_groups.csv", col_names = c("groups")) -> nodes
unique(links$from) -> nodes
graph_from_data_frame(links_m, directed = FALSE, vertices = nodes) -> net_m
graph_from_data_frame(links, directed = FALSE, vertices = nodes) -> net
plot.igraph(net)
plot.igraph(net_m)
