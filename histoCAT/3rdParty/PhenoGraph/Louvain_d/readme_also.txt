Hacking louvain in order to make matlab integration faster.

The new procedure:
	1. Write graph directly to .bin file (instead of text)
		- uint32 uint32 float64
		- see here: http://www.mathworks.com/help/matlab/ref/fwrite.html
		- graph.cpp expects [uint uint double] (a double is 8 bytes, float64?)
		- write_graph_to_bin.m 
	2. convert now takes .bin file as input
		./convert -i graphIN.bin -o graphOUT.bin -w graphOUT.weights
		./community graphOUT.bin -l -1 -w graphOUT.weights > graph.tree
		./hierarchy graph.tree
