class packet_in #();
    rand logic [31:0]    data_1st_i;
    rand logic [31:0]    data_2d_i ;
         logic           valid_1st_i;
         logic           valid_2d_i;
endclass

class packet_out #();
    logic [31:0]    data_1st_o ;
    logic [31:0]    data_2d_o  ;
    logic [1:0]     statuses_o ;
endclass
