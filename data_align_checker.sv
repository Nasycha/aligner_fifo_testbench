class checker_data_aligner_base;

    data_align_cfg cfg;

    bit done;
    int cnt;
    bit in_reset;
    bit reset_done = 0; // флаг для того чтобы если был сброс 
    // и мы потеряли 4 пакета, не было ошибки

    mailbox#(packet_out) out_mbx;
    mailbox#(packet_in) in_mbx;


    // очередь для ожидаемых выходов
    typedef struct packed {
        logic [31:0] data_1st;
        logic [31:0] data_2d;
        logic [1:0]  statuses;
    } expected_t;
    
    expected_t exp;

    // локальные переменные
    logic [1:0] statuses_o_check;

    // очередь
    logic [31:0] queue_fifo_check[$];

    // очередь ожидаемых выходов
    expected_t expected_q[$];


    virtual task run();
        packet_in tmp_p;
        forever begin
            wait(~in_reset);
            fork
                do_check();
                wait(in_reset);
            join_any
            disable fork;
            reset_fifo();
            reset_done = 1;
            if(done) break;
            while (in_mbx.try_get(tmp_p)) cnt++;
        end
    endtask

    virtual task do_check();
        packet_in p_in;
        packet_out  p_out;
        forever begin
            fork
                begin
                    in_mbx.get(p_in);
                    simulate_fifo(p_in);
                end

                begin
                    out_mbx.get(p_out);
                    check_correct( p_out);
                    cnt++;
                    // проверка, если у нас был сброс в середине теста,
                    //  то мы теряем cfg.DELAY_BW_1ST_2D пакетов и это нормально
                    if ((cnt == cfg.pkt_amount && !reset_done) || 
                     (cnt == cfg.pkt_amount-cfg.DELAY_BW_1ST_2D && reset_done)) begin
                        $display("All packets checked: %0d", cnt);
                        done = 1;
                    end
                end
            join_any
        end
    endtask

    
    virtual task reset_fifo();
        queue_fifo_check.delete();
        expected_q.delete();
        exp.statuses = 2'b10; // empty
    endtask

    
    virtual task simulate_fifo(packet_in p_in); // для эмуляции fifo
        // Обработка ТОЛЬКО первичных данных (data_1st_i)
        if (p_in.valid_1st_i && !p_in.valid_2d_i) begin
            only_1st_input(p_in);
        end

        // Обработка ТОЛЬКО вторичных данных (data_2d_i)
        else if ( p_in.valid_2d_i && !p_in.valid_1st_i) begin // пришел 2 сигнал
            only_2d_input(p_in);
        end
        // Обработка обоих сигналов
        else if (p_in.valid_1st_i && p_in.valid_2d_i) begin
            only_1st_input(p_in);
            only_2d_input(p_in);
        end
    endtask

    virtual task only_1st_input(packet_in p_in);
        if (queue_fifo_check.size() < cfg.DEPTH_FIFO) begin // пришел 1 сигнал
            queue_fifo_check.push_back(p_in.data_1st_i);
            change_signal_status();
        end else if (queue_fifo_check.size() == cfg.DEPTH_FIFO) begin
            // если fifo полон, то просто игнорируем новые данные
            $display($time(), " [CHECKER] WARNING! FIFO full, data_1st_i=0x%h ignored", p_in.data_1st_i);
        end
    endtask


    virtual task only_2d_input(packet_in p_in);
        if ( queue_fifo_check.size() > 0) begin // пришел 2 сигнал
            $display("\n\nCurrent FIFO queue: ");
            foreach (queue_fifo_check[i]) begin
                $display("  [%0d]: %0h", i, queue_fifo_check[i]);
            end

            // добавляем ожидаемые выходы в очередь проверки
            exp.data_1st = queue_fifo_check.pop_front(); 
            exp.data_2d = p_in.data_2d_i ;
            change_signal_status(); // достаем data1, изменяем сигнал и его сравниваем? порядок?
            exp.statuses = statuses_o_check;
            expected_q.push_back(exp);
        end else if (queue_fifo_check.size() == 0) begin
            // если fifo пуст, то просто игнорируем новые данные
            $display($time(), " [CHECKER] WARNING! FIFO empty, data_2d_i=0x%h ignored", p_in.data_2d_i);
        end
    endtask

    virtual task change_signal_status();
        if (queue_fifo_check.size() == 0) 
            statuses_o_check = 2'b10; // empty
        else if (queue_fifo_check.size() == cfg.DEPTH_FIFO) 
            statuses_o_check = 2'b01; // full
        else 
            statuses_o_check = 2'b00; // normal
    endtask

    virtual task check_correct(packet_out p_out); // функция для сравнения
        if (expected_q.size() == 0) begin
            $error("No expected outputs in queue, but got output from DUT!");
            $finish();
        end
        // достаем из очереди ожидаемых выходов
        exp = expected_q.pop_front(); 
        // проверяем на дефолтные значения
        if (p_out.data_1st_o === cfg.DEFAULT_ELEMENT_2D || p_out.data_2d_o === cfg.DEFAULT_ELEMENT_2D) begin
            $error("vld_o is high, but output data are default!");
            $finish();
        end
        // сравниваем значения данных
        if (p_out.data_1st_o !== exp.data_1st) begin
            $error($time(), " Error: data_1st mismatch. Exp: %0h, Got: %0h",
                    exp.data_1st, p_out.data_1st_o);
            $finish();
        end
        if (p_out.data_2d_o !== exp.data_2d) begin
            $error($time(), " Error: data_2d mismatch. Exp: %0h, Got: %0h",
                    exp.data_2d, p_out.data_2d_o);
            $finish();
        end 
        if (p_out.statuses_o !== exp.statuses) begin
            $error($time(), " Error: statuses_o mismatch. Exp: %0b, Got: %0b",
                    exp.statuses, p_out.statuses_o);
            $finish();
        end
    $display($time, " [CHECKER] Output check PASSED: data_1st_o=0x%h, data_2d_o=0x%h", 
                 p_out.data_1st_o, p_out.data_2d_o);
    $display("cnt=%0d\n", cnt);

    endtask


    
endclass