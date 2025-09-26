class packet_in #(parametr int WIDTH_FIFO = 32);
    rand logic [WIDTH_FIFO - 1:0]    data_1st_i;
    rand logic [WIDTH_FIFO - 1:0]    data_2d_i ;
endclass

class packet_out #(parametr int WIDTH_FIFO = 32);
    logic [WIDTH_FIFO - 1:0]    data_1st_o ;
    logic [WIDTH_FIFO - 1:0]    data_2d_o  ;
    logic                       vld_o      ;
    logic                       statuses_o ;
endclass
