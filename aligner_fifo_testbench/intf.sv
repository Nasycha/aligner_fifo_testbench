interface data_aligner_intf_in #(parametr int WIDTH_FIFO)( // входной интерфейс
    input logic clk,
    input logic aresetn
    );
    logic [WIDTH_FIFO - 1:0] data_1st_i;
    logic [WIDTH_FIFO - 1:0] data_2d_i;
    logic                    vld_1st_i;
    logic                    vld_2d_i;
    
endinterface

interface data_aligner_intf_out #(parametr int WIDTH_FIFO)( // выходной интерфейс
    input logic clk,
    input logic aresetn
    );
    logic [WIDTH_FIFO - 1:0] data_1st_o;
    logic [WIDTH_FIFO - 1:0] data_2d_o;
    logic                    vld_o;
    logic [1:0]              statuses_o; // сигнал статусов FIFO

endinterface