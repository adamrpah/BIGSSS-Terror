library("igraph")
library("tidyverse")

### Iraq

# upload data
read_csv("data/Iraq_edges.csv") %>%
  rename(from = Source, to = Target) %>%
  distinct %>%
  mutate(source = "real") %>%
  as_data_frame -> links

rename(links, from = to, to = from) -> links_inv

read_csv("results/multihawkes/tol_burn_runs001/Iraq_wnet.csv", 
         col_names = c("from", "to", "w"))%>%
  filter(w > 0.001) %>%
  select(from, to) %>%
  filter(from != to) %>%
  distinct %>%
  left_join(links) %>%
  left_join(links2) %>%
  mutate( source = replace_na(source, "multihawk")) %>%
  as_data_frame -> links_m

read_delim("results/multihawkes/tol_burn_runs001/Iraq_groupnames.txt", 
           "\t", escape_double = FALSE, col_names = "groups", 
           trim_ws = TRUE) -> nodes

# create graph objects
graph_from_data_frame(links, directed = FALSE, vertices = nodes) -> Iraq_net
graph_from_data_frame(links_m, directed = FALSE, vertices = nodes) -> Iraq_net_m

# different colors for edges
colors <- c("gray50", "tomato")
E(Iraq_net_m)$color <- colors[E(Iraq_net_m)$source]


# set vertex coordinates
coords <- layout_in_circle(Iraq_net)

#plot
pdf("figures/network_Iraq.pdf")
par(mfrow=c(1,2))
plot(Iraq_net, 
     vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     edge.color = "tomato",
     vertex.color = "gray75", xlab = "Observed", layout = coords)
plot(Iraq_net_m, vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     vertex.color = "gray75",
     edge.color = c("gray75", "tomato")[1+(E(Iraq_net_m)$source == "real")], 
     xlab = "Estimated", layout = coords)
dev.off()

