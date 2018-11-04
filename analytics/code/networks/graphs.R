library("igraph")
library("tidyverse")

# palette  c("#00AFBB", "#E7B800", "#FC4E07");

# afghanistan

# upload data
read_csv("data/Afghanistan_edges.csv") %>%
  rename(from = Source, to = Target) %>%
  mutate(source = "real") %>%
  as_data_frame -> links

read_csv("results/multihawkes/tol_burn_runs001/Afghanistan_wnet.csv", 
         col_names = c("from", "to", "w"))%>%
  select(from, to) %>%
  filter(from != to) %>%
  left_join(links) %>%
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
coords <- layout_nicely(net_m)

#plot
par(mfrow=c(1,2))
plot(net, vertex.label = NA, 
     edge.width = 1,
     vertex.color = "gray75", main = "Afghanistan (Obs.)", layout = coords)
plot(net_m, vertex.label = NA, 
     edge.width = 1,
     vertex.color = "gray75",
     edge.color = c("gray75", "tomato")[1+(E(net_m)$source == "real")], 
     main = "Afghanistan (Est.)", layout = coords)
dev.off()

# analytics
d_real <- degree(net, normalized = TRUE)
d_mh <- degree(net_m, normalized = TRUE)

transitivity(net)
transitivity(net_m)


