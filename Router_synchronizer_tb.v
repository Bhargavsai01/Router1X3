module Router_synchronizer_tb;

 // Inputs
 reg clock;
 reg resetn;
 reg detect_addr;
 reg full_0;
 reg full_1;
 reg full_2;
 reg empty_0;
 reg empty_1;
 reg empty_2;
 reg write_en_reg;
 reg read_en_0;
 reg read_en_1;
 reg read_en_2;
 reg [1:0] data_in;

 // Outputs
 wire [2:0] write_enb;
 wire fifo_full;
 wire soft_reset_0;
 wire soft_reset_1;
 wire soft_reset_2;
 wire vld_out_0;
 wire vld_out_1;
 wire vld_out_2;

 // Instantiate the Unit Under Test (UUT)
 Router_synchronizer uut (
  .clock(clock), 
  .resetn(resetn), 
  .detect_addr(detect_addr), 
  .full_0(full_0), 
  .full_1(full_1), 
  .full_2(full_2), 
  .empty_0(empty_0), 
  .empty_1(empty_1), 
  .empty_2(empty_2), 
  .write_en_reg(write_en_reg), 
  .read_en_0(read_en_0), 
  .read_en_1(read_en_1), 
  .read_en_2(read_en_2), 
  .data_in(data_in), 
  .write_enb(write_enb), 
  .fifo_full(fifo_full), 
  .soft_reset_0(soft_reset_0), 
  .soft_reset_1(soft_reset_1), 
  .soft_reset_2(soft_reset_2), 
  .vld_out_0(vld_out_0), 
  .vld_out_1(vld_out_1), 
  .vld_out_2(vld_out_2)
 );
 
 initial begin
   clock=0;
   forever #10 clock=!clock;
 end
 
 //intialization task
 task initialize;
   begin
    {detect_addr,full_0,full_1,full_2,data_in}=0;
  {write_en_reg,read_en_0,read_en_1,read_en_2,empty_0,empty_1,empty_2}=0;
  end
 endtask
 
 //reset task
 task reset;
    begin
    @(negedge clock)
       resetn=1'b0;
    @(negedge clock)
       resetn=1'b1;
  end
 endtask
 
 //task for full
 task full(input t1,input t2,input t3);
   begin
     {full_0,full_1,full_2}={t1,t2,t3};
   end
   endtask
 
 //task for input data
  task input_stimuli(input[1:0] k);
     begin
     @(negedge clock)
       data_in=k;
   end
 endtask
 
 //task for read_enable
 task read_enable(input r1,r2,r3);
  begin
    {read_en_0,read_en_1,read_en_2}={r1,r2,r3};
  end
 endtask
 
 //task for detect_address
 
 task detect_address(input det);
   begin
     detect_addr=det;
   end
 endtask
 
 //task for empty
 task empty_stim(input e1,e2,e3);
    begin
    {empty_0,empty_1,empty_2}={e1,e2,e3};
  end
 endtask
 
 //task for write_enb_reg
 task write_enb_stim(input w1);
   begin
     write_en_reg=w1;
   end
 endtask
 
   
     

 initial begin
  // Initialize Inputs
  initialize;
  reset;
  @(negedge clock);
  read_enable(0,1,0);
  input_stimuli(2'b10);
  detect_address(1);
  full(0,1,1);
  write_enb_stim(1);
  empty_stim(1,0,0);
  #1000 $finish;

  

 end
      
endmodule
