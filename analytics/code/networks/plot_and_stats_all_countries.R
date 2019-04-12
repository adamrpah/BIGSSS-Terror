## This file generates the figure that compares estimated and 
# observed networks in the three countries and generates the table
# with the descriptive statistical comparison between the networks

library("igraph")
library("tidyverse")
library("knitr")

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


### Colombia

# upload real data
read_csv("data/Colombia_edges.csv") %>%
  rename(from = Source, to = Target) %>%
  distinct %>%
  mutate(s_dir = "real") %>%
  as_data_frame -> links

# generate inverse of real diads
rename(links, from = to, to = from, s_inv = s_dir) -> links_inv

# upload estimated netw and add label for real networks
read_csv("results/multihawkes/tol_burn_runs001/Colombia_wnet.csv", 
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

read_delim("results/multihawkes/tol_burn_runs001/Colombia_groupnames.txt", 
           "\t", escape_double = FALSE, col_names = "groups", 
           trim_ws = TRUE) -> nodes

# create graph objects
graph_from_data_frame(links, directed = FALSE, vertices = nodes) -> Colombia_net
graph_from_data_frame(links_m, directed = FALSE, vertices = nodes) -> Colombia_net_m

# different colors for edges
colors <- c("gray50", "tomato")
E(Colombia_net_m)$color <- colors[E(Colombia_net_m)$source]

colors <- c("gray50", "tomato")
E(Colombia_net)$color <- colors2[E(Colombia_net)$source]

# set vertex coordinates
coords <- layout_in_circle(Colombia_net)

### Iraq

# upload real data
read_csv("data/Iraq_edges.csv") %>%
  rename(from = Source, to = Target) %>%
  distinct %>%
  mutate(s_dir = "real") %>%
  as_data_frame -> links

# generate inverse of real diads
rename(links, from = to, to = from, s_inv = s_dir) -> links_inv

# upload estimated netw and add label for real networks
read_csv("results/multihawkes/tol_burn_runs001/Iraq_wnet.csv", 
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

read_delim("results/multihawkes/tol_burn_runs001/Iraq_groupnames.txt", 
           "\t", escape_double = FALSE, col_names = "groups", 
           trim_ws = TRUE) -> nodes

# create graph objects
graph_from_data_frame(links, directed = FALSE, vertices = nodes) -> Iraq_net
graph_from_data_frame(links_m, directed = FALSE, vertices = nodes) -> Iraq_net_m

# different colors for edges
colors <- c("gray50", "tomato")
E(Iraq_net_m)$color <- colors[E(Iraq_net_m)$source]

colors <- c("gray50", "tomato")
E(Iraq_net)$color <- colors2[E(Iraq_net)$source]

# set vertex coordinates
coords <- layout_in_circle(Iraq_net)

### Plot

pdf("figures/network_all.pdf")

par(mar=c(.5,.5,.5,.5))
layout(matrix(c(1,2,3,4, 5, 6, 7,8, 9, 10, 11, 12), ncol=3),heights=c(2,5,5,5), widths=c(2,4,4))
# row titles
plot.new()
plot.new()
text(0.5,0.5,"Afghanistan",cex=1.5,font=2, srt = 90)
plot.new()
text(0.5,0.5,"Colombia",cex=1.5,font=2, srt = 90)
plot.new()
text(0.5,0.5,"Iraq",cex=1.5,font=2, srt = 90)

#column title 1
plot.new()
text(0.5,0.5,"Actual",cex=1.5,font=2)

# afghanistan real
plot(Afghanistan_net, 
     vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     edge.color = c("gray75", "tomato")[1+(E(Afghanistan_net)$source == "multihawk")], 
     vertex.color = "gray75", layout = coords_a)

# colombia real
plot(Colombia_net, 
     vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     edge.color = c("gray75", "tomato")[1+(E(Colombia_net)$source == "multihawk")], 
     vertex.color = "gray75", layout = coords_c)

#iraq real
plot(Iraq_net, 
     vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     edge.color = c("gray75", "tomato")[1+(E(Iraq_net)$source == "multihawk")], 
     vertex.color = "gray75", layout = coords_i)

#column title 2
plot.new()
text(0.5,0.5,"Inferred",cex=1.5,font=2)

#afghanistan estimated
plot(Afghanistan_net_m, 
     vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     vertex.color = "gray75",
     edge.color = c("gray75", "tomato")[1+(E(Afghanistan_net_m)$source == "real")], 
     layout = coords_a)

# colobia estimated
plot(Colombia_net_m, 
     vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     vertex.color = "gray75",
     edge.color = c("gray75", "tomato")[1+(E(Colombia_net_m)$source == "real")], 
     layout = coords_c)

# iraq estimated
plot(Iraq_net_m, 
     vertex.label = NA, 
     edge.width = 1,
     edge.arrow.size=.2,
     vertex.color = "gray75",
     edge.color = c("gray75", "tomato")[1+(E(Iraq_net_m)$source == "real")], 
     layout = coords_i)

dev.off()

### Statistical comparison between netwroks

# calculate average degree
d_r_a <- as.data.frame(degree(Afghanistan_net, normalized = TRUE))
m_d_r_a <- round(mean(d_r_a$`degree(Afghanistan_net, normalized = TRUE)`), 2)
d_e_a <- as.data.frame(degree(Afghanistan_net_m, normalized = TRUE))
m_d_e_a <- round(mean(d_e_a$`degree(Afghanistan_net_m, normalized = TRUE)`), 2)

d_r_c <- as.data.frame(degree(Colombia_net, normalized = TRUE))
m_d_r_c <- round(mean(d_r_c$`degree(Colombia_net, normalized = TRUE)`), 2)
d_e_c <- as.data.frame(degree(Colombia_net_m, normalized = TRUE))
m_d_e_c <- round(mean(d_e_c$`degree(Colombia_net_m, normalized = TRUE)`), 2)

d_r_i <- as.data.frame(degree(Iraq_net, normalized = TRUE))
m_d_r_i <- round(mean(d_r_i$`degree(Iraq_net, normalized = TRUE)`), 2)
d_e_i <- as.data.frame(degree(Iraq_net_m, normalized = TRUE))
m_d_e_i <- round(mean(d_e_i$`degree(Iraq_net_m, normalized = TRUE)`), 2)

t_a_r <- transitivity(Afghanistan_net)
t_a_e <- transitivity(Afghanistan_net_m)
t_c_r <- transitivity(Colombia_net)
t_c_e <- transitivity(Colombia_net_m)
t_i_r <- transitivity(Iraq_net)
t_i_e <- transitivity(Iraq_net_m)

names <- c("", "", "Afghanistan", "Colombia", "Iraq")
d_obs <- c("Degree", "Observed", m_d_r_a, m_d_r_c, m_d_r_i)
d_est <- c("Degree", "Estimated", m_d_e_a, m_d_e_c, m_d_e_i)
t_obs <- c("Trasitivity", "Observed", t_a_r, t_c_r, t_i_r)
t_est <- c("Trasitivity", "Estimated", t_a_e, t_c_e, t_i_e)

kable(cbind(names, d_obs, d_est, t_obs, t_est), format = "latex")





