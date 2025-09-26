`timescale 1ns/1ps

module testbench#(
    parameter int DELAY_BW_1ST_2D, // задержка между 1ми и 2ми данными
    parameter int WIDTH_FIFO,
    parameter int DEPTH_FIFO, // глубина FIFO
    parameter logic [31:0]   DEFAULT_ELEMENT_1ST,           // инициализация
    parameter logic [31:0]   DEFAULT_ELEMENT_2D
);

    //---------------------------------
    // Импорт паккейджа тестирования
    //--------------------------------- 

    import test_pkg::*;

    //---------------------------------
    // Сигналы
    //---------------------------------

    logic    clk;
    logic    aresetn;
    localparam logic [31:0]   ELEMENT_TYPE_1ST;                      // типы
    localparam logic [31:0]   ELEMENT_TYPE_2D;

    //---------------------------------
    // Интерфейс
    //---------------------------------
    
    data_aligner_intf_in  #(WIDTH_FIFO) intf_in  (clk, aresetn);
    data_aligner_intf_out #(WIDTH_FIFO) intf_out (clk, aresetn);


    //---------------------------------
    // Модуль для тестирования
    //---------------------------------

    aligner_fifo DUT(
        .clk                 ( clk                 ), // тактирование 
        .aresetn             ( aresetn             ), // сброс
                                                      
        .data_1st_i          ( intf_in.data_1st_i  ), // входные интерфейсы
        .vld_1st_i           ( intf_in.vld_1st_i   ),
        .data_2d_i           ( intf_in.data_2d_i   ),
        .vld_2d_i            ( intf_in.vld_2d_i    ),
                                                      
        .data_1st_o          ( intf_out.data_1st_o ), // выходные интерфейсы
        .data_2d_o           ( intf_out.data_2d_o  ),
        .vld_o               ( intf_out.vld_o      ),
        .statuses_o          ( intf_out.statuses_o ),

        .ELEMENT_TYPE_1ST    ( ELEMENT_TYPE_1ST    ), // конфигурационные параметры
        .ELEMENT_TYPE_2D     ( ELEMENT_TYPE_2D     ),
        .DEFAULT_ELEMENT_1ST ( DEFAULT_ELEMENT_1ST ),
        .DEFAULT_ELEMENT_2D  ( DEFAULT_ELEMENT_2D  ), 
        .DELAY_BW_1ST_2D     ( DELAY_BW_1ST_2D     ),  
        .WIDTH_FIFO          ( WIDTH_FIFO          ),
        .DEPTH_FIFO          ( DEPTH_FIFO          )
    );


    //---------------------------------
    // Переменные тестирования
    //---------------------------------

    // Период тактового сигнала
    parameter CLK_PERIOD = 16.276; // по спецификации


    //---------------------------------
    // Общие методы
    //---------------------------------

    // Генерация сигнала сброса
    task reset();
        aresetn <= 0;
        #(100*CLK_PERIOD); // ждем 1627 нс типо сброс
        aresetn <= 1; // устанавливаем обратно 
    endtask


    //---------------------------------
    // Выполнение
    //---------------------------------

    // генерация тактового сигнала
    initial begin
        clk <= 0;
        forever begin
            #(CLK_PERIOD/2) clk = ~clk; // каждые пол такта меняем фронт на противоположный
        end
    end

    initial begin
        ...
    end
endmodule