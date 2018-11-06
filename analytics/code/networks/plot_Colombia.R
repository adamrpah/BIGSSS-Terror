library("igraph")
library("tidyverse")

### Colombia

# upload data
read_csv("data/Colombia_edges.csv") %>%
  rename(from = Source, to = Target) %>%
  distinct %>%
  mutate(source = "real") %>%
  as_data_frame -> links

rename(links, from = to, to = from) -> links_inv

read_csv("results/multihawkes/tol_burn_runs001/Colombia_wnet.csv", 
         col_names = c("from", "to", "w"))%>%
  filter(w > 0.001) %>%
  select(from, to) %>%
  filter(from != to) %>%
  distinct %>%
  left_join(links) %>%
  left_join(links2) %>%
  mutate( source = replace_na(source, "multihawk")) %>%
  as_data_frame -> links_m

read_delim("results/multihawkes/tol_burn_runs001/Colombia_groupnames.txt", 
           "\t", escape_double = FALSE, col_names = "groups", 
           trim_ws = TRUE) -> nodes

# create graph objects
graph_from_data_frame(links, directed = FALSE, vertices = nodes) -> Colombia_net
graph_from_data_frame(links_m, directed = FALSE, vertices = nodes) -> Colombia_net_m

# different colors for edges
colors <- c("gray50", "tomato")
E(Colombia_net_m)$color <- colors[E(Colombia_net_m)$source]


# set vertex coordinates
coords <- layout_in_circle(Colombia_net)

#plot
pdf("figures/network_Colombia.pdf")
par(mfrow=c(1,2))
plot(Colombia_net, 
     vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     edge.color = "tomato",
     vertex.color = "gray75", xlab = "Observed", layout = coords)
plot(Colombia_net_m, vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     vertex.color = "gray75",
     edge.color = c("gray75", "tomato")[1+(E(Colombia_net_m)$source == "real")], 
     xlab = "Estimated", layout = coords)
dev.off()

