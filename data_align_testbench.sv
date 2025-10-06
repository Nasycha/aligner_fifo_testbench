/*
 -------------------------------------------------------------------------------
 -- MOD.DATE: 
 -----------------------
 -- Author          :   ANASTASIA MILKHERT
 -- Target Device   :   XCKU040-FFVA1156-2-I
 -- Software        :   Modelsim 10.6d
 -------------------------------------------------------------------------------
 -- Description:    This testbench is designed to verify the data_aligner 
                    module. The technical specification for data_aligner with 
                    a description of the input and output interfaces, as well as 
                    configuration parameters, is presented in the file 
                    ТЗ_data_aligner.
 -------------------------------------------------------------------------------
*/

`timescale 1ns/1ps

module testbench;

    //---------------------------------
    // Импорт паккейджа тестирования
    //--------------------------------- 

    import test_pkg::*;
    

    //---------------------------------
    // Конфигурация теста
    //---------------------------------
    
    data_align_cfg cfg;

    //---------------------------------
    // Сигналы
    //---------------------------------

    logic    clk;
    logic    aresetn;
    localparam int            DELAY_BW_1ST_2D     = 4;       // задержка между 1ым и 2ым потоком данных (в тактах)
    localparam int            DEPTH_FIFO          = DELAY_BW_1ST_2D;
    localparam logic [31:0]   DEFAULT_ELEMENT_2D = 32'b0;  // значения по умолчанию (какие должны быть?)
    // localparam logic [31:0]   ELEMENT_TYPE_1ST    = 32'b0;       // типы (как указывать и какими должны быть?)
    // localparam logic [31:0]   ELEMENT_TYPE_2D     = 32'b0;


    //---------------------------------
    // Интерфейс
    //---------------------------------
    
    data_aligner_intf_in  intf_in  (clk, aresetn);
    data_aligner_intf_out intf_out (clk, aresetn);


    //---------------------------------
    // Модуль для тестирования
    //---------------------------------

    data_aligner #(
        // type ELEMENT_TYPE_1ST   = logic [31:0], 
        // type ELEMENT_TYPE_2D    = logic [31:0],
        // .ELEMENT_TYPE_1ST    ( ELEMENT_TYPE_1ST    ), // типы
        // .ELEMENT_TYPE_2D     ( ELEMENT_TYPE_2D     ),
        .DEFAULT_ELEMENT_2D  ( DEFAULT_ELEMENT_2D  ), 
        .DELAY_BW_1ST_2D     ( DELAY_BW_1ST_2D     ),  // задержка между 1ым и 2ым потоком данных (в тактах)
        .DEPTH_FIFO          ( DEPTH_FIFO          )  // глубина FIFO
    
    ) DUT(
        .clk                 ( clk                 ), // тактирование 
        .aresetn             ( aresetn             ), // сброс
                                                      
        .data_1st_i          ( intf_in.data_1st_i  ), // входные интерфейсы
        .vld_1st_i           ( intf_in.vld_1st_i   ),
        .data_2d_i           ( intf_in.data_2d_i   ),
        .vld_2d_i            ( intf_in.vld_2d_i    ),
                                                      
        .data_1st_o          ( intf_out.data_1st_o ), // выходные интерфейсы
        .data_2d_o           ( intf_out.data_2d_o  ),
        .vld_o               ( intf_out.vld_o      ),
        .statuses_o          ( intf_out.statuses_o )
    );


    //---------------------------------
    // Переменные тестирования
    //---------------------------------

    // Период тактового сигнала
    parameter CLK_PERIOD = 16.276; // по спецификации

    //---------------------------------
    // Инициализация конфигурации
    //---------------------------------

    initial begin
        cfg = new();
        // копируем параметры для конфигурационного окружения в тестах
        cfg.DELAY_BW_1ST_2D = DELAY_BW_1ST_2D;
        cfg.DEPTH_FIFO = DEPTH_FIFO;
        cfg.DEFAULT_ELEMENT_2D = DEFAULT_ELEMENT_2D;
        // cfg.ELEMENT_TYPE_1ST = ELEMENT_TYPE_1ST;
        // cfg.ELEMENT_TYPE_2D = ELEMENT_TYPE_2D;

        $display("=== Testbench Configuration ===\n");
        $display("\tDELAY_BW_1ST_2D: %0d\n", DELAY_BW_1ST_2D);
        $display("\tDEPTH_FIFO: %0d\n", DEPTH_FIFO);
    end


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
        test_base test;
        test = new(intf_in, intf_out, cfg);
        fork
            reset();
            test.run(); 
        join_none
        repeat(180) @(posedge clk);
        reset();
    end
    
endmodule