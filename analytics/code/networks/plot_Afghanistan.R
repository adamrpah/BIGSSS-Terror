# this code generates the working plot for afghanistan

library("igraph")
library("tidyverse")

### Afghanistan

# upload real data
read_csv("data/Afghanistan_edges.csv") %>%
  rename(from = Source, to = Target) %>%
  distinct %>%
  mutate(s_dir = "real") %>%
  as_data_frame -> links

# generate inverse of real diads
rename(links, from = to, to = from, s_inv = s_dir) -> links_inv

# upload estimated netw and add label for real networks
read_csv("results/multihawkes/tol_burn_runs001/Afghanistan_wnet.csv", 
         col_names = c("from", "to", "w"))%>%
  filter(w > 0.001) %>%
  select(from, to) %>%
  filter(from != to) %>%
  distinct %>%
  left_join(links, by = c("from", "to")) %>%
  left_join(links_inv, by = c("from", "to")) %>%
  mutate(source = ifelse((s_dir == "real" | s_inv == "real"), "real", is.na)) %>%
  mutate( source = replace_na(source, "multihawk")) %>%
  select(from, to, source) %>%
  as_data_frame -> links_m

# generate inverse of estimated diads
rename(links_m, s_dir = source) -> links_m_dir
rename(links_m, from = to, to = from, s_inv = source) -> links_m_inv

# add label for estimated networks in real data
links %>%
  select(from, to) %>%
  left_join(links_m_dir, by=c("from", "to")) %>%
  left_join(links_m_inv, by=c("from", "to")) %>%  
  mutate(source = ifelse((s_dir == "real" | s_inv == "real"), "multihawk", is.na)) %>%
  mutate(source = replace_na(source, "real")) %>%
  select(from, to, source) %>%
  as_data_frame -> links

read_delim("results/multihawkes/tol_burn_runs001/Afghanistan_groupnames.txt", 
           "\t", escape_double = FALSE, col_names = "groups", 
           trim_ws = TRUE) -> nodes

# create graph objects
graph_from_data_frame(links, directed = FALSE, vertices = nodes) -> Afghanistan_net
graph_from_data_frame(links_m, directed = FALSE, vertices = nodes) -> Afghanistan_net_m

# different colors for edges
colors <- c("gray50", "tomato")
E(Afghanistan_net_m)$color <- colors[E(Afghanistan_net_m)$source]

colors <- c("gray50", "tomato")
E(Afghanistan_net)$color <- colors2[E(Afghanistan_net)$source]

# set vertex coordinates
coords <- layout_in_circle(Afghanistan_net)

#plot
#pdf("figures/network_Afghanistan.pdf")
par(mfrow=c(1,2))
plot(Afghanistan_net, 
     #vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     edge.color = c("gray75", "tomato")[1+(E(Afghanistan_net)$source == "multihawk")], 
     vertex.color = "gray75", xlab = "Observed", layout = coords)
plot(Afghanistan_net_m, 
     #vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     vertex.color = "gray75",
     edge.color = c("gray75", "tomato")[1+(E(Afghanistan_net_m)$source == "real")], 
     xlab = "Estimated", layout = coords)
#dev.off()



